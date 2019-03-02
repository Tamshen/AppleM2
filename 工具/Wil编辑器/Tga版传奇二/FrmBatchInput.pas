unit FrmBatchInput;

interface

uses
  Windows, Messages, SysUtils, StrUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, ComCtrls, StdCtrls, GraphicEx;

type
  TFormBatchInput = class(TForm)
    GroupBox1: TGroupBox;
    rbImageAndXY: TRadioButton;
    rbImage: TRadioButton;
    rbXY: TRadioButton;
    Button1: TButton;
    edtSaveDir: TEdit;
    Label1: TLabel;
    GroupBox2: TGroupBox;
    edtIndexStart: TEdit;
    edtIndexEnd: TEdit;
    Label3: TLabel;
    Label2: TLabel;
    GroupBox3: TGroupBox;
    rbRumpAdd: TRadioButton;
    rbIndexInsert: TRadioButton;
    rbIndexBestrow: TRadioButton;
    GroupBox4: TGroupBox;
    rbXYFile: TRadioButton;
    rbSetXY: TRadioButton;
    edtXY: TEdit;
    btnExit: TButton;
    btnGo: TButton;
    ProgressBar: TProgressBar;
    procedure btnExitClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure rbRumpAddClick(Sender: TObject);
    procedure rbImageAndXYClick(Sender: TObject);
    procedure btnGoClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    procedure GetImageXY(sFileName: string; var X, Y: Integer);
  public
    { Public declarations }
  end;

var
  FormBatchInput: TFormBatchInput;
  XYList: TStringList;
  FIleList: TStringList;

implementation

uses
  Share, FrmMain, Wil, DIB, HUtil32, wmUtil;

{$R *.dfm}

procedure TFormBatchInput.btnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TFormBatchInput.btnGoClick(Sender: TObject);
var
  m_SaveDir, TempStr: string;
  m_SaveXYDir, sX, sY: string;
  StartInt, EndInt: Integer;
  X, Y, II, position, nSize, nextposition: Integer;
  //  ImageInfo: TWMImageInfo;
  lsDIb: TDIB;
  nMaxSize, nNowSize, nLen, nWhiteSize, nLong: Integer;
  pimginfo: TWMImageInfo;
  TargaGraphic: TTargaGraphic;
  //  ni: integer;

  procedure GetXYFileList(SaveDir: string);
  var
    sr: TSearchRec;
    I: Integer;
  begin
    XYList.Clear;
    I := FindFirst(SaveDir + '*.txt', faAnyFile, sr);
    while i = 0 do begin
      if (Sr.Attr and faDirectory) = 0 then begin
        if sr.Name[1] <> '.' then begin
          XYList.Add(SaveDir + sr.Name);
        end;
      end;
      i := FindNext(sr);
    end;
    FindClose(sr);
  end;

  procedure GetImagesFileList(SaveDir: string);
  var
    sr: TSearchRec;
    I: Integer;
  begin
    FIleList.Clear;
    I := FindFirst(SaveDir + '*.tga', faAnyFile, sr);
    while i = 0 do begin
      if (Sr.Attr and faDirectory) = 0 then begin
        if sr.Name[1] <> '.' then begin
          FIleList.Add(SaveDir + sr.Name);
        end;
      end;
      i := FindNext(sr);
    end;
    FindClose(sr);
  end;

  procedure GetImageFileXY(Filename: string; var x, Y: Integer);
  var
    FIdxFile: string;
  begin
    FIdxFile := ExtractFilePath(Filename) + SaveXYDir +
      ExtractFileNameOnly(Filename) +
      '.txt';
    GetImageXY(FIdxFile, x, Y);
  end;
