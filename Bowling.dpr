program Bowling;

uses
  Vcl.Forms,
  BowlingGameUI in 'BowlingGameUI.pas' {Form1},
  BowlingGame in 'BowlingGame.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
