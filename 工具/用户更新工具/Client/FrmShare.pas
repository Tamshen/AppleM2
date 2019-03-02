unit FrmShare;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, bsSkinData, bsSkinCtrls, ComCtrls, bsSkinTabs, StdCtrls, Mask, bsSkinBoxCtrls;

type
  pTShareDataInfo = ^TShareDataInfo;
  TShareDataInfo = packed record
    nID: Integer;
    sFileName: string[255];
    nFileSize: Integer;
    dwFileTime: TDateTime;
    sUserName: string[30];
  end;

  TShareList = record
    AdminList: TList;
    UserList: TList;
  end;

  TShareLists = array[0..2] of TShareList;

  TFrameShare = class(TFrame)
    GroupBoxBg: TbsSkinGroupBox;
    DSkinData: TbsSkinData;
    DBPageControl: TbsSkinPageControl;
    bsSkinTabSheet1: TbsSkinTabSheet;
    ListViewAdmin: TbsSkinListView;
    ScrollBarStditemsRight: TbsSkinScrollBar;
    ScrollBarStdItemsBottom: TbsSkinScrollBar;
    bsSkinTabSheet2: TbsSkinTabSheet;
    ListViewUser: TbsSkinListView;
    ScrollBarMagicRight: TbsSkinScrollBar;
    ScrollBarMagicBottom: TbsSkinScrollBar;
    bsSkinGroupBox3: TbsSkinGroupBox;
    ButtonSave: TbsSkinButton;
    FileName: TbsSkinEdit;
    bsSkinStdLabel2: TbsSkinStdLabel;
    ButtonDownFile: TbsSkinButton;
    procedure FileNameButtonClick(Sender: TObject);
    procedure FileNameChange(Sender: TObject);
    procedure ButtonSaveClick(Sender: TObject);
    procedure ButtonDownFileClick(Sender: TObject);
    procedure ListViewAdminSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
  private
    procedure RefShowFileList();
  public
    FOpenIndex: Integer;
    FShareLists: TShareLists;
    FSaveFileName: string;
    procedure Open(nIndex: Integer);
    procedure Close();
    procedure Init();
    procedure UnInit();
    procedure SendGetList();
    procedure GetFileList(nOpenIndex: Integer; boAdmin: Boolean; sData: string);
    procedure GetFileData(nDataSize, nFileSize, nOK: Integer; sData: string);
  end;

implementation

uses
  FrmMain, FShare, SCShare, EDCode, MD5Unit, Hutil32;

{$R *.dfm}

{ TFrameShare }

procedure TFrameShare.ButtonDownFileClick(Sender: TObject);
var
  Item: TListItem;
  ShareDataInfo: pTShareDataInfo;
  DefMsg: TDefaultMessage;
begin
  if not g_boToolConnect then begin
    FormMain.DMsg.MessageDlg('�빲����������ӶϿ��У������������ӣ����Ժ�..��', mtError, [mbYes], 0);
    Exit;
  end;
  if DBPageControl.TabIndex = 0 then begin
    Item := ListViewAdmin.Selected;
  end else begin
    Item := ListViewUser.Selected;
  end;
  if (Item <> nil) then begin
    ShareDataInfo := pTShareDataInfo(Item.SubItems.Objects[0]);
    if ShareDataInfo <> nil then begin
      FormMain.SaveDialog.FileName := ShareDataInfo.sFileName;
      if FormMain.SaveDialog.Execute then begin
        FSaveFileName := FormMain.SaveDialog.FileName;
        if FileExists(FSaveFileName) then begin
          if FormMain.DMsg.MessageDlg('���ļ��Ѿ����ڣ��Ƿ��滻���ļ���', mtConfirmation, [mbYes, mbNo], 0) <> mrYes then begin
            Exit;
          end;
          if not DeleteFile(FSaveFileName) then begin
            FormMain.DMsg.MessageDlg('�滻�ļ�ʧ�ܣ�������ѡ�񱣴�λ��..��', mtError, [mbYes], 0);
            Exit;
          end;
        end;
        FileClose(FileCreate(FSaveFileName, fmCreate));
        DefMsg := MakeDefaultMsg(CM_SHARE_DOWNFILE, ShareDataInfo.nID, 0, 0, 0);
        FormMain.SendToolSocket(EncodeMessage(DefMsg));
        FormMain.Lock(True);
        GroupBoxBg.Enabled := False;
        FormMain.ShowHint('����׼������[' + ShareDataInfo.sFileName + ']...');
      end;
    end else
      FormMain.DMsg.MessageDlg('���ص��ļ���Ϣ�Ѿ���..��', mtError, [mbYes], 0);
  end else
    FormMain.DMsg.MessageDlg('����ѡ��Ҫ���ص��ļ�..��', mtError, [mbYes], 0);
