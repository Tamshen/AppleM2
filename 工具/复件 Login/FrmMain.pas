unit FrmMain;

interface

uses
  Windows, Messages, SysUtils, StrUtils, Variants, Classes, Graphics, Controls, Forms, Share,
  Dialogs, ExtCtrls, EzRgnBtn, OleCtrls, SHDocVw, ComCtrls, RzStatus, RzLabel, RSA, 
  XMLDoc, XMLIntf, LShare, LAShare, xmldom, msxmldom, StdCtrls, JSocket, WebBrowserWithUI;

type

  pTMapDataInfo = ^TMapDataInfo;
  TMapDataInfo = packed record
    Handle: THandle;
  end;

  TFormMain = class(TForm)
    ImageBg: TImage;
    BtnMin: TEzRgnBtn;
    BtnClose: TEzRgnBtn;
    TreeViewServer: TTreeView;
    LabelLog: TRzLabel;
    ProgressNow: TRzProgressStatus;
    BtnUpdating: TEzRgnBtn;
    BtnPlay: TEzRgnBtn;
    BtnSetup: TEzRgnBtn;
    BtnExit: TEzRgnBtn;
    LabelNow: TRzLabel;
    LabelAll: TRzLabel;
    ProgressAll: TRzProgressStatus;
    rs: TRSA;
    tmrStart: TTimer;
    xmldSetup: TXMLDocument;
    tmrCheck: TTimer;
    WebBrowser: TWebBrowserWithUI;
    procedure ImageBgMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure BtnMinClick(Sender: TObject);
    procedure BtnCloseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtnSetupClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TreeViewServerCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
      var DefaultDraw: Boolean);
    procedure tmrStartTimer(Sender: TObject);
    procedure TreeViewServerChange(Sender: TObject; Node: TTreeNode);
    procedure TreeViewServerChanging(Sender: TObject; Node: TTreeNode; var AllowChange: Boolean);
    procedure BtnUpdatingClick(Sender: TObject);
    procedure BtnPlayClick(Sender: TObject);
    procedure tmrCheckTimer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure WebBrowserDownloadBegin(Sender: TObject);
    procedure WebBrowserNavigateComplete2(ASender: TObject; const pDisp: IDispatch; var URL: OleVariant);
  private
    FMapHandle: THandle;
    FMapDataInfo: pTMapDataInfo;
    FboLoad: Boolean;
    SelectServerInfo: pTLServerInfo;
    FClientList: array of THandle;
    FboHide: Boolean;
    FCheckIndex: Integer;
    FCheckCount: Integer;
    function CheckIsRun(): THandle;
    procedure CloseMapInfo();
    procedure CreateMapInfo();
    procedure CreateClientSocket(sAddrs: string; wPort: Word; nIndex: Integer);
    function GetCheckIndex: Integer;
  public
    procedure MyRest(var Message: TMessage); message WM_REST;
    procedure ShowHintMsg(sMsg: string);
    procedure ChangePercent(Percent: TPPercent; boAll: Boolean);
    procedure MyException(Sender: TObject; E: Exception);
    procedure MyDisposalXML(var Msg: TMessage); message WM_DISPOSALXML;
    procedure MyChangePercent(var Msg: TMessage); message WM_CHANGEPERCENT;
    procedure MyReadOK(var Msg: TMessage); message WM_MYREAD_OK;
    procedure MySelfChange(var Msg: TMessage); message WM_SELFCHANGE;
    procedure MyCopyDataMessage(var MsgData: TWmCopyData); message WM_COPYDATA;
    procedure MyGetServerList(var Msg: TMessage); message WM_GETSERVERLIST;
    procedure MyCheckClient(var Msg: TMessage); message WM_CHECK_CLIENT;
    procedure ClientSocketConnect(Sender: TObject; Socket: TCustomWinSocket);
    procedure ClientSocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
    procedure ClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
  end;

  //  procedure GetServerListThread(lpParameter: Pointer); stdcall;

var
  FormMain: TFormMain;
  boAllReadOK: Boolean;

implementation

uses FrmSetup, UpThread, ShellAPI, FrmFindClient, Hutil32, FrmRegID;

{$R *.dfm}

procedure TFormMain.BtnMinClick(Sender: TObject);
begin
  SendMessage(Application.Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0);
