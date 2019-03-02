unit FrmRegID;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, JSocket, StdCtrls, Common;

type
  TFormReg = class(TForm)
    grp1: TGroupBox;
    lbl1: TLabel;
    lbl2: TLabel;
    lbl3: TLabel;
    lbl4: TLabel;
    lbl5: TLabel;
    lbl6: TLabel;
    lbl7: TLabel;
    lbl8: TLabel;
    lbl9: TLabel;
    lbl10: TLabel;
    lbl11: TLabel;
    lbl12: TLabel;
    lbl13: TLabel;
    lbl14: TLabel;
    edt_EdNewId: TEdit;
    edt_EdPasswd: TEdit;
    edt_EdNewPasswd: TEdit;
    edt_EdYourName: TEdit;
    edt_EdSSNo: TEdit;
    edt_EdBirthDay: TEdit;
    edt_EdQuiz1: TEdit;
    edt_EdAnswer1: TEdit;
    edt_EdQuiz2: TEdit;
    edt_EdAnswer2: TEdit;
    edt_EdEMail: TEdit;
    edt_EdPhone: TEdit;
    edt_EdMobPhone: TEdit;
    btnOK: TButton;
    mmoMsg: TMemo;
    btn1: TButton;
    lbl15: TLabel;
    lbl16: TLabel;
    ClientSocket: TClientSocket;
    tmr1: TTimer;
    procedure edt_EdNewIdEnter(Sender: TObject);
    procedure ClientSocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
      var ErrorCode: Integer);
    procedure ClientSocketConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
    procedure tmr1Timer(Sender: TObject);
    procedure edt_EdNewIdKeyPress(Sender: TObject; var Key: Char);
    procedure btnOKClick(Sender: TObject);
  private
    code: byte;
    procedure SendSocket(sendstr: string);
    procedure CheckEditText();
    function NewIdCheckBirthDay: Boolean;
    function CheckID(sUserID: string): Boolean;
    procedure NewAccountOk;
  public

    procedure Open(addrs: string; Port: Word);

  end;

var
  FormReg: TFormReg;

implementation

{$R *.dfm}

uses
  Hutil32, Grobal2, EDcode;

procedure TFormReg.btnOKClick(Sender: TObject);
begin
  CheckEditText;
end;

procedure TFormReg.CheckEditText;
begin
  if Length(edt_EdNewId.Text) < 5 then begin
    MessageBox(Handle, '�˺ų��ȱ������ 4λ.', '��ʾ��Ϣ', MB_OK or MB_ICONASTERISK);
    edt_EdNewId.SetFocus;
    exit;
  end;
  if not CheckID(edt_EdNewId.Text) then begin
    MessageBox(Handle, '�˺Ű����˷Ƿ��ַ���ֻ��ʹ�����ֺ�Ӣ����ĸ.', '��ʾ��Ϣ', MB_OK or
      MB_ICONASTERISK);
    edt_EdNewId.SetFocus;
    exit;
  end;

  if Length(edt_EdPasswd.Text) < 5 then begin
    MessageBox(Handle, '���볤�ȱ������ 4λ.', '��ʾ��Ϣ', MB_OK or MB_ICONASTERISK);
    edt_EdPasswd.SetFocus;
    exit;
  end;
  if edt_EdNewPasswd.Text <> edt_EdPasswd.Text then begin
    MessageBox(Handle, '������������벻һ��������', '��ʾ��Ϣ', MB_OK or MB_ICONASTERISK);
    edt_EdNewPasswd.SetFocus;
    exit;
  end;
  if edt_EdYourName.Text = '' then begin
    Beep;
    edt_EdYourName.SetFocus;
    exit;
  end;
  if edt_EdBirthDay.Text = '' then begin
    Beep;
    edt_EdBirthDay.SetFocus;
    exit;
  end;
  if not NewIdCheckBirthDay then
    exit;
  if edt_EdQuiz1.Text = '' then begin
    Beep;
    edt_EdQuiz1.SetFocus;
    exit;
  end;
  if edt_EdAnswer1.Text = '' then begin
    Beep;
    edt_EdAnswer1.SetFocus;
    exit;
  end;
  if edt_EdQuiz2.Text = '' then begin
    Beep;
    edt_EdQuiz2.SetFocus;
    exit;
  end;
  if edt_EdAnswer2.Text = '' then begin
    Beep;
    edt_EdAnswer2.SetFocus;
    exit;
  end;
  if BtnOK.Enabled then
    NewAccountOk;
end;

function TFormReg.CheckID(sUserID: string): Boolean;
var
  i: Integer;
