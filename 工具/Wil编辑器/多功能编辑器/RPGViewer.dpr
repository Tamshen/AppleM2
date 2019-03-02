program RPGViewer;

uses
  Forms,
  FrmMain in 'FrmMain.pas' {FormMain},
  ZShare in 'ZShare.pas',
  FrmAdd in 'FrmAdd.pas' {FormAdd},
  FrmDel in 'FrmDel.pas' {FormDel},
  FrmOut in 'FrmOut.pas' {FormOut},
  FrmAlpha in 'FrmAlpha.pas' {FormAlpha},
  MyCommon in '..\..\..\MyCommon\MyCommon.pas',
  HUtil32 in '..\..\..\Common\HUtil32.pas',
  Bass in '..\..\..\MirClient\Bass.pas',
  DLLFile in '..\..\..\MirClient\DLLFile.pas',
  wmMyImage in '..\..\..\�ؼ�\WIL\wmMyImage.pas',
  WIL in '..\..\..\�ؼ�\WIL\WIL.pas',
  wmM2Def in '..\..\..\�ؼ�\WIL\wmM2Def.pas',
  wmM2Zip in '..\..\..\�ؼ�\WIL\wmM2Zip.pas',
  wmM3Zip in '..\..\..\�ؼ�\WIL\wmM3Zip.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TFormAdd, FormAdd);
  Application.CreateForm(TFormDel, FormDel);
  Application.CreateForm(TFormOut, FormOut);
  Application.CreateForm(TFormAlpha, FormAlpha);
  Application.Run;
end.