end;

procedure TFormMain.BtnPlayClick(Sender: TObject);
var
  I, nCount: Integer;
begin
  if SelectServerInfo <> nil then begin
    if FileExists(CLIENTNAME) then begin
      if CheckMirDir(g_SelfPath, True) then begin
        nCount := 0;
        for I := Low(FClientList) to High(FClientList) do begin
          if FClientList[I] = 0 then begin
            Inc(nCount);
          end;
        end;
        if nCount > 0 then begin
          Hide;
          FboHide := True;
          if g_boSQL then WinExec(PChar(CLIENTNAME + ' ' + IntToStr(Handle) + ' 1'), SW_SHOW)
          else WinExec(PChar(CLIENTNAME + ' ' + IntToStr(Handle) + ' 0'), SW_SHOW);

        end else
          Application.MessageBox(PChar('���ֻ��ͬʱ����' + IntToStr(Length(FClientList)) + '����Ϸ�ͻ��ˣ�'),
            '��ʾ��Ϣ', MB_OK + MB_ICONSTOP);
      end else
        Application.MessageBox('ȱ�ٱ�Ҫ�Ĳ����ļ���', '��ʾ��Ϣ', MB_OK + MB_ICONSTOP);
    end else
      Application.MessageBox('������Ϸʧ�ܣ��ͻ����ļ���ʧ��', '��ʾ��Ϣ', MB_OK + MB_ICONSTOP);
  end;
end;

procedure TFormMain.BtnSetupClick(Sender: TObject);
begin
  FormSetup := TFormSetup.Create(Self);
  FormSetup.Open;
  FreeAndNil(FormSetup);
end;

procedure TFormMain.BtnUpdatingClick(Sender: TObject);
begin
  if g_boSQL then begin
    if g_PayUrl <> ''  then begin
      SendMessage(Application.Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0);
      ShellExecute(Handle, 'Open', PChar(g_RegUrl), '', '', SW_SHOW);
    end;
  end else begin
    if SelectServerInfo <> nil then begin
      if SelectServerInfo.boCheck then begin
        FormReg := TFormReg.Create(Owner);
        FormReg.Open(SelectServerInfo.CAddr, SelectServerInfo.CPort);
        FormReg.Free;
        FormReg := nil;
      end else
        Application.MessageBox('������ά���У�', '��ʾ��Ϣ', MB_OK + MB_ICONINFORMATION);
    end else
      Application.MessageBox('����ѡ���������', '��ʾ��Ϣ', MB_OK + MB_ICONINFORMATION);
  end;
    //Application.MessageBox('����ѡ���������', '��ʾ��Ϣ', MB_OK + MB_ICONINFORMATION);

  //
end;

procedure TFormMain.ChangePercent(Percent: TPPercent; boAll: Boolean);
begin
  if boAll then begin
    ProgressAll.Percent := Percent;
    LabelAll.Caption := IntToStr(Percent) + '%';
  end
  else begin
    ProgressNow.Percent := Percent;
    LabelNow.Caption := IntToStr(Percent) + '%';
  end;
end;

function TFormMain.CheckIsRun: THandle;
begin
  Result := 0;
  FMapHandle := OpenFileMapping(FILE_MAP_ALL_ACCESS, False, MAPNAME);
  if FMapHandle = 0 then begin
    CreateMapInfo;
  end
  else begin
    FMapDataInfo := MapViewOfFile(FMapHandle, FILE_MAP_ALL_ACCESS, 0, 0, 0);
    if FMapDataInfo <> nil then begin
      Result := FMapDataInfo.Handle;
    end;
  end;
end;

procedure TFormMain.ClientSocketConnect(Sender: TObject; Socket: TCustomWinSocket);
begin
  if (SelectServerInfo <> nil) and (Socket.nIndex = SelectServerInfo.nIndex) and (not SelectServerInfo.boCheck) then begin
    Socket.SendText('*');
  end else
    Sender.Free;
end;