begin
  Result := True;
  if sUserID <> '' then begin
    for I := 1 to Length(sUserID) do begin
      if not (sUserID[I] in [#48..#57, #65..#90, #95, #97..#122]) then begin
        Result := False;
        break;
      end;

    end;

  end;
end;

procedure TFormReg.ClientSocketConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  Socket.SendText('*');
  //Lbl16.Caption:='������״̬����...';
  //Timer1.Enabled:=True;
end;

procedure TFormReg.ClientSocketDisconnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  Lbl16.Caption := '�����ѹر�...';
end;

procedure TFormReg.ClientSocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent;
  var ErrorCode: Integer);
begin
  ErrorCode := 0;
  Socket.Close;
  Lbl16.Caption := '���ӷ�����ʧ��...';
end;

procedure TFormReg.ClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
ResourceString
  sText1  = '[%s]�Ѿ����������ʹ���ˡ�'#13#10'������ѡ���û�����';
  sText2  = '�ڱ��������ϣ����û����ѱ���ֹʹ�á�'#13#10'����ѡһ����ͬ�����֡�';
  sText3  = '����IDʧ�ܣ���ȷ��û�а����ո�'#13#10'���⡢�����Ա��ϵ��ַ��� Code: %d';
  sText4  = '����˺��Ѿ�������.'#13#10;
  sText5  = ' �����Ʊ��ܺ�����˺ź����룬'#13#10;
  sText6  = '���Ҳ�Ҫ���κ�ԭ������������κ������ˡ�'#13#10;
  sText7  = ' ��������������룬'#13#10;
  sText8  = '�����ͨ��������ҳ�����һ�����'#13#10;
var
  datablock, data: string;
  msg: TDefaultMessage;
begin
  datablock := Socket.ReceiveText;
  if datablock = '*' then begin
    Socket.SendText(g_CodeHead + '+' + g_CodeEnd);
    Lbl16.Caption := '������״̬����...';
    tmr1.Enabled := True;
  end
  else begin
    //mmoMsg.Lines.Add(datablock);
    ArrestStringEx(datablock, '#', '!', data);
    if Length(data) = DEFBLOCKSIZE then begin
      msg := DecodeMessage(data);
      case msg.Ident of
        SM_NEWID_SUCCESS: begin
            MessageBox(Handle, PChar(sText4 + sText5 + sText6 + sText7 + sText8 {+SF_WEB}), 'ע��ɹ�', MB_OK or MB_ICONASTERISK);
            Close;
          end;
        SM_NEWID_FAIL: begin
            case msg.Recog of
              0: begin
                  MessageBox(Handle, PChar(ForMat(sText1, [edt_EdNewId.Text])), 'ע��ʧ��', MB_OK or MB_ICONASTERISK);
                  edt_EdNewId.Text := '';
                  edt_EdNewId.SetFocus;
                end;
              -2: begin
                  MessageBox(Handle, PChar(sText2), 'ע��ʧ��', MB_OK or MB_ICONASTERISK);
                end;
            else
              MessageBox(Handle, PChar(ForMat(sText3, [msg.Recog])), 'ע��ʧ��', MB_OK or MB_ICONASTERISK);
            end;
            BtnOK.Enabled := False;
            BtnOK.Caption := '���Ե�..';
            tmr1.Enabled := True;
          end;
      end;
    end;
  end;
end;

procedure TFormReg.edt_EdNewIdEnter(Sender: TObject);
begin
  if Sender = edt_EdNewId then begin
    mmoMsg.Lines.Clear;
    mmoMsg.Lines.Add('�ַ������ֵ����');
    mmoMsg.Lines.Add('�˺����Ƴ��ȱ���Ϊ4������');
    mmoMsg.Lines.Add('��½�˺Ų�����Ϸ����������');
    mmoMsg.Lines.Add('����ϸ�����˺���Ϣ'#13#10);
    mmoMsg.Lines.Add('���������˺Ų�Ҫ����Ϸ������������ͬ');
    mmoMsg.Lines.Add('��ȷ���������벻�ᱻ�����ƽ�');
  end;
  if Sender = edt_EdPasswd then begin
    mmoMsg.Lines.Clear;
    mmoMsg.Lines.Add('��������������ַ������ݵ����');
    mmoMsg.Lines.Add('�����볤�Ȳ�������4λ');
    mmoMsg.Lines.Add('�����������벻Ҫ���ڼ�');
    mmoMsg.Lines.Add('�Է����˲µ�');
    mmoMsg.Lines.Add('���ס�����������');
    mmoMsg.Lines.Add('�����ʧ�����޷���½��Ϸ');
  end;
  if Sender = edt_EdNewPasswd then begin
    mmoMsg.Lines.Clear;
    mmoMsg.Lines.Add('�ٴ���������');
    mmoMsg.Lines.Add('��ȷ��');
  end;
  if Sender = edt_EdYourName then begin
    mmoMsg.Lines.Clear;
    mmoMsg.Lines.Add('����������ȫ��');
  end;
  if Sender = edt_EdBirthDay then begin
    mmoMsg.Lines.Clear;
    mmoMsg.Lines.Add('��������������');
    mmoMsg.Lines.Add('���磺1977/10/15');
  end;
  if Sender = edt_EdQuiz1 then begin
    mmoMsg.Lines.Clear;
    mmoMsg.Lines.Add('�������һ��������ʾ����');
    mmoMsg.Lines.Add('�����ʾ�������һ�����');
  end;
  if Sender = edt_EdAnswer1 then begin
    mmoMsg.Lines.Clear;
    mmoMsg.Lines.Add('��������������Ĵ�');
  end;
  if Sender = edt_EdQuiz2 then begin
    mmoMsg.Lines.Clear;
    mmoMsg.Lines.Add('������ڶ���������ʾ����');
    mmoMsg.Lines.Add('�����ʾ�������һ�����');
  end;
  if Sender = edt_EdAnswer2 then begin
    mmoMsg.Lines.Clear;
    mmoMsg.Lines.Add('��������������Ĵ�');
  end;
  if Sender = edt_EdEMail then begin
    mmoMsg.Lines.Clear;
    mmoMsg.Lines.Add('���������ĵ��������ַ');
    mmoMsg.Lines.Add('�����ڽ��շ�����������Ϣ');
  end;
  if Sender = edt_EdPhone then begin
    mmoMsg.Lines.Clear;
    mmoMsg.Lines.Add('������������ϵ�绰');
  end;
  if Sender = edt_EdMobPhone then begin
    mmoMsg.Lines.Clear;
    mmoMsg.Lines.Add('�����������ֻ�����');
  end;
end;

procedure TFormReg.edt_EdNewIdKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = '~') or (Key = '''') or (Key = ' ') then
    Key := #0;
  if Key = #13 then begin
    Key := #0;
    CheckEditText;
  end;
end;

procedure TFormReg.NewAccountOk;
var
  ue: TUserEntry;
  ua: TUserEntryAdd;
  msg: TDefaultMessage;
  SendMsg: string;
begin
  BtnOK.Enabled := False;
  FillChar(ue, sizeof(TUserEntry), #0);
  FillChar(ua, sizeof(TUserEntryAdd), #0);
  ue.sAccount := LowerCase(edt_EdNewId.Text);
  ue.sPassword := edt_EdNewPasswd.Text;
  ue.sUserName := edt_EdYourName.Text;
  ue.sSSNo := edt_EdSSNo.Text;
  ue.sQuiz := edt_EdQuiz1.Text;
  ue.sAnswer := Trim(edt_EdAnswer1.Text);
  ue.sPhone := edt_EdPhone.Text;
  ue.sEMail := Trim(edt_EdEMail.Text);

  ua.sQuiz2 := edt_EdQuiz2.Text;
  ua.sAnswer2 := Trim(edt_EdAnswer2.Text);
  ua.sBirthday := edt_EdBirthDay.Text;
  ua.sMobilePhone := edt_EdMobPhone.Text;
  //ua.sMemo:=SF_Auter;
  //ua.sMemo2:=SF_WEB;

  msg := MakeDefaultMsg(CM_ADDNEWUSER, 0, 0, 0, 0);
  SendMsg := EncodeMessage(msg) + EncodeBuffer(@ue, sizeof(TUserEntry)) + EncodeBuffer(@ua, sizeof(TUserEntryAdd));
  SendSocket(SendMsg);
end;

function TFormReg.NewIdCheckBirthDay: Boolean;
var
  str, syear, smon, sday: string;
  ayear, amon, aday: integer;
  flag: Boolean;
begin
  Result := TRUE;
  flag := TRUE;
  str := edt_EdBirthDay.Text;
  str := GetValidStr3(str, syear, ['/']);
  str := GetValidStr3(str, smon, ['/']);
  str := GetValidStr3(str, sday, ['/']);
  ayear := StrToIntDef(syear, 0);
  amon := StrToIntDef(smon, 0);
  aday := StrToIntDef(sday, 0);
  if (ayear <= 1890) or (ayear > 2101) then
    flag := FALSE;
  if (amon <= 0) or (amon > 12) then
    flag := FALSE;
  if (aday <= 0) or (aday > 31) then
    flag := FALSE;
  if not flag then begin
    edt_EdBirthDay.SetFocus;
    Result := FALSE;
  end;
end;

procedure TFormReg.Open(addrs: string; Port: Word);
begin
  code := 1;
  Lbl16.Caption := '�������ӷ�����...';
  ClientSocket.Close;
  ClientSocket.Host := addrs;
  ClientSocket.Port := Port;
  ClientSocket.Open;
  ShowModal;

end;

procedure TFormReg.SendSocket(sendstr: string);
begin
  if ClientSocket.Socket.Connected then begin
    ClientSocket.Socket.SendText('#' + IntToStr(code) + sendstr + '!');
    Inc(code);
    if code >= 10 then
      code := 1;
  end;
end;

procedure TFormReg.tmr1Timer(Sender: TObject);
begin
  btnOK.Enabled := True;
  btnOK.Caption := 'ȷ��(&O)';
  tmr1.Enabled := False;
end;

end.

