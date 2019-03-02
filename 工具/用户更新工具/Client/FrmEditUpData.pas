unit FrmEditUpData;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, ShellAPI, MD5Unit, 
  Dialogs, BusinessSkinForm, bsSkinData, bsSkinCtrls, bsSkinBoxCtrls, StdCtrls, Mask;

type
  TFormEditUpData = class(TForm)
    DForm: TbsBusinessSkinForm;
    DSkinData: TbsSkinData;
    bsSkinGroupBox1: TbsSkinGroupBox;
    bsSkinStdLabel10: TbsSkinStdLabel;
    bsSkinStdLabel1: TbsSkinStdLabel;
    bsSkinStdLabel2: TbsSkinStdLabel;
    bsSkinStdLabel3: TbsSkinStdLabel;
    bsSkinStdLabel4: TbsSkinStdLabel;
    edtHint: TbsSkinEdit;
    EditDownUrl: TbsSkinEdit;
    EditSaveDir: TbsSkinEdit;
    edtdownmd5: TbsSkinEdit;
    cbbCheckType: TbsSkinComboBox;
    ButtonOk: TbsSkinButton;
    ButtonClose: TbsSkinButton;
    ComboBoxZip: TbsSkinComboBox;
    bsSkinStdLabel5: TbsSkinStdLabel;
    cbbDownType: TbsSkinComboBox;
    bsSkinStdLabel6: TbsSkinStdLabel;
    EditSaveName: TbsSkinEdit;
    Label1: TbsSkinStdLabel;
    EditVer: TbsSkinEdit;
    edtDate: TbsSkinEdit;
    edtMD5: TbsSkinEdit;
    GroupBoxMD5: TbsSkinGroupBox;
    bsSkinStdLabel7: TbsSkinStdLabel;
    bsSkinStdLabel8: TbsSkinStdLabel;
    bsSkinEdit3: TbsSkinEdit;
    bsSkinEdit4: TbsSkinEdit;
    procedure cbbCheckTypeChange(Sender: TObject);
    procedure ButtonOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure bsSkinEdit3Change(Sender: TObject);
  private
    procedure WMDropFiles(var Msg: TMsg);
  public
    function Open(): Integer;
    procedure MainOnMessage(var Msg: TMsg; var Handled: Boolean);
    procedure ShowProgress(aPercent: Integer);
  end;

var
  FormEditUpData: TFormEditUpData;

implementation

{$R *.dfm}

uses
  FrmMain;

procedure TFormEditUpData.bsSkinEdit3Change(Sender: TObject);
begin
  if FileExists(bsSkinEdit3.Text) then begin
    FormMain.ShowHint('���ڼ���...');
    bsSkinEdit4.Text := '';
    bsSkinEdit4.Text := MD5Print(GetMD5OfFile(bsSkinEdit3.Text, ShowProgress));
    FormMain.ShowHint('�������...');
  end;
end;

procedure TFormEditUpData.ButtonOkClick(Sender: TObject);
begin
  if Trim(edtHint.Text) = '' then begin
    FormMain.DMsg.MessageDlg('������ʾ����Ϊ�գ�', mtError, [mbYes], 0);
    edtHint.SetFocus;
  end
  else if Trim(EditDownUrl.Text) = '' then begin
    FormMain.DMsg.MessageDlg('���ز���Ϊ�գ�', mtError, [mbYes], 0);
    EditDownUrl.SetFocus;
  end
  else if Trim(EditSaveDir.Text) = '' then begin
    FormMain.DMsg.MessageDlg('����λ�ò���Ϊ�գ�', mtError, [mbYes], 0);
    EditSaveDir.SetFocus;
  end
  else if Trim(EditSaveName.Text) = '' then begin
    FormMain.DMsg.MessageDlg('�����ļ�������Ϊ�գ�', mtError, [mbYes], 0);
    EditSaveName.SetFocus;
  end
  else
    Self.ModalResult := mrOk;
end;

procedure TFormEditUpData.cbbCheckTypeChange(Sender: TObject);
begin
  EditVer.Visible := False;
  edtDate.Visible := False;
  Label1.Visible := False;
  edtmd5.Visible := False;
  if cbbCheckType.ItemIndex = 0 then begin
    Label1.Visible := True;
    Label1.Caption := '�汾��:';
    EditVer.Visible := True;
  end
  else if cbbCheckType.ItemIndex = 2 then begin
    Label1.Visible := True;
    Label1.Caption := 'PAK����ʱ��:';
    edtDate.Visible := True;
    edtDate.Top := 105;
    edtDate.Left := 245;
  end
  else if cbbCheckType.ItemIndex = 3 then begin
    Label1.Visible := True;
    Label1.Caption := '�ļ�MD5ֵ:';
    edtmd5.Visible := True;
    edtmd5.Top := 105;
    edtmd5.Left := 245;
  end;
end;

procedure TFormEditUpData.FormCreate(Sender: TObject);
begin
  DSkinData.SkinList := FormMain.CompressedSkinList;
  Application.OnMessage := MainOnMessage;
end;

procedure TFormEditUpData.MainOnMessage(var Msg: TMsg; var Handled: Boolean);
begin
  if Msg.message = WM_DROPFILES then begin
    WMDropFiles(Msg);
  end;
end;

function TFormEditUpData.Open: Integer;
begin
  ClientHeight := 302;
  ClientWidth := 474;
  Result := ShowModal;
end;

procedure TFormEditUpData.ShowProgress(aPercent: Integer);
begin
  FormMain.ShowProgress(aPercent);
end;

procedure TFormEditUpData.WMDropFiles(var Msg: TMsg);
var
  AFileName: array[0..MAX_PATH] of Char;
  Drop: THandle;
begin
  Drop := Msg.wParam;
  if DragQueryFile(Drop, 0, AFileName, MAX_PATH) > 0 then begin
    if Msg.hwnd = GroupBoxMD5.Handle then begin
      if FileExists(AFileName) then
        bsSkinEdit3.Text := AFileName;
    end;
  end;
end;

end.