procedure TFormMain.ClientSocketError(Sender: TObject; Socket: TCustomWinSocket; ErrorEvent: TErrorEvent; var ErrorCode: Integer);
begin
  if (SelectServerInfo <> nil) and (Socket.nIndex = SelectServerInfo.nIndex) and (not SelectServerInfo.boCheck) then begin
    Dec(FCheckCount);
    if FCheckCount <= 0 then begin
      BtnPlay.Enabled := False;
      BtnPlay.Refresh;
      LabelLog.Font.Color := clRed;
      LabelLog.Caption := '����������ά�������Ժ�����...';
    end;
  end;
  ErrorCode:=0;
  Sender.Free;
end;

procedure TFormMain.ClientSocketRead(Sender: TObject; Socket: TCustomWinSocket);
begin
  if (SelectServerInfo <> nil) and (Socket.nIndex = SelectServerInfo.nIndex) and (not SelectServerInfo.boCheck) then begin
    SelectServerInfo.boCheck := True;
    SelectServerInfo.CAddr := Socket.RemoteAddress;
    SelectServerInfo.CPort := Socket.RemotePort;
    BtnPlay.Enabled := True;
    BtnPlay.Refresh;
    LabelLog.Font.Color := clLime;
    LabelLog.Caption := '�������������ţ������Խ�����Ϸ��...';
  end;
  Sender.Free;
end;

procedure TFormMain.CloseMapInfo;
begin
  if FMapDataInfo <> nil then
    UnMapViewOfFile(FMapDataInfo);
  if FMapHandle <> 0 then
    CloseHandle(FMapHandle);
  FMapDataInfo := nil;
  FMapHandle := 0;
end;

procedure TFormMain.CreateClientSocket(sAddrs: string; wPort: Word; nIndex: Integer);
begin
  With TClientSocket.Create(Nil) do begin
    Active := False;
    Socket.nIndex := nIndex;
    ClientType := ctNonBlocking;
    OnConnect := ClientSocketConnect;
    OnError := ClientSocketError;
    OnRead := ClientSocketRead;
    Host := sAddrs;
    Port := wPort;
    Active := True;
  end;
end;

procedure TFormMain.CreateMapInfo;
begin
  FMapHandle := CreateFileMapping($FFFFFFFF, nil, PAGE_READWRITE, 0, SizeOf(TMapDataInfo), MAPNAME);
  FMapDataInfo := MapViewOfFile(FMapHandle, FILE_MAP_ALL_ACCESS, 0, 0, 0);
  if FMapDataInfo <> nil then begin
    FMapDataInfo.Handle := Handle;
  end;
end;

procedure TFormMain.BtnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFormMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  I, nCount: Integer;
begin
  nCount := 0;
  for I := Low(FClientList) to High(FClientList) do begin
    if FClientList[I] <> 0 then begin
      if SendMessage(FClientList[I], WM_CHECK_CLIENT, Handle, MSG_CHECK_CLIENT_TEST) <= 0 then begin
        FClientList[I] := 0;
      end else Inc(nCount);
    end;
  end;
  if (nCount > 0) then begin
    CanClose := False;
    Hide;
    FboHide := True;
  end;
end;

procedure TFormMain.FormCreate(Sender: TObject);
var
  nRunHandle: THandle;
begin
  Application.Title := TITLENAME;
  g_SelfName := ParamStr(0);
  FboHide := False;
  FCheckIndex := 0;
  g_SelfPath := ExtractFilePath(g_SelfName);
  if FileExists(ParamStr(1)) then DeleteFile(PChar(ParamStr(1)));
  //Application.OnMessage := MyMessage;
  //Application.OnException := MyException;
  FboLoad := False;
  boAllReadOK := False;
  FMapHandle := 0;
  FMapDataInfo := nil;
  SelectServerInfo := nil;
  g_DownList := TList.Create;
  ChangePercent(0, False);
  ChangePercent(0, True);
  Width := ImageBg.Picture.Width;
  Height := ImageBg.Picture.Height;
  TransparentColor := True;
  TransparentColorValue := clFuchsia;
  nRunHandle := CheckIsRun;
  SetLength(FClientList, 3);
  FillChar(FClientList[0], Length(FClientList) * SizeOf(FClientList[0]), 0);
  if nRunHandle <> 0 then begin
    SendMessage(nRunHandle, WM_REST, 0, 0);
    Application.Terminate;
  end
  else
  if not CheckMirDir(g_SelfPath, False) then begin
    FormFindClient := TFormFindClient.Create(Self.Owner);
    FormFindClient.ShowModal;
    if sFindDir <> '' then begin
      if CopyFile(PChar(g_SelfName), PChar(sFindDir + ExtractFileName(g_SelfName)), False) then begin
        PostMessage(Handle, WM_CLOSE, 0, 0);
        SetCurrentDir(sFindDir);
        ShellExecute(0, 'open', PChar(sFindDir + ExtractFileName(g_SelfName)), PChar(g_SelfName), nil, SW_SHOW);
        Exit;
      end;
    end;
    FormFindClient.Free;
    Application.Terminate;
  end else
    tmrStart.Enabled := True;
