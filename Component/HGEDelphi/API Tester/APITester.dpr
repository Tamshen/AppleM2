program APITester;

uses
  Forms,
  FMain in 'FMain.pas' {FrmMain},
  UTestBase in 'Tests\UTestBase.pas',
  USystem_Log in 'Tests\HGE\System\USystem_Log.pas',
  USyntaxHighlighter in 'USyntaxHighlighter.pas',
  USystem_Launch in 'Tests\HGE\System\USystem_Launch.pas',
  USystem_Snapshot in 'Tests\HGE\System\USystem_Snapshot.pas',
  UResource_Load in 'Tests\HGE\Resource\UResource_Load.pas',
  UResource_Packs in 'Tests\HGE\Resource\UResource_Packs.pas',
  UResource_MakePath in 'Tests\HGE\Resource\UResource_MakePath.pas',
  UResource_Enum in 'Tests\HGE\Resource\UResource_Enum.pas',
  UIni in 'Tests\HGE\Ini\UIni.pas',
  URandom in 'Tests\HGE\Random\URandom.pas',
  UTimer in 'Tests\HGE\Timer\UTimer.pas',
  UEffect in 'Tests\HGE\Effect\UEffect.pas',
  UMusic in 'Tests\HGE\Music\UMusic.pas',
  UStream in 'Tests\HGE\Stream\UStream.pas',
  UChannel in 'Tests\HGE\Channel\UChannel.pas',
  UInput in 'Tests\HGE\Input\UInput.pas',
  UGfx_Line in 'Tests\HGE\Gfx\UGfx_Line.pas',
  UGfx_Triple in 'Tests\HGE\Gfx\UGfx_Triple.pas',
  UGfx_Quad in 'Tests\HGE\Gfx\UGfx_Quad.pas',
  UGfx_Batch in 'Tests\HGE\Gfx\UGfx_Batch.pas',
  UGfx_Clip in 'Tests\HGE\Gfx\UGfx_Clip.pas',
  UGfx_Transform in 'Tests\HGE\Gfx\UGfx_Transform.pas',
  UTarget in 'Tests\HGE\Target\UTarget.pas',
  UTexture in 'Tests\HGE\Texture\UTexture.pas',
  USprite_Render in 'Tests\Sprite\USprite_Render.pas',
  USprite_Texture in 'Tests\Sprite\USprite_Texture.pas',
  USprite_Color in 'Tests\Sprite\USprite_Color.pas',
  USprite_Hotspot in 'Tests\Sprite\USprite_Hotspot.pas',
  USprite_Flip in 'Tests\Sprite\USprite_Flip.pas',
  USprite_BoundingBox in 'Tests\Sprite\USprite_BoundingBox.pas',
  UAnim_Control in 'Tests\Animation\UAnim_Control.pas',
  UFont in 'Tests\Font\UFont.pas',
  UParSys_Params in 'Tests\ParticleSystem\UParSys_Params.pas',
  UParSys_BoundingBox in 'Tests\ParticleSystem\UParSys_BoundingBox.pas',
  UParMan in 'Tests\ParticleManager\UParMan.pas',
  UDistortionMesh in 'Tests\DistortionMesh\UDistortionMesh.pas',
  HGE in '..\Source\HGE.pas',
  HGEAnim in '..\Source\HGEAnim.pas',
  HGEColor in '..\Source\HGEColor.pas',
  HGEDistort in '..\Source\HGEDistort.pas',
  HGEFont in '..\Source\HGEFont.pas',
  HGEGUI in '..\Source\HGEGUI.pas',
  HGEParticle in '..\Source\HGEParticle.pas',
  HGERect in '..\Source\HGERect.pas',
  HGESprite in '..\Source\HGESprite.pas',
  HGEUtils in '..\Source\HGEUtils.pas',
  HGEVector in '..\Source\HGEVector.pas',
  HGEGUICtrls in '..\Source\HGEGUICtrls.pas',
  HGEPhysics in '..\Source\HGEPhysics.pas',
  HGEMatrix in '..\Source\HGEMatrix.pas',
  OpenJpeg in '..\Source\OpenJpeg.pas',
  UGUI_ManageControls in 'Tests\GUI\UGUI_ManageControls.pas',
  UGUIObject_Text in 'Tests\GUIObject\UGUIObject_Text.pas',
  UGUIObject_Button in 'Tests\GUIObject\UGUIObject_Button.pas',
  UGUIObject_Slider in 'Tests\GUIObject\UGUIObject_Slider.pas',
  UGUIObject_Listbox in 'Tests\GUIObject\UGUIObject_Listbox.pas',
  UPhysics_SingleBox in 'Tests\Extensions\Physics\UPhysics_SingleBox.pas',
  UPhysics_Base in 'Tests\Extensions\Physics\UPhysics_Base.pas',
  UPhysics_Pendulum in 'Tests\Extensions\Physics\UPhysics_Pendulum.pas',
  UPhysics_Friction in 'Tests\Extensions\Physics\UPhysics_Friction.pas',
  UPhysics_VerticalStack in 'Tests\Extensions\Physics\UPhysics_VerticalStack.pas',
  UPhysics_Pyramid in 'Tests\Extensions\Physics\UPhysics_Pyramid.pas',
  UPhysics_Teeter in 'Tests\Extensions\Physics\UPhysics_Teeter.pas',
  UPhysics_Bridge in 'Tests\Extensions\Physics\UPhysics_Bridge.pas',
  UPhysics_Dominos in 'Tests\Extensions\Physics\UPhysics_Dominos.pas',
  UPhysics_MultiPendulum in 'Tests\Extensions\Physics\UPhysics_MultiPendulum.pas',
  UJPEG2000_Load in 'Tests\Extensions\JPEG2000\UJPEG2000_Load.pas',
  UAlpha_Load in 'Tests\Extensions\SeparateAlpha\UAlpha_Load.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.Title := 'HGE API Tester';
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
