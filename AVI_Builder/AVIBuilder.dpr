program AVIBuilder;

uses
  Forms,
  AniTool in 'AniTool.pas' {AniToolForm},
  VFW in 'vfw.pas',
  DIBitmap in 'DIBitmap.pas',
  IUnk in 'IUnk.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TAniToolForm, AniToolForm);
  Application.Run;
end.
