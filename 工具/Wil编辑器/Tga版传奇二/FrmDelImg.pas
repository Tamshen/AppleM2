unit FrmDelImg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TFormDelImg = class(TForm)
    GroupBox1: TGroupBox;
    edtIndexStart: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    edtIndexEnd: TEdit;
    GroupBox2: TGroupBox;
    rbQuiteDel: TRadioButton;
    RadioButton2: TRadioButton;
    ProgressBar: TProgressBar;
    btnGo: TButton;
    btnExit: TButton;
    procedure btnExitClick(Sender: TObject);
    procedure btnGoClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormDelImg: TFormDelImg;

implementation
uses
  Wil, Share, FrmMain, HUtil32;

{$R *.dfm}

procedure TFormDelImg.btnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TFormDelImg.btnGoClick(Sender: TObject);
var
  StartInt, EndInt: Integer;
  position, positionend, nNowSize: Integer;
  i: Integer;
begin
  if not FormMain.WMImages.boInitialize then
    exit;

  StartInt := StrToIntDef(edtIndexStart.Text, -1);
  EndInt := StrToIntDef(edtIndexEnd.Text, -1);
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
    Application.MessageBox('ͼƬ����������ô��󣬲��ܴ�����ͼƬ����', '��ʾ��Ϣ', MB_OK or MB_ICONASTERISK);
    exit;
  end;
  if (StartInt > EndInt) then begin
    Application.MessageBox('ͼƬ��ʼ������ô��󣬲��ܴ��ڽ�ű��', '��ʾ��Ϣ', MB_OK or MB_ICONASTERISK);
    exit;
  end;
  ProgressBar.Position := 100;
  position := 0;
  with FormMain.WMImages do begin
    for i:=StartInt to EndInt  do begin
      if i >= m_IndexList.Count then Break;
      nNowSize := Integer(m_IndexList.Items[i]);
      if nNowSize <> 0 then begin
        position := nNowSize;
        Break;
      end;
    end;
    positionend := GetNextposition(EndInt + 1);
    for i:= EndInt downto StartInt do begin
      if i >= FormMain.WMImages.m_IndexList.Count then Break;
      if rbQuiteDel.Checked then FormMain.WMImages.m_IndexList.Delete(i)
      else FormMain.WMImages.m_IndexList[i] := nil;
    end;
    if (position > 0) and (positionend > 0) and (positionend >= position)
    then begin
      nNowSize := positionend - position;
      RemoveData(FormMain.WMImages.FileName, position, nNowSize);
      FormMain.WMImages.UpdateIndex(StartInt - 1, -nNowSize);
      if FormMain.WMImages.Version = 2 then
        FormMain.WMImages.FHeader.IndexOffset :=
          FormMain.WMImages.FHeader.IndexOffset - nNowSize;
    end;
    FormMain.WMImages.SaveIndex();
    FormMain.DrawGrid.RowCount := FormMain.WMImages.ImageCount div 6 + 1;
    FormMain.DrawGrid.Repaint;
    FormMain.RefShowLabel(FormMain.DrawGrid.Col, FormMain.DrawGrid.Row * 6);
    Application.MessageBox('ɾ��ͼƬ���', '��ʾ��Ϣ', MB_OK or
      MB_ICONASTERISK);
    Close;
  end;
end;

end.