end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  CloseMapInfo;
  g_DownList.Free;
end;

procedure TFormMain.FormShow(Sender: TObject);
begin
  WebBrowser.Width := 401;
  WebBrowser.Height := 211;
  WebBrowser.Left := 18;
  WebBrowser.Top := 143;
end;

function TFormMain.GetCheckIndex: Integer;
begin
  Inc(FCheckIndex);
  Result := FCheckIndex;
end;

procedure TFormMain.ImageBgMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture; //�ͷ����Ĳ���״̬��
  Perform(wm_SysCommand, {sc_DragMove} $F012, 0); //���巢���ƶ���Ϣ
end;

procedure TFormMain.MyChangePercent(var Msg: TMessage);
begin
  ChangePercent(Msg.WParam, Msg.LParam = 1);
end;

procedure TFormMain.MyCheckClient(var Msg: TMessage);
var
  nMsg, nIndex: Integer;
  nHandle: THandle;
begin
  nHandle := Msg.WParam;
  nMsg := LoWord(Msg.LParam);
  nIndex := HiWord(Msg.LParam);
  if (nIndex >= Low(FClientList)) and (nIndex <= High(FClientList)) then begin
    case nMsg of
      MSG_CHECK_CLIENT_TEST: begin
          if (nHandle = FClientList[nIndex]) and (nHandle <> 0) then begin
            Msg.Result := 1;
          end;
        end;
      MSG_CHECK_CLIENT_EXIT: begin
          FClientList[nIndex] := 0;
          tmrCheckTimer(tmrCheck);
        end;
    end;
  end;
end;

procedure TFormMain.MyDisposalXML(var Msg: TMessage);
  function DecryptStr(sStr: string): string;
  begin
    try
      Result := rs.DecryptStr(AnsiReplaceText(sStr, '-', '='));
    except
      Result := '';
    end;
  end;
var
  RootNode, ANode, BNode, CNode, DNode: IXMLNode;
  xmlList, ln, bn, cn: IXMLNodeList;
  i, k, j, n: Integer;
  MasterTreeNode, CTreeNode: TTreeNode;
  sName, sAddrs, sPort, sCheckStr: string;
  //nPort: Integer;
  LServerInfo: pTLServerInfo;
  UpDataInfo: TUpDataInfo;
  pUpDataInfo: PTUpDataInfo;
  boAddDown: Boolean;
