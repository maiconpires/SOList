program SOList_Example;

uses
  System.StartUpCopy,
  FMX.Forms,
  formSOListExample in 'formSOListExample.pas' {SOListExample},
  SOList in 'SOList.pas',
  framePeople in 'framePeople.pas' {fraPeople: TFrame},
  frameProduct in 'frameProduct.pas' {fraProduct: TFrame},
  frameColor in 'frameColor.pas' {fraColor: TFrame},
  frameForm in 'frameForm.pas' {fraForm: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TSOListExample, SOListExample);
  Application.Run;
end.
