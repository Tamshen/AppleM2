unit FrmEditServer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Spin;

type
  TFormEditServer = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    EditShowName: TEdit;
    EditName: TEdit;
    Label2: TLabel;
    EditAddr: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    ComboBoxServerGroup: TComboBox;
    ButtonOk: TButton;
    ButtonClose: TButton;
    edtPort: TEdit;
    procedure ButtonOkClick(Sender: TObject);
  private
    { Private declarations }
  public

  end;

var
  FormEditServer: TFormEditServer;

implementation

uses FrmMain;

{$R *.dfm}

procedure TFormEditServer.ButtonOkClick(Sender: TObject);
begin
  if Trim(EditShowName.Text) = '' then begin
    Application.MessageBox('��������ʾ���Ʋ���Ϊ��!', '��ʾ��Ϣ', MB_OK + MB_ICONERROR);
    EditShowName.SetFocus;
  end
  else if Trim(EditName.Text) = '' then begin
    Application.MessageBox('���������Ʋ���Ϊ��!', '��ʾ��Ϣ', MB_OK + MB_ICONERROR);
    EditName.SetFocus;
  end
  else if Trim(EditAddr.Text) = '' then begin
    Application.MessageBox('��������ַ����Ϊ��!', '��ʾ��Ϣ', MB_OK + MB_ICONERROR);
    EditAddr.SetFocus;
  end
  else if ComboBoxServerGroup.ItemIndex = -1 then begin
    Application.MessageBox('��ѡ�����������!', '��ʾ��Ϣ', MB_OK + MB_ICONERROR);
    ComboBoxServerGroup.SetFocus;
  end
  else
    Self.ModalResult := mrOk;
end;

end.