begin
  if not FormMain.WMImages.boInitialize then
    exit;
  if (Trim(edtSaveDir.Text) <> '') or (rbXY.Checked and rbIndexBestrow.Checked
    and rbSetXY.Checked) then begin
    m_SaveDir := Trim(edtSaveDir.Text);
    if RightStr(m_SaveDir, 1) <> '\' then
      m_SaveDir := m_SaveDir + '\';
    m_SaveXYDir := m_SaveDir + SaveXYDir;
    StartInt := StrToIntDef(edtIndexStart.Text, -1);
    EndInt := StrToIntDef(edtIndexEnd.Text, -1);
    TempStr := edtXY.Text;
    TempStr := GetValidStr3(TempStr, sX, [' ', ',']);
    TempStr := GetValidStr3(TempStr, sY, [' ', ',']);
    X := StrToIntDef(sX, 0);
    Y := StrToIntDef(sY, 0);
    if (not rbImageAndXY.Checked) or rbIndexInsert.Checked or
      rbIndexBestrow.Checked then begin
      if (StartInt < 0) then begin
        Application.MessageBox('ͼƬ��ʼ������ô���', '��ʾ��Ϣ',
          MB_OK or MB_ICONASTERISK);
        exit;
      end;
      if (EndInt < 0) then begin
        Application.MessageBox('ͼƬ����������ô���', '��ʾ��Ϣ',
          MB_OK or MB_ICONASTERISK);
        exit;
      end;
      if (EndInt > FormMain.WMImages.ImageCount) then begin
        Application.MessageBox('ͼƬ����������ô��󣬲��ܴ�����ͼƬ����', '��ʾ��Ϣ', MB_OK or
          MB_ICONASTERISK);
        exit;
      end;
      if (not rbIndexInsert.Checked) or rbIndexBestrow.Checked then begin
        if (StartInt > EndInt) then begin
          Application.MessageBox('ͼƬ��ʼ������ô��󣬲��ܴ��ڽ��ٱ��', '��ʾ��Ϣ', MB_OK or
            MB_ICONASTERISK);
          exit;
        end;
      end;
    end;
    if rbXY.Checked and rbIndexBestrow.Checked then begin //д����
      if rbXYFile.Checked then begin
        GetXYFileList(m_SaveDir);
        if (EndInt - StartInt) >= XYList.Count then begin
          Application.MessageBox('�����ļ���������', '��ʾ��Ϣ',
            MB_OK or
            MB_ICONASTERISK);
          exit;
        end;
      end;
      for II := StartInt to EndInt do begin
        if rbXYFile.Checked then begin
          GetImageXY(XYList[II - StartInt], X, Y);
        end;
        FormMain.WMImages.GetImageInfo(II, @pimginfo);
        pimginfo.px := x;
        pimginfo.py := y;
        FormMain.WMImages.SetImageInfo(II, @pimginfo);
        ProgressBar.Position := Trunc((II - StartInt) / (EndInt - StartInt) *
          100);
      end;
    end
    else if rbImageAndXY.Checked and rbRumpAdd.Checked then begin
      GetImagesFileList(m_SaveDir); //ͼƬβ������

      lsDIb := TDIB.Create;
      TargaGraphic := TTargaGraphic.Create;
      try
        for II := 0 to FileList.Count - 1 do begin
          //lsDIb.LoadFromFile(FIleList[II]);
          TargaGraphic.LoadFromFile(FIleList[II]);
          lsDib.Assign(TargaGraphic);
          if rbXYFile.Checked then begin
            GetImageFileXY(FIleList[II], x, y);
          end;
          FormMain.WMImages.AddImages(x, y, lsDib);
          ProgressBar.Position := Trunc(II / (FileList.Count - 1) * 100);
        end;
      finally
        TargaGraphic.Free;
        lsDIb.Free;
      end;
    end
    else if rbImageAndXY.Checked and rbIndexBestrow.Checked then begin
      GetImagesFileList(m_SaveDir); //ͼƬ���긲��
      if (EndInt - StartInt) >= FIleList.Count then begin
        Application.MessageBox('ͼƬ�ļ���������', '��ʾ��Ϣ', MB_OK
          or MB_ICONASTERISK);
        exit;
      end;
      lsDIb := TDIB.Create;
      TargaGraphic := TTargaGraphic.Create;
      try
        nMaxSize := 0;
        for II := StartInt to EndInt do begin
          TargaGraphic.LoadFromFile(FIleList[II - StartInt]);
          lsDib.Assign(TargaGraphic);
          //lsDIb.LoadFromFile(FIleList[II - StartInt]);
          nSize := FormMain.WMImages.GetDibSize(lsDib);
          Inc(nMaxSize, nSize);
        end;
        position := FormMain.WMImages.Getposition(StartInt);
        nextposition := FormMain.WMImages.GetNextposition(EndInt + 1);
        if (position > 0) and (nextposition > 0) and
          (nextposition >= position) then begin
          nNowSize := nextposition - position;
          if nNowSize < nMaxSize then begin
            AppendData(FormMain.WMImages.FileName, nextposition,
              nMaxSize - nNowSize); //����ռ�
          end
          else begin
            nMaxSize := nNowSize;
          end;
          nWhiteSize := 0;
          for II := StartInt to EndInt do begin
            TargaGraphic.LoadFromFile(FIleList[II - StartInt]);
            lsDib.Assign(TargaGraphic);
            //lsDIb.LoadFromFile(FIleList[II - StartInt]);
            if rbXYFile.Checked then begin
              GetImageFileXY(FIleList[II - StartInt], x, y);
            end;
            nSize := FormMain.WMImages.GetDibSize(lsDib);
            if nSize > 0 then begin
              nLen := FormMain.WMImages.ReplaceImages(position + nWhiteSize, ii, x, y,
                lsDib);
              Inc(nWhiteSize, nLen);
            end
            else begin
              FormMain.WMImages.m_IndexList.Items[ii] := nil;
            end;
            ProgressBar.Position := Trunc((II - StartInt) / (EndInt - StartInt)
              * 100);
          end;
          if nWhiteSize < nMaxSize then begin
            RemoveData(FormMain.WMImages.FileName, position + nWhiteSize,
              nMaxSize - nWhiteSize);
          end;
          nNowSize := nWhiteSize - nNowSize;
          FormMain.WMImages.UpdateIndex(EndInt, nNowSize);
          if FormMain.WMImages.Version = 2 then
            FormMain.WMImages.FHeader.IndexOffset :=
              FormMain.WMImages.FHeader.IndexOffset + nNowSize;
        end;
      finally
        TargaGraphic.Free;
        lsDIb.Free;
      end;
    end
    else if rbImageAndXY.Checked and rbIndexInsert.Checked then begin
      GetImagesFileList(m_SaveDir); //ͼƬ�������
      lsDIb := TDIB.Create;
      TargaGraphic := TTargaGraphic.Create;
      try
        nMaxSize := 0;
        for II := 0 to FIleList.Count - 1 do begin
          TargaGraphic.LoadFromFile(FIleList[II]);
          lsDib.Assign(TargaGraphic);
          //lsDIb.LoadFromFile(FIleList[II]);
          nSize := FormMain.WMImages.GetDibSize(lsDib);
          Inc(nMaxSize, nSize);
        end;
        position := FormMain.WMImages.Getposition(StartInt);
        if position > 0 then begin //����ռ�
          AppendData(FormMain.WMImages.FileName, position, nMaxSize);
          nWhiteSize := 0;
          for II := 0 to FIleList.Count - 1 do begin
            TargaGraphic.LoadFromFile(FIleList[II]);
            lsDib.Assign(TargaGraphic);
            //lsDIb.LoadFromFile(FIleList[II]);
            if rbXYFile.Checked then begin
              GetImageFileXY(FIleList[II], x, y);
            end;
            nSize := FormMain.WMImages.GetDibSize(lsDib);
            if nSize > 0 then begin
              FormMain.WMImages.m_IndexList.Insert(StartInt + ii, nil);
              nLen := FormMain.WMImages.ReplaceImages(position + nWhiteSize,
                StartInt + ii, x, y, lsDib);
              Inc(nWhiteSize, nLen);
            end
            else begin
              FormMain.WMImages.m_IndexList.Insert(StartInt + ii, nil);
            end;
            ProgressBar.Position := Trunc((II) / (FIleList.Count - 1) * 100);
          end;
          if nWhiteSize < nMaxSize then begin
            RemoveData(FormMain.WMImages.FileName, position + nWhiteSize,
              nMaxSize - nWhiteSize);
          end;
          FormMain.WMImages.UpdateIndex(StartInt + FIleList.Count - 1,
            nWhiteSize);
          if FormMain.WMImages.Version = 2 then
            FormMain.WMImages.FHeader.IndexOffset :=
              FormMain.WMImages.FHeader.IndexOffset + nWhiteSize;
        end;
      finally
        TargaGraphic.Free;
        lsDIb.Free;
      end;
    end
    else if rbImage.Checked and rbIndexBestrow.Checked then begin
      GetImagesFileList(m_SaveDir); //ͼƬ����
      if (EndInt - StartInt) >= FIleList.Count then begin
        Application.MessageBox('ͼƬ�ļ���������', '��ʾ��Ϣ', MB_OK
          or MB_ICONASTERISK);
        exit;
      end;
      lsDIb := TDIB.Create;
      TargaGraphic := TTargaGraphic.Create;
      try
        nMaxSize := 0;
        for II := StartInt to EndInt do begin
          TargaGraphic.LoadFromFile(FIleList[II - StartInt]);
          lsDib.Assign(TargaGraphic);
          //lsDIb.LoadFromFile(FIleList[II - StartInt]);
          nSize := FormMain.WMImages.GetDibSize(lsDib);
          Inc(nMaxSize, nSize);
          FormMain.WMImages.GetImageInfo(II, @pimginfo);
          FIleList.Objects[II - StartInt] :=
            TObject(MakeLong(pimginfo.px, pimginfo.py));
        end;
        position := FormMain.WMImages.Getposition(StartInt);
        nextposition := FormMain.WMImages.GetNextposition(EndInt + 1);
        if (position > 0) and (nextposition > 0) and
          (nextposition >= position) then begin
          nNowSize := nextposition - position;
          if nNowSize < nMaxSize then begin
            AppendData(FormMain.WMImages.FileName, nextposition,
              nMaxSize - nNowSize); //����ռ�
          end
          else begin
            nMaxSize := nNowSize;
          end;
          nWhiteSize := 0;
          for II := StartInt to EndInt do begin
            TargaGraphic.LoadFromFile(FIleList[II - StartInt]);
            lsDib.Assign(TargaGraphic);
            //lsDIb.LoadFromFile(FIleList[II - StartInt]);
            nLong := Integer(FIleList.Objects[II - StartInt]);
            x := LoWord(nLong);
            y := HiWord(nLong);
            nSize := FormMain.WMImages.GetDibSize(lsDib);
            if nSize > 0 then begin
              nLen := FormMain.WMImages.ReplaceImages(position + nWhiteSize, ii, x, y,
                lsDib);
              Inc(nWhiteSize, nLen);
            end
            else begin
              FormMain.WMImages.m_IndexList.Items[ii] := nil;
            end;
            ProgressBar.Position := Trunc((II - StartInt) / (EndInt - StartInt)
              * 100);
          end;
          if nWhiteSize < nMaxSize then begin
            RemoveData(FormMain.WMImages.FileName, position + nWhiteSize,
              nMaxSize - nWhiteSize);
          end;
          nNowSize := nWhiteSize - nNowSize;
          FormMain.WMImages.UpdateIndex(EndInt, nNowSize);
          if FormMain.WMImages.Version = 2 then
            FormMain.WMImages.FHeader.IndexOffset :=
              FormMain.WMImages.FHeader.IndexOffset + nNowSize;
        end;
      finally
        TargaGraphic.Free;
        lsDIb.Free;
      end;
    end;
    //FormMain.WMImages.m_IndexList.Add(nil);
    FormMain.WMImages.SaveIndex();
    FormMain.DrawGrid.RowCount := FormMain.WMImages.ImageCount div 6 + 1;
    FormMain.DrawGrid.Repaint;
    application.ProcessMessages;
    Application.MessageBox('�����������', '��ʾ��Ϣ', MB_OK or
      MB_ICONASTERISK);
    Close;

  end
  else
    Application.MessageBox('����ѡ��ͼƬ�ļ���λ��', '��ʾ��Ϣ',
      MB_OK or MB_ICONASTERISK);