begin
  ShowHintMsg('���ڽ����������б���Ϣ�����Ժ�...');
  try
    TreeViewServer.Items.Clear;
    if FileExists(SAVEFILENAME) then begin
      xmldSetup.FileName := SAVEFILENAME;
      try
        xmldSetup.Active := True;
        RootNode := xmldSetup.DocumentElement;
        xmlList := RootNode.ChildNodes;
        ANode := xmlList[XML_SERVER_MASTERNODE];
        if ANode.HasChildNodes then begin
          ln := ANode.ChildNodes;
          for I := 0 to ln.Count - 1 do begin
            BNode := ln[I];
            MasterTreeNode := TreeViewServer.Items.Add(nil, DecryptStr(BNode.GetAttribute(XML_SERVER_NAME)));
            bn := BNode.ChildNodes;
            for k := 0 to bn.Count - 1 do begin
              CNode := bn[k];
              New(LServerInfo);
              FillChar(LServerInfo^, SizeOf(TLServerInfo), #0);
              LServerInfo.sShowName := DecryptStr(CNode.GetAttribute(XML_SERVER_NAME));
              CTreeNode := TreeViewServer.Items.AddChild(MasterTreeNode, LServerInfo.sShowName);
              CTreeNode.Data := LServerInfo;
              cn := CNode.ChildNodes;
              n := 0;
              for j := 0 to cn.Count - 1 do begin
                if n >= 8 then break;
                DNode := cn[j];
                if not VarIsNull(DNode.Text) then begin
                  sName := DecryptStr(DNode.Text);
                  sAddrs := DecryptStr(DNode.GetAttribute(XML_SERVER_NODE_ADDRS));
                  sPort := DecryptStr(DNode.GetAttribute(XML_SERVER_NODE_PORT));
                  //nPort := StrToIntDef(sPort, -1);
                  if (sName <> '') and (sAddrs <> '') {and (nPort > 0) and (nPort < 65535)} then begin
                    LServerInfo.Info[n].sName := sName;
                    LServerInfo.Info[n].sAddrs := sAddrs;
                    LServerInfo.Info[n].sPort := sPort;
                    Inc(n);
                  end;
                end;
              end;
            end;
            MasterTreeNode.Expanded := True;
          end;

          ANode := xmlList[XML_URL_MASTERNODE];

          if not VarIsNull(ANode.ChildValues[XML_URL_LFRAME]) then
            g_LoginframeUrl := DecryptStr(ANode.ChildValues[XML_URL_LFRAME]);
          if not VarIsNull(ANode.ChildValues[XML_URL_CONTACTGM]) then
            g_GMUrl := DecryptStr(ANode.ChildValues[XML_URL_CONTACTGM]);
          if not VarIsNull(ANode.ChildValues[XML_URL_PAYMENT]) then
            g_PayUrl := DecryptStr(ANode.ChildValues[XML_URL_PAYMENT]);
          if not VarIsNull(ANode.ChildValues[XML_URL_REGISTER]) then
            g_RegUrl := DecryptStr(ANode.ChildValues[XML_URL_REGISTER]);
          if not VarIsNull(ANode.ChildValues[XML_URL_CHANGEPASS]) then
            g_ChangePassUrl := DecryptStr(ANode.ChildValues[XML_URL_CHANGEPASS]);
          if not VarIsNull(ANode.ChildValues[XML_URL_LostPASS]) then
            g_LostPassUrl := DecryptStr(ANode.ChildValues[XML_URL_LostPASS]);

          ANode := xmlList[XML_UPDATE_MASTERNODE];
          if ANode.HasChildNodes then begin
            ln := ANode.ChildNodes;
            for I := 0 to ln.Count - 1 do begin
              BNode := ln[I];
              if not VarIsNull(BNode.Text) then begin
                FillChar(UpDataInfo, SizeOf(UpDataInfo), #0);
                boAddDown := False;
                UpDataInfo.sHint := DecryptStr(BNode.Text);
                UpDataInfo.sSaveDir := DecryptStr(BNode.GetAttribute(XML_UPDATE_SAVEDIR));
                UpDataInfo.sFileName := DecryptStr(BNode.GetAttribute(XML_UPDATE_FILENAME));
                UpDataInfo.sDownUrl := DecryptStr(BNode.GetAttribute(XML_UPDATE_DOWNPATH));
                UpDataInfo.boZip := BNode.GetAttribute(XML_UPDATE_ZIP) = XML_ZIP_YES;
                sCheckStr := BNode.GetAttribute(XML_UPDATE_CHECK);
                UpDataInfo.boBaiduDown := BNode.GetAttribute(XML_UPDATE_DOWNTYPE) = XML_DOWNTYPE_BAIDU;
                UpDataInfo.nDate := StrToIntDef(BNode.GetAttribute(XML_UPDATE_DATE), 0);
                UpDataInfo.nVar := StrToIntDef(BNode.GetAttribute(XML_UPDATE_VAR), 0);
                UpDataInfo.sMD5 := BNode.GetAttribute(XML_UPDATE_MD5);
                UpDataInfo.sID := BNode.GetAttribute(XML_UPDATE_ID);
                if sCheckStr <> '' then begin
                  case sCheckStr[1] of
                    XML_CHECK_VAR: begin
                        boAddDown := True;
                        UpDataInfo.CheckType := dct_var;
                      end;
                    XML_CHECK_EXISTS: begin
                        boAddDown := True;
                        UpDataInfo.CheckType := dct_exists;
                      end;
                    XML_CHECK_PACK: begin
                        boAddDown := True;
                        UpDataInfo.CheckType := dct_pack;
                      end;
                    XML_CHECK_MD5: begin
                        boAddDown := True;
                        UpDataInfo.CheckType := dct_md5;
                      end;
                  end;
                  if boAddDown then begin
                    New(pUpDataInfo);
                    pUpDataInfo^ := UpDataInfo;
                    g_DownList.Add(pUpDataInfo);
                  end;
                end;
              end;
            end;
          end;
          if g_LoginframeUrl <> '' then WebBrowser.Navigate(g_LoginframeUrl);
        end;
      finally
        xmldSetup.Active := False;
        BtnUpdating.Enabled := True;
        BtnUpdating.Repaint;
      end;
    end;
  except
  end;
end;

procedure TFormMain.MyException(Sender: TObject; E: Exception);
begin
  //
end;

procedure TFormMain.MyGetServerList(var Msg: TMessage);
var
  nCount, nIndex: SmallInt;
  nHandle: THandle;
  I: Integer;
  SendData: TCopyDataStruct;
begin
  nCount := 0;
  nIndex := -1;
  if (SelectServerInfo <> nil) then begin
    nHandle := Msg.WParam;
    for I := Low(FClientList) to High(FClientList) do begin
      if FClientList[I] = 0 then begin
        FClientList[I] := nHandle;
        nIndex := I;
        break;
      end;
    end;
    if nIndex > -1 then begin
      FillChar(g_ServerInfo, SizeOf(g_ServerInfo), #0);
      for I := Low(SelectServerInfo.Info) to High(SelectServerInfo.Info) do begin
        if SelectServerInfo.Info[I].sName <> '' then begin
          g_ServerInfo[I] := SelectServerInfo.Info[I];
          Inc(nCount);
        end;
      end;
      if nCount > 0 then begin
        SendData.cbData := SizeOf(g_ServerInfo);
        GetMem(SendData.lpData, SendData.cbData);
        Move(g_ServerInfo[0], SendData.lpData^, SendData.cbData);
        SendMessage(nHandle, WM_COPYDATA, COPYMSG_LOGIN_SENDSERVERLIST, Cardinal(@SendData));
        FreeMem(SendData.lpData);
      end;
      g_WebInfo.g_GMUrl := g_GMUrl;
      g_WebInfo.g_PayUrl := g_PayUrl;
      g_WebInfo.g_RegUrl := g_RegUrl;
      g_WebInfo.g_ChangePassUrl := g_ChangePassUrl;
      g_WebInfo.g_LostPassUrl := g_LostPassUrl;
      SendData.cbData := SizeOf(g_WebInfo);
      GetMem(SendData.lpData, SendData.cbData);
      Move(g_WebInfo, SendData.lpData^, SendData.cbData);
      SendMessage(nHandle, WM_COPYDATA, COPYMSG_LOGIN_WEBINFO, Cardinal(@SendData));
      FreeMem(SendData.lpData);
    end;
  end;
  Msg.Result := MakeLong(nCount, nIndex);
end;

procedure TFormMain.MyCopyDataMessage(var MsgData: TWmCopyData);
begin
  case MsgData.From of
    COPYMSG_LOGIN_HINTMSG: ShowHintMsg(StrPas(MsgData.CopyDataStruct^.lpData));
  end;
end;

procedure TFormMain.MyReadOK(var Msg: TMessage);
var
  UpDataInfo: PTUpDataInfo;
begin
  boAllReadOK := True;
  for UpDataInfo in g_DownList do
    Dispose(UpDataInfo);
  g_DownList.Clear;
end;

procedure TFormMain.MyRest(var Message: TMessage);
begin
  Show;
  FboHide := False;
  SendMessage(Application.Handle, WM_SYSCOMMAND, SC_RESTORE, 0);
end;

procedure TFormMain.MySelfChange(var Msg: TMessage);
begin
  if FileExists(g_SelfName + '.bak') then DeleteFile(PChar(g_SelfName + '.bak'));
  RenameFile(g_SelfName, g_SelfName + '.bak');
  CopyFile(PChar(Msg.LParam), PChar(g_SelfName), False);
  PostMessage(Handle, WM_CLOSE, 0, 0);
  ShellExecute(0, 'open', PChar(g_SelfName), PChar(g_SelfName + '.bak'), nil, SW_SHOW);

end;

procedure TFormMain.ShowHintMsg(sMsg: string);
begin
  LabelLog.Caption := sMsg;
end;

procedure TFormMain.tmrCheckTimer(Sender: TObject);
var
  I, nCount: Integer;
begin
  nCount := 0;
  for I := Low(FClientList) to High(FClientList) do begin
    if FClientList[I] <> 0 then begin
      if SendMessage(FClientList[I], WM_CHECK_CLIENT, Handle, MSG_CHECK_CLIENT_TEST) <= 0 then begin
        FClientList[I] := 0;
      end else Inc(nCount);
    end;
  end;
  if (nCount <= 0) and (FboHide) then
    Close;
end;

procedure TFormMain.tmrStartTimer(Sender: TObject);
//var
//  sUrl: string;
begin
  tmrStart.Enabled := False;
  if FboLoad then Exit;
  FboLoad := True;
  CreateShortCut(g_SelfName, TITLENAME);
  CreateDir('.\Resource\');
  {if DirectoryExists('.\Resource\') then begin
    sUrl := 'http://www.mir2k.com/Loginframe/';
  end
  else begin
    CreateDir('.\Resource\');
    sUrl := 'http://www.mir2k.com/Loginframe/?first=1';
  end;  }
  ShowHintMsg('���ڻ�ȡ�������б���Ϣ�����Ժ�...');
  UpdateThread := TUpdateThread.Create(Handle, True);
  UpdateThread.FreeOnTerminate := True;
  UpdateThread.Resume;
  
end;

procedure TFormMain.TreeViewServerChange(Sender: TObject; Node: TTreeNode);
var
  sAddr, sPort, sAddrs, sPorts: string;
  nPort, I, K: Integer;
begin
  if not boAllReadOK then exit;

  if Node.Data <> nil then begin
    SelectServerInfo := pTLServerInfo(Node.Data);
    SelectServerInfo.boCheck := False;
    BtnPlay.Enabled := False;
    BtnPlay.Refresh;
    LabelLog.Font.Color := clYellow;
    LabelLog.Caption := '���ڼ�����������״̬...';
    SelectServerInfo.nIndex := GetCheckIndex;
    FCheckCount := 0;
    for I := Low(SelectServerInfo.Info) to High(SelectServerInfo.Info) do begin
      if SelectServerInfo.Info[I].sAddrs = '' then break;
      sAddrs := SelectServerInfo.Info[I].sAddrs;
      sPorts := SelectServerInfo.Info[I].sPort;
      K := 0;
      while True do begin
        if K > 9 then break;
        sAddrs := GetValidStr3(sAddrs, sAddr, [',']);
        sPorts := GetValidStr3(sPorts, sPort, [',']);
        nPort := StrToIntDef(sPort, -1);
        if (sAddr <> '') and (nPort > 0) and (nPort < 65535) then begin
          Inc(K);
          Inc(FCheckCount);
          CreateClientSocket(sAddr, nPort, SelectServerInfo.nIndex);
        end
        else
          Break;
      end;
    end;
  end
  else begin
    LabelLog.Font.Color := clYellow;
    LabelLog.Caption := '����ѡ�������...';
    SelectServerInfo := nil;
    FormMain.BtnPlay.Enabled := False;
    FormMain.BtnPlay.Refresh;
  end;
end;

procedure TFormMain.TreeViewServerChanging(Sender: TObject; Node: TTreeNode; var AllowChange: Boolean);
begin
  if (not boAllReadOK) then begin
    AllowChange := False;
  end;
end;

procedure TFormMain.TreeViewServerCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  if Node.Level = 0 then begin
    Sender.Canvas.Font.Color := clLime;
  end;
end;

procedure TFormMain.WebBrowserDownloadBegin(Sender: TObject);
begin
  WebBrowser.Silent := True;
end;

procedure TFormMain.WebBrowserNavigateComplete2(ASender: TObject; const pDisp: IDispatch; var URL: OleVariant);
begin
  WebBrowser.Silent := True;
end;

end.