end;

procedure TFrameShare.ButtonSaveClick(Sender: TObject);
var
  sFileName, sExt, sFileName2, sFileMD5: string;
  FileHandle: THandle;
  nFileSize: Integer;
  nWriteSize, nDefSize, nParSize: Integer;
  FileBuffer: PChar;
  DefMsg: TDefaultMessage;
begin
  if not g_boConnect then begin
    FormMain.DMsg.MessageDlg('��Զ�̷��������ӶϿ��У������������ӣ����Ժ�..��', mtError, [mbYes], 0);
    Exit;
  end;
  if not g_boToolConnect then begin
    FormMain.DMsg.MessageDlg('�빲����������ӶϿ��У������������ӣ����Ժ�..��', mtError, [mbYes], 0);
    Exit;
  end;
  sFileName := Trim(FileName.Text);
  sFileName2 := ExtractFileName(sFileName);
  sExt := ExtractFileExt(sFileName);
  if not FileExists(sFileName) then begin
    FormMain.DMsg.MessageDlg('����ѡ��Ҫ�ϴ����ļ�..��', mtError, [mbYes], 0);
    Exit;
  end;
  if (CompareText(sExt, '.txt') = 0) or (CompareText(sExt, '.rar') = 0) then begin
    FileHandle := FileOpen(sFilename, fmOpenRead or fmShareDenyWrite);
    if FileHandle > 0 then begin
      Try
        nFileSize := FileSeek(FileHandle, 0, 2);
        if nFileSize <= 1 then begin
          FormMain.DMsg.MessageDlg('�������ϴ����ļ�..��', mtError, [mbYes], 0);
          Exit;
        end;
        if nFileSize <= MAX_UPFILESIZE then begin
          sFileMD5 := FileToMD5Text(sFilename);
          GetMem(FileBuffer, nFileSize);
          Try
            FileSeek(FileHandle, 0, 0);
            if FileRead(FileHandle, FileBuffer^, nFileSize) = nFileSize then begin
              FormMain.Lock(True);
              GroupBoxBg.Enabled := False;
              Try
                FormMain.ShowHint('�����ϴ��ļ�[' + sFileName2 + ']������� ' + IntToStr(0) + '%...');
                FormMain.ShowProgress(0);
                DefMsg := MakeDefaultMsg(CM_SHARE_UPFILE, nFileSize, FOpenIndex, 0, 0);
                if not FormMain.SendToolSocket(EncodeMessage(DefMsg) + EncodeString(sFileName2)) then begin
                  FormMain.DMsg.MessageDlg('�ϴ��ļ�ʧ��..��', mtError, [mbYes], 0);
                  Exit;
                end;
                nWriteSize := 0;

                while nWriteSize < nFileSize do begin
                  nDefSize := 6000;
                  if (nDefSize + nWriteSize) > nFileSize then
                    nDefSize := nFileSize - nWriteSize;
                  DefMsg := MakeDefaultMsg(CM_SHARE_UPFILE, nFileSize, LoWord(nWriteSize), HiWord(nWriteSize), nDefSize);
                  if not FormMain.SendToolSocket(EncodeMessage(DefMsg) + EncodeBuffer(@FileBuffer[nWriteSize], nDefSize)) then begin
                    FormMain.DMsg.MessageDlg('�ϴ��ļ�ʧ��..��', mtError, [mbYes], 0);
                    Exit;
                  end;
                  Inc(nWriteSize, nDefSize);
                  nParSize := Round(nWriteSize / nFileSize * 100);
                  FormMain.ShowHint('�����ϴ��ļ�[' + sFileName2 + ']������� ' + IntToStr(nParSize) + '%...');
                  FormMain.ShowProgress(nParSize);
                end;

                DefMsg := MakeDefaultMsg(CM_SHARE_UPFILE, -1, 0, 0, 0);
                if not FormMain.SendToolSocket(EncodeMessage(DefMsg) + EncodeString(sFileMD5)) then begin
                  FormMain.DMsg.MessageDlg('�ϴ��ļ�ʧ��..��', mtError, [mbYes], 0);
                  Exit;
                end;
                FileName.Text := '';
                FormMain.ShowHint('����Ч���ϴ��ļ�...');
              Finally
                GroupBoxBg.Enabled := True;
                FormMain.Lock(False);
              End;
            end else
              FormMain.DMsg.MessageDlg('��ȡ�ļ�����ʧ��..��', mtError, [mbYes], 0);
          Finally
            FreeMem(FileBuffer, nFileSize);
          End;
        end else
          FormMain.DMsg.MessageDlg('�ļ���С�������ƣ����ֻ�����ϴ�(' + IntToStr(MAX_UPFILESIZE div 1024 div 1024) + ' MB)..��', mtError, [mbYes], 0);
      Finally
        FileClose(FileHandle);
      End;
    end else
      FormMain.DMsg.MessageDlg('��Ҫ�ϴ����ļ�ʧ��..��', mtError, [mbYes], 0);
  end else
    FormMain.DMsg.MessageDlg('ֻ�����ϴ�TXT(�ı��ĵ�)��RAR(ѹ����ʽ)���ļ�..��', mtError, [mbYes], 0);
