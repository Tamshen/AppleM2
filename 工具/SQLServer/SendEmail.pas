unit SendEmail;

interface

uses
  Windows, SysUtils, Classes, IdComponent, IdSMTPBase, IdSMTP, StdCtrls, IdMessage, DateUtils;

type
  pTSendEmailInfo = ^TSendEmailInfo;
  TSendEmailInfo = record
    saddressee: string[30];
    sSendName: string;
    sTitle: string;
    sText: string;
    nErrorCount: Integer;
  end;
  TEmailThread = class(TThread)
  private
    FCriticalSection: TRTLCriticalSection;
    FIdSMTP: TIdSMTP;
    FIdMessage: TIdMessage;
    FConnected: Boolean;
    FSendList1: TList;
    FSendList2: TList;
    procedure Lock;
    procedure UnLock;
    function GetSendCount: Integer;
  protected
    procedure Execute; override;

  public
    constructor Create(CreateSuspended: Boolean);
    destructor Destroy; override;
    procedure SMTPStatus(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
    procedure AddSendEmail(sName, sAddressee, sTitle, sText: string);
    property Connected: Boolean read FConnected;
    property SendCount: Integer read GetSendCount;
  end;

var
  EMailThread: TEMailThread;
  g_nSendEMailCount: Integer;
  g_nSendEMailFail: Integer;

implementation

uses
  Share;

{ Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure TSendEmail.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ TSendEmail }

procedure TEmailThread.AddSendEmail(sName, sAddressee, sTitle, sText: string);
var
  SendEmailInfo: pTSendEmailInfo;
begin
  if (sAddressee <> '') and (sTitle <> '') and (sText <> '') then begin
    New(SendEmailInfo);
    SendEmailInfo.saddressee := sAddressee;
    SendEmailInfo.sSendName := sName;
    SendEmailInfo.sTitle := sTitle;
    SendEmailInfo.sText := sText;
    SendEmailInfo.nErrorCount := 0;
    Lock;
    Try
      FSendList1.Add(SendEmailInfo);
    Finally
      UnLock;
    End;
  end;
end;

constructor TEmailThread.Create(CreateSuspended: Boolean);
begin
  inherited Create(CreateSuspended);
  InitializeCriticalSection(FCriticalSection);
  //FreeOnTerminate := True;
  FIdSMTP := TIdSMTP.Create(nil);
  FIdSMTP.OnStatus := SMTPStatus;
  FIdMessage := TIdMessage.Create(nil);
  FConnected := False;
  FSendList1 := TList.Create;
  FSendList2 := TList.Create;
end;

destructor TEmailThread.Destroy;
begin
  FSendList1.Free;
  FSendList2.Free;
  FIdMessage.Free;
  FIdSMTP.Free;
  DeleteCriticalSection(FCriticalSection);
  inherited;
end;

procedure TEmailThread.Execute;
var
  i: Integer;
  SendEmailInfo: pTSendEmailInfo;
begin
  while (not Terminated) and (g_sEMailNameList.Count > 0) do begin
    Try
      Lock;
      Try
        if FSendList1.Count > 0 then begin
          for I := 0 to FSendList1.Count - 1 do
            FSendList2.Add(FSendList1[I]);
          FSendList1.Clear;
        end;
      Finally
        UnLock;
      End;
      if (FSendList2.Count > 0) then begin
        Try
          if FIdSMTP.Connected then FIdSMTP.Disconnect();
        Except
        End;
        {FIdSMTP.Username := 'service@mir2k.com'; //�������ϵ��û���
        FIdSMTP.Password := '19850506'; //�������ϵ�����
        FIdSMTP.Host := 'smtp.qq.com'; //������SMTP��ַ      }
        FIdSMTP.Username := g_sEMailNameList[Random(g_sEMailNameList.Count)]; //�������ϵ��û���
        //FIdSMTP.Username := 'service_20@mir2k.net'; //�������ϵ��û���
        FIdSMTP.Password := g_sEMailPassword; //�������ϵ�����
        FIdSMTP.Host := g_sEMailSmtpHost; //������SMTP��ַ
        FIdSMTP.Port := g_sEMailSmtpPort; //�������˿�
        FIdMessage.From.address := FIdSMTP.Username; //�����˵�ַ
        FIdMessage.ContentType := 'text/html';
        Try
          FIdSMTP.Connect; //��������
        Except
          on E:Exception do begin
            MainOutMessage('[Exception] EMail->Connect');
            MainOutMessage(E.Message);
            Sleep(5000);
            Continue;
          end;
        End;
        I := 0;
        while (FSendList2.Count > 0) and (not Terminated) do begin
          if I >= 20 then break;
          SendEmailInfo := pTSendEmailInfo(FSendList2[0]);
          FIdMessage.Body.SetText(PChar(SendEmailInfo.sText)); //�ʼ����ļ�����
          FIdMessage.From.Name := SendEmailInfo.sSendName;
          FIdMessage.Recipients.EMailAddresses := SendEmailInfo.saddressee; //�ռ��˵�ַ�������Ϊ���EMAIL��ַ
          FIdMessage.Subject := SendEmailInfo.sTitle; //�ʼ�����
          FIdMessage.Date := IncHour(now(), -8);
          FIdMessage.Priority := mpNormal; //���ȼ���mphighΪ��߼���
          Try
            FIdSMTP.Send(FIdMessage); //�����ʼ�
            Dispose(SendEmailInfo);
            FSendList2.Delete(0);
            Inc(g_nSendEMailCount);
            Inc(I);
          Except
            on E:Exception do begin
              Inc(g_nSendEMailFail);
              Inc(SendEmailInfo.nErrorCount);
              if SendEmailInfo.nErrorCount > 1 then begin
                Dispose(SendEmailInfo);
                FSendList2.Delete(0);
              end;
              MainOutMessage('[Exception] EMail->SendMsg');
              MainOutMessage(E.Message);
              break;
            end;
          End;
          Sleep(10);
        end;
        FIdSMTP.Disconnect();
      end;
    Except
      Sleep(5000);
    End;
    Sleep(2000);
  end;
end;

function TEmailThread.GetSendCount: Integer;
begin
  Lock;
  Try
    Result := FSendList1.Count;
  Finally
    UnLock;
  End;
end;

procedure TEmailThread.Lock;
begin
  EnterCriticalSection(FCriticalSection);
end;

procedure TEmailThread.SMTPStatus(ASender: TObject; const AStatus: TIdStatus; const AStatusText: string);
begin
  case AStatus of
    hsResolving: ;
    hsConnecting: ;
    hsConnected: FConnected := True;
    hsDisconnecting: ;
    hsDisconnected: FConnected := False;
    hsStatusText: ;
    ftpTransfer: ;
    ftpReady: ;
    ftpAborted: ;
  end;
end;

procedure TEmailThread.UnLock;
begin
  LeaveCriticalSection(FCriticalSection);
end;

end.
