{=====================================================}
{          Developer: Rafael Gustavo Dal Bosco        }
{       2022 - Datapar® - All Rights Reserved ™       }
{=====================================================}
unit Frm.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Menus, Frm.Simulador, MidasLib,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.CategoryButtons,
  Vcl.WinXCtrls, Vcl.Imaging.pngimage;

type

   TFrmMain = class(TForm)
      PnlToolBar: TPanel;
      ImgMenu: TImage;
      lblTitle: TLabel;
      SplitView: TSplitView;
      CategoryButtons: TCategoryButtons;
      procedure Fechar1Click(Sender: TObject);
      procedure ImgMenuClick(Sender: TObject);
      procedure SplitViewClosed(Sender: TObject);
      procedure SplitViewOpened(Sender: TObject);
      procedure SplitViewOpening(Sender: TObject);
      procedure FormClose(Sender: TObject; var Action: TCloseAction);
      procedure CategoryButtonsCategories0Items0Click(Sender: TObject);
      procedure CategoryButtonsCategories0Items1Click(Sender: TObject);
      procedure CategoryButtonsCategories0Items2Click(Sender: TObject);
   protected
      /// <summary>
      ///    Fecha todos os forms da aplicação (menos este)
      /// </summary>
      procedure CloseAllForms;
   private
      /// <summary>
      ///    Seta o tamanho e o caption do CategoryButtons baseado no SplitView
      /// </summary>
      procedure SplitViewOpen;
   end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}


procedure TFrmMain.CategoryButtonsCategories0Items0Click(Sender: TObject);
begin
   FrmSimulador := TFrmSimulador.Create(nil);
   FrmSimulador.Show;
end;

procedure TFrmMain.CategoryButtonsCategories0Items1Click(Sender: TObject);
begin
   CloseAllForms;
end;

procedure TFrmMain.CategoryButtonsCategories0Items2Click(Sender: TObject);
begin
   Close;
end;

procedure TFrmMain.CloseAllForms;
var
   Loop: Integer;
begin
   for Loop := 0 to Screen.FormCount - 1 do
   begin
      if (Screen.Forms[Loop] <> Self) then
         Screen.Forms[Loop].Close;
   end;
end;

procedure TFrmMain.Fechar1Click(Sender: TObject);
begin
   Close;
end;

procedure TFrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   CloseAllForms;
   inherited;
end;

procedure TFrmMain.ImgMenuClick(Sender: TObject);
begin
   if SplitView.Opened then
     SplitView.Close
   else
     SplitView.Open;
end;

procedure TFrmMain.SplitViewClosed(Sender: TObject);
begin
   CategoryButtons.ButtonOptions := CategoryButtons.ButtonOptions - [boShowCaptions];
   if (SplitView.CloseStyle = svcCompact) then
      CategoryButtons.Width := SplitView.CompactWidth;
end;

procedure TFrmMain.SplitViewOpen;
begin
   CategoryButtons.ButtonOptions := CategoryButtons.ButtonOptions + [boShowCaptions];
   CategoryButtons.Width := SplitView.OpenedWidth;
end;

procedure TFrmMain.SplitViewOpened(Sender: TObject);
begin
   SplitViewOpen;
end;

procedure TFrmMain.SplitViewOpening(Sender: TObject);
begin
   SplitViewOpen;
end;

end.