end;

procedure TFrameShare.Close;
begin
  //
end;

procedure TFrameShare.FileNameButtonClick(Sender: TObject);
begin
  FormMain.OpenDialog.Filter := '���п����ϴ����ļ� (*.txt;*.rar)|*.txt;*.rar|�ı��ĵ� (*.txt)|*.txt|ѹ���ļ� (*.rar)|*.rar';
  if FormMain.OpenDialog.Execute then begin
    FileName.Text := FormMain.OpenDialog.FileName;
  end;
end;

procedure TFrameShare.FileNameChange(Sender: TObject);
begin
  ButtonSave.Enabled := FileExists(FileName.Text);
end;

procedure TFrameShare.GetFileData(nDataSize, nFileSize, nOK: Integer; sData: string);
var
  FileHandle: THandle;
  DataBuffer: PChar;
  nParSize, nWriteSize: Integer;
begin
  if FileExists(FSaveFileName) then begin
    Filehandle := FileOpen(FSaveFileName, fmOpenWrite or fmShareDenyWrite);
    GetMem(DataBuffer, nDataSize);
    Try
      if FileHandle > 0 then begin
        DecodeBuffer(sData, DataBuffer, nDataSize);
        nWriteSize := FileSeek(FileHandle, 0, 2);
        FileWrite(FileHandle, DataBuffer^, nDataSize);
        Inc(nWriteSize, nDataSize);
        nParSize := Round(nWriteSize / nFileSize * 100);
        FormMain.ShowHint('���������ļ�[' + ExtractFileName(FSaveFileName) + ']������� ' + IntToStr(nParSize) + '%...');
        FormMain.ShowProgress(nParSize);
      end;
    Finally
      FreeMem(DataBuffer, nDataSize);
      FileClose(FileHandle);
    End;
    if nOK = 1 then begin
      FormMain.Lock(False);
      GroupBoxBg.Enabled := True;
      FormMain.ShowHint('[' + ExtractFileName(FSaveFileName) + '] ���������...');
    end;
  end; 
end;

procedure TFrameShare.GetFileList(nOpenIndex: Integer; boAdmin: Boolean; sData: string);
var
  sStr, sID, sFileSize, sFileName, sFileTime, sUpName: string;
  ShareDataInfo: pTShareDataInfo;
begin
  while True do begin
    if sData = '' then break;
    sData := GetValidStr3(sData, sStr, ['/']);
    if sStr = '' then break;
    sStr := DecodeString(sStr);
    sStr := GetValidStr3(sStr, sID, ['/']);
    sStr := GetValidStr3(sStr, sFileSize, ['/']);
    sStr := GetValidStr3(sStr, sFileName, ['/']);
    sStr := GetValidStr3(sStr, sFileTime, ['/']);
    sStr := GetValidStr3(sStr, sUpName, ['/']);
    New(ShareDataInfo);
    ShareDataInfo.nID := StrToIntDef(sID, -1);
    ShareDataInfo.nFileSize := StrToIntDef(sFileSize, 0);
    ShareDataInfo.sFileName := sFileName;
    ShareDataInfo.dwFileTime := StrToDateTimeDef(sFileTime, Now);
    ShareDataInfo.sUserName := sUpName;
    if boAdmin then FShareLists[nOpenIndex].AdminList.Add(ShareDataInfo)
    else FShareLists[nOpenIndex].UserList.Add(ShareDataInfo);
  end;
  RefShowFileList;
end;

procedure TFrameShare.Init;
var
  I: Integer;
begin
  for I := Low(FShareLists) to High(FShareLists) do begin
    FShareLists[I].AdminList := TList.Create;
    FShareLists[I].UserList := TList.Create;
  end;
end;

procedure TFrameShare.ListViewAdminSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  //
end;