end;

procedure TFormBatchInput.GetImageXY(sFileName: string; var X, Y: Integer);
var
  StringList: TStringList;
begin
  X := 0;
  Y := 0;
  StringList := TStringList.Create;
  try
    if FileExists(sFileName) then begin
      StringList.LoadFromFile(sFileName);
      if StringList.Count > 0 then
        X := StrToIntDef(StringList[0], 0);
      if StringList.Count > 1 then
        Y := StrToIntDef(StringList[1], 0);
    end;
  finally
    StringList.Free;
  end;
end;

procedure TFormBatchInput.Button1Click(Sender: TObject);
var
  sStr: string;
begin
  sStr := BrowseForFolder(Handle, '��ѡ��ͼƬ�ļ���');
  if sStr <> '' then begin
    edtSaveDir.Text := sStr;
  end;
end;

procedure TFormBatchInput.FormCreate(Sender: TObject);
begin
  XYList := TStringList.Create;
  FIleList := TStringList.Create;
end;

procedure TFormBatchInput.FormDestroy(Sender: TObject);
begin
  XYList.Free;
  FIleList.Free;
end;

procedure TFormBatchInput.rbImageAndXYClick(Sender: TObject);
begin
  if rbImageAndXY.Checked then begin
    rbRumpAdd.Enabled := true;
    rbIndexInsert.Enabled := true;
    rbXYFile.Enabled := True;
    rbSetXY.Enabled := true;
  end
  else if rbImage.Checked then begin
    rbRumpAdd.Enabled := False;
    rbIndexInsert.Enabled := False;
    rbXYFile.Enabled := False;
    rbSetXY.Enabled := False;
    rbIndexBestrow.Checked := True;
  end
  else begin
    rbRumpAdd.Enabled := False;
    rbIndexInsert.Enabled := False;
    rbXYFile.Enabled := True;
    rbSetXY.Enabled := True;
    rbIndexBestrow.Checked := True;
  end;
  rbRumpAddClick(nil);
end;

procedure TFormBatchInput.rbRumpAddClick(Sender: TObject);
begin
  if rbRumpAdd.Checked then begin
    Label2.Enabled := False;
    Label3.Enabled := False;
    edtIndexStart.Enabled := False;
    edtIndexEnd.Enabled := False;
  end
  else if rbIndexInsert.Checked then begin
    Label2.Enabled := True;
    Label3.Enabled := False;
    edtIndexStart.Enabled := True;
    edtIndexEnd.Enabled := False;
  end
  else begin
    Label2.Enabled := True;
    Label3.Enabled := True;
    edtIndexStart.Enabled := True;
    edtIndexEnd.Enabled := True;
  end;
end;

end.

