program DataPar;

uses
  Vcl.Forms,
  App.Utils in '..\Source\Units\Utils\App.Utils.pas',
  App.Utils.Component.Border in '..\Source\Units\Utils\App.Utils.Component.Border.pas',
  App.Financiamento.Objects in '..\Source\Units\Classes\App.Financiamento.Objects.pas',
  App.Financiamento.Controller in '..\Source\Units\Classes\App.Financiamento.Controller.pas',
  Frm.Main in '..\Source\Forms\Frm.Main.pas' {FrmMain},
  Frm.Simulador in '..\Source\Forms\Frm.Simulador.pas' {FrmSimulador};

{$R *.res}

begin
   {$IFDEF DEBUG}
   ReportMemoryLeaksOnShutdown := True;
   {$ENDIF}

   Application.Initialize;
   Application.MainFormOnTaskbar := True;
   Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