procedure TFrameShare.Open(nIndex: Integer);
begin
  case nIndex of
    0: begin
        GroupBoxBg.Caption := '����ר�� - �ű�����';
      end;
    1: begin
        GroupBoxBg.Caption := '����ר�� - ���߹���';
      end;
    2: begin
        GroupBoxBg.Caption := '����ר�� - ��������';
      end;
    else begin
      GroupBoxBg.Caption := '����ר�� - �ű�����';
      nIndex := 0;
    end;
  end;
  if FOpenIndex <> nIndex then begin
    FOpenIndex := nIndex;
    ListViewUser.Items.Clear;
    ListViewAdmin.Items.Clear;
  end;
  if not g_boToolConnect then begin
    FormMain.DMsg.MessageDlg('�빲����������ӶϿ��У������������ӣ���ʱ�޷�ˢ���ļ��б�..��', mtError, [mbYes], 0);
    FormMain.ShowHint('�빲����������ӶϿ��У������������ӣ���ʱ�޷�ˢ���ļ��б�...');
  end else
    SendGetList();
  RefShowFileList;
end;

procedure TFrameShare.RefShowFileList;
  function FormatValue(nValue: Integer): string;
  begin
    if nValue > 1024 * 800 then begin
      Result := Format('%.2f', [nValue / 1024 / 1024]) + ' M';
    end else
    if nValue > 800 then begin
      Result := Format('%.2f', [nValue / 1024]) + ' KB';
    end else begin
      Result := IntToStr(nValue) + ' B';
    end;
  end;

  function FormatUserName(sValue: string): string;
  var
    sExt: string;
  begin
    sValue := GetValidStr3(sValue, sExt, ['@']);
    Result := Copy(sExt, 1, Length(sExt) - 3) + '***@' + sValue;
  end;
var
  ShareDataInfo: pTShareDataInfo;
  Item: TListItem;
  I: Integer;
begin
  ListViewUser.Items.Clear;
  ListViewAdmin.Items.Clear;
  for I := FShareLists[FOpenIndex].AdminList.Count - 1 downto 0 do begin
    ShareDataInfo := FShareLists[FOpenIndex].AdminList[I];
    Item := ListViewAdmin.Items.Add;
    Item.Caption := ShareDataInfo.sFileName;
    if CompareText(ExtractFileExt(ShareDataInfo.sFileName), '.txt') = 0 then Item.ImageIndex := 14
    else Item.ImageIndex := 15;
    Item.SubItems.AddObject(FormatValue(ShareDataInfo.nFileSize), TObject(ShareDataInfo));
    Item.SubItems.Add(FormatDateTime('YYYY-MM-DD HH:MM', ShareDataInfo.dwFileTime));
  end;
  for I := FShareLists[FOpenIndex].UserList.Count - 1 downto 0 do begin
    ShareDataInfo := FShareLists[FOpenIndex].UserList[I];
    Item := ListViewUser.Items.Add;
    Item.Caption := ShareDataInfo.sFileName;
    if CompareText(ExtractFileExt(ShareDataInfo.sFileName), '.txt') = 0 then Item.ImageIndex := 14
    else Item.ImageIndex := 15;
    Item.SubItems.AddObject(FormatValue(ShareDataInfo.nFileSize), TObject(ShareDataInfo));
    Item.SubItems.Add(FormatDateTime('YYYY-MM-DD HH:MM', ShareDataInfo.dwFileTime));
    Item.SubItems.Add(FormatUserName(ShareDataInfo.sUserName));
  end;
end;

procedure TFrameShare.SendGetList();
var
  nAdminIndex, nUserIndex: Integer;
  DefMsg: TDefaultMessage;
begin
  if g_boToolConnect and (FOpenIndex in [Low(FShareLists)..High(FShareLists)]) then begin
    if FShareLists[FOpenIndex].AdminList.Count > 0 then begin
      nAdminIndex := pTShareDataInfo(FShareLists[FOpenIndex].AdminList[FShareLists[FOpenIndex].AdminList.Count - 1]).nID;
    end else
      nAdminIndex := 0;
    if FShareLists[FOpenIndex].UserList.Count > 0 then begin
      nUserIndex := pTShareDataInfo(FShareLists[FOpenIndex].UserList[FShareLists[FOpenIndex].UserList.Count - 1]).nID;
    end else
      nUserIndex := 0;

    DefMsg := MakeDefaultMsg(CM_SHARE_GETLIST, nAdminIndex, LoWord(nUserIndex), HiWord(nUserIndex), FOpenIndex);
    FormMain.SendToolSocket(EncodeMessage(DefMsg));
  end;
end;

procedure TFrameShare.UnInit;
var
  I, k: Integer;
begin
  for I := Low(FShareLists) to High(FShareLists) do begin
    for K := 0 to FShareLists[I].AdminList.Count - 1 do
      Dispose(pTShareDataInfo(FShareLists[I].AdminList[k]));
    for K := 0 to FShareLists[I].UserList.Count - 1 do
      Dispose(pTShareDataInfo(FShareLists[I].UserList[k]));
    FShareLists[I].AdminList.Free;
    FShareLists[I].UserList.Free;
  end;
end;

end.
