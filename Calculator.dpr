program Calculator;

uses
  Vcl.Forms,
  UMain in 'UMain.pas' {Calc},
  UCalc in 'UCalc.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TCalc, Calc);
  Application.Run;
end.
