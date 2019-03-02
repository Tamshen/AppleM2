unit FrmLogin;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TFormLogin = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    EditPassword: TEdit;
    ButtonOK: TBitBtn;
    ButtonExit: TBitBtn;
    EditName: TEdit;
    procedure ButtonExitClick(Sender: TObject);
    procedure ButtonOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure Lock(boLock: Boolean);
  end;

var
  FormLogin: TFormLogin;

implementation

{$R *.dfm}

uses
  Share, EDCode, SCShare, FrmMain;

procedure TFormLogin.ButtonExitClick(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TFormLogin.ButtonOKClick(Sender: TObject);
var
  sName, sPass: string;
  DefMsg: TDefaultMessage;
begin
  sName := Trim(EditName.Text);
  sPass := Trim(EditPassword.Text);
  if sName = '' then begin
    Application.MessageBox('�ʺŲ���Ϊ�գ�', '��ʾ��Ϣ', MB_OK + MB_ICONINFORMATION);
    Exit;
  end;
  if not CheckEMailRule(sName) then begin
    Application.MessageBox('�ʺŸ�ʽ����ȷ��', '��ʾ��Ϣ', MB_OK + MB_ICONINFORMATION);
    Exit;
  end;
  if sPass = '' then begin
    Application.MessageBox('���벻��Ϊ�գ�', '��ʾ��Ϣ', MB_OK + MB_ICONINFORMATION);
    Exit;
  end;
  Lock(True);
  Caption := '������֤�ʻ���Ϣ...';
  DefMsg := MakeDefaultMsg(CM_DOWNLOGIN, 0, 0, 0, 0);
  FormMain.SendSocket(EncodeMessage(DefMsg) + EncodeString(sName + '/' + sPass));
end;

procedure TFormLogin.Lock(boLock: Boolean);
begin
  FormLogin.EditPassword.Enabled := not boLock;
  FormLogin.EditName.Enabled := not boLock;
  FormLogin.ButtonOK.Enabled := not boLock;
end;

end.
