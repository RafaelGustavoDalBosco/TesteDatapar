{=====================================================}
{          Developer: Rafael Gustavo Dal Bosco        }
{       2022 - Datapar® - All Rights Reserved ™       }
{=====================================================}
unit Frm.Simulador;

interface

uses

{$REGION '| SYSTEM |'}
   Winapi.Windows,
   Winapi.Messages,
   System.SysUtils,
   System.Classes,
   System.Variants,
   ComObj,
   XMLDoc,
   XMLIntf,
{$ENDREGION}

{$REGION '| VCL |'}
   Vcl.Controls,
   Vcl.Forms,
   Vcl.Dialogs,
   Vcl.Buttons,
   Vcl.ExtCtrls,
   Vcl.StdCtrls,
   Vcl.Grids,
   Vcl.DBGrids,
{$ENDREGION}

{$REGION '| DATA |'}
   Data.DB,
   DataSnap.DBClient,
   Web.DBWeb,
   Web.HTTPProd,
{$ENDREGION}

{$REGION '| APP |'}
   App.Utils,
   App.Financiamento.Controller,
   App.Financiamento.Objects;
{$ENDREGION}

type

   TFrmSimulador = class(TForm)
      PnlMain: TPanel;
      PnlBottom: TPanel;
      PnlUpper: TPanel;
      PnlTop: TPanel;
      GrbMeses: TGroupBox;
      GrbCapital: TGroupBox;
      GrbTaxaJuros: TGroupBox;
      GrbGrid: TGroupBox;
      GrbExport: TGroupBox;
      GridSimulator: TDBGrid;
      BtClose: TSpeedButton;
      BtMinimize: TSpeedButton;
      BtExportHTML: TSpeedButton;
      BtExportCSV: TSpeedButton;
      BtExportXML: TSpeedButton;
      BtSimular: TButton;
      BtFechar: TButton;
      EdtCapital: TEdit;
      EdtTaxaJuros: TEdit;
      EdtMeses: TEdit;
      procedure EdtCapitalKeyPress(Sender: TObject; var Key: Char);
      procedure EdtTaxaJurosKeyPress(Sender: TObject; var Key: Char);
      procedure EdtCapitalExit(Sender: TObject);
      procedure EdtTaxaJurosExit(Sender: TObject);
      procedure BtSimularClick(Sender: TObject);
      procedure BtCloseClick(Sender: TObject);
      procedure BtMinimizeClick(Sender: TObject);
      procedure BtFecharClick(Sender: TObject);
      procedure FormClose(Sender: TObject; var Action: TCloseAction);
      procedure FormKeyPress(Sender: TObject; var Key: Char);
      procedure PnlUpperMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
      procedure BtExportXMLClick(Sender: TObject);
      procedure BtExportCSVClick(Sender: TObject);
      procedure BtExportHTMLClick(Sender: TObject);
   private
      FMeses: Integer;
      FTaxaJuros: Currency;
      FCapital: Currency;
      FClientDataSet: TClientDataSet;
      FDataSource: TDataSource;
      procedure SetCapital(const Value: Currency);
      procedure SetMeses(const Value: Integer);
      procedure SetTaxaJuros(const Value: Currency);
      procedure SetClientDataSet(const Value: TClientDataSet);
      procedure SetDataSource(const Value: TDataSource);

      function GetCapital: Currency;
      function GetTaxaJuros: Currency;
      function GetMeses: Integer;
      function GetClientDataSet: TClientDataSet;
      function GetDataSource: TDataSource;
   protected
      /// <summary>
      ///    Cria e seta o CDS/DS ao Grid
      /// </summary>
      procedure CreateAndSetSourceOnGrid;

      /// <summary>
      ///    Limpa o CDS/DS do Grid
      /// </summary>
      procedure ClearForm;

      /// <summary>
      ///    System Command
      /// </summary>
      procedure SendSystemCommand(const ACommand: Integer);
   strict protected
      /// <summary>
      ///    Valida as informações digitadas nos campos do form
      /// </summary>
      function Validate: Boolean;

      /// <summary>
      ///    Executa a simulação
      /// </summary>
      procedure Simulate;
   strict private
      /// <summary>
      ///    Exporta os dados do grid em HTML
      /// </summary>
      procedure ExportToHTML;

      /// <summary>
      ///    Exporta os dados do grid em CSV
      /// </summary>
      procedure ExportToCSV;

      /// <summary>
      ///    Exporta os dados do grid em XML
      /// </summary>
      procedure ExportToXML;

      /// <summary>
      ///    Finaliza a exportação montando o nome do arquivo e salvando na pasta padrão
      /// </summary>
      procedure FinalizeExport(const AExtensionFile: UnicodeString; const AStringList: TStringList);

      /// <summary>
      ///    Insere os dados do financiamento ao DBGrid
      /// </summary>
      procedure AppendDataOnClientDataSet(const AFinanciamento: TFinanciamento);

      /// <summary>
      ///    Insere a primeira linha no grid
      /// </summary>
      procedure InsertFirstLine(const ACapital: Currency);

      /// <summary>
      ///    Insere a última linha no grid
      /// </summary>
      procedure InsertLastLine(const AFinanciamento: TFinanciamento);

      /// <summary>
      ///    Insere uma linha no grid com os dados da parcela
      /// </summary>
      procedure AppendLineOnClientDataSet(const AFinanciamentoParcela: TFinanciamentoParcela);
   public
      property Capital: Currency read GetCapital write SetCapital;
      property TaxaJuros: Currency read GetTaxaJuros write SetTaxaJuros;
      property Meses: Integer read GetMeses write SetMeses;
      property ClientDataSet: TClientDataSet read GetClientDataSet write SetClientDataSet;
      property DataSource: TDataSource read GetDataSource write SetDataSource;

      // -> Remove a a borda do form
      procedure CreateParams(var Params: TCreateParams); override;
   end;

var
  FrmSimulador: TFrmSimulador;

implementation

{$R *.dfm}

procedure TFrmSimulador.AppendDataOnClientDataSet(const AFinanciamento: TFinanciamento);
var
   FinanciamentoParcela: TFinanciamentoParcela;
begin
   if Assigned(AFinanciamento) then
   begin
      CreateAndSetSourceOnGrid;

      // -> Insere a primeira linha
      InsertFirstLine(AFinanciamento.Capital);

      // -> Insere as parcelas
      for FinanciamentoParcela in AFinanciamento.Parcelas do
         AppendLineOnClientDataSet(FinanciamentoParcela);

      // -> Insere a última linha
      InsertLastLine(AFinanciamento);
   end;
end;

procedure TFrmSimulador.AppendLineOnClientDataSet(const AFinanciamentoParcela: TFinanciamentoParcela);
begin
   ClientDataSet.Append;
   ClientDataSet.FieldByName('PARCELA').AsString := AFinanciamentoParcela.Parcela.ToString;
   ClientDataSet.FieldByName('JUROS').AsCurrency := AFinanciamentoParcela.Juros;

   if (AFinanciamentoParcela.Amortizacao > 0) then
      ClientDataSet.FieldByName('AMORTIZACAO').AsCurrency := AFinanciamentoParcela.Amortizacao
   else
      ClientDataSet.FieldByName('AMORTIZACAO').AsString := '';

   if (AFinanciamentoParcela.Pagamento > 0) then
      ClientDataSet.FieldByName('PAGAMENTO').AsCurrency := AFinanciamentoParcela.Pagamento
   else
      ClientDataSet.FieldByName('PAGAMENTO').AsString := '';

   ClientDataSet.FieldByName('SALDODEVEDOR').AsCurrency := AFinanciamentoParcela.SaldoDevedor;
   ClientDataSet.Post;
end;

procedure TFrmSimulador.BtCloseClick(Sender: TObject);
begin
   Close;
end;

procedure TFrmSimulador.BtExportHTMLClick(Sender: TObject);
begin
   ExportToHTML;
end;

procedure TFrmSimulador.BtExportCSVClick(Sender: TObject);
begin
   ExportToCSV;
end;

procedure TFrmSimulador.BtExportXMLClick(Sender: TObject);
begin
   ExportToXML;
end;

procedure TFrmSimulador.BtFecharClick(Sender: TObject);
begin
   Close;
end;

procedure TFrmSimulador.BtMinimizeClick(Sender: TObject);
begin
   WindowState := wsMinimized;
end;

procedure TFrmSimulador.BtSimularClick(Sender: TObject);
begin
   Simulate;
end;

procedure TFrmSimulador.ClearForm;
begin
   if Assigned(FClientDataSet) then
   begin
      FClientDataSet.EmptyDataSet;
      FreeAndNil(FClientDataSet);
   end;

   if Assigned(FDataSource) then
      FreeAndNil(FDataSource);
end;

procedure TFrmSimulador.CreateAndSetSourceOnGrid;
begin
   if (GridSimulator.DataSource = nil) then
   begin
      ClientDataSet.Close;
      ClientDataSet.FieldDefs.Add('PARCELA', ftString, 6);
      ClientDataSet.FieldDefs.Add('JUROS', ftCurrency);
      ClientDataSet.FieldDefs.Add('AMORTIZACAO', ftCurrency);
      ClientDataSet.FieldDefs.Add('PAGAMENTO', ftCurrency);
      ClientDataSet.FieldDefs.Add('SALDODEVEDOR', ftCurrency);
      ClientDataSet.CreateDataSet;

      DataSource.DataSet := ClientDataSet;
      GridSimulator.DataSource := DataSource;
   end
   else
   if (ClientDataSet.Active) then
      ClientDataSet.EmptyDataSet;
end;

procedure TFrmSimulador.CreateParams(var Params: TCreateParams);
begin
   inherited;
   Params.Style := Params.Style - WS_BORDER;
end;

procedure TFrmSimulador.EdtCapitalExit(Sender: TObject);
begin
   if (Capital > 0.00) then
      EdtCapital.Text := FormatFloat('#,###,##0.00', Capital);
end;

procedure TFrmSimulador.EdtCapitalKeyPress(Sender: TObject; var Key: Char);
begin
   UtilsComp.KeyPressCurrency(Key);
end;

procedure TFrmSimulador.EdtTaxaJurosExit(Sender: TObject);
begin
   if (TaxaJuros > 0.00) then
      EdtTaxaJuros.Text := FormatFloat('#0.00', TaxaJuros);
end;

procedure TFrmSimulador.EdtTaxaJurosKeyPress(Sender: TObject; var Key: Char);
begin
   UtilsComp.KeyPressCurrency(Key);
end;

procedure TFrmSimulador.ExportToHTML;
var
   DataSetTable: TDataSetTableProducer;
   StringList: TStringList;
begin
   if (ClientDataSet.IsEmpty) then
      Exit;

   DataSetTable := TDataSetTableProducer.Create(nil);
   StringList := TStringList.Create;
   try
      ClientDataSet.First;

      DataSetTable.DataSet := ClientDataSet;
      DataSetTable.TableAttributes.Border := 1;
      DataSetTable.MaxRows := Meses + 2;
      DataSetTable.TableAttributes.Align := THTMLAlign.haCenter;
      DataSetTable.RowAttributes.Align := THTMLAlign.haCenter;
      DataSetTable.Header.Add(Format('Simulação de Amortização de Juros - Capital R$: %s - Juros: %s', [EdtCapital.Text, EdtTaxaJuros.Text]) + '%');
      DataSetTable.Footer.Add(Format('Relatório gerado em %s a partir do aplicativo teste para a empresa Datapar®', [DateToStr(Now)]));

      StringList.Text := DataSetTable.Content;

      // -> Finaliza a exportação
      FinalizeExport('html', StringList);
   finally
      FreeAndNil(DataSetTable);
      FreeAndNil(StringList);
   end;
end;

procedure TFrmSimulador.ExportToCSV;
var
   StringList: TStringList;
   Field: TField;
   Title, Content: UnicodeString;
begin
   if (ClientDataSet.IsEmpty) then
      Exit;

   StringList := TStringList.Create;
   try
      for Field in ClientDataSet.Fields do
         Title := Title + Field.DisplayLabel + ';';

      StringList.Add(Title);

      ClientDataSet.First;
      repeat
         Content := EmptyStr;

         for Field in ClientDataSet.Fields do
            Content := Content + Field.DisplayText + ';';

         StringList.Add(Content);
         ClientDataSet.Next;
      until ClientDataSet.Eof;

      // -> Finaliza a exportação
      FinalizeExport('csv', StringList);
   finally
      FreeAndNil(StringList);
   end;
end;

procedure TFrmSimulador.ExportToXML;
var
   StringList: TStringList;
   XMLDocument: IXMLDocument;
   HeaderNode, RowNode, FieldNode: IXMLNode;
   Field: TField;
begin
   if (ClientDataSet.IsEmpty) then
      Exit;

   StringList := TStringList.Create;
   XMLDocument := TXMLDocument.Create(nil);
   try
      XMLDocument.Active := True;
      XMLDocument.DocumentElement := XMLDocument.CreateElement('financiamento', EmptyStr);

      HeaderNode := XMLDocument.DocumentElement.AddChild('header');
      FieldNode := HeaderNode.AddChild('capital');
      FieldNode.Text := EdtCapital.Text;
      FieldNode := HeaderNode.AddChild('taxajuros');
      FieldNode.Text := EdtTaxaJuros.Text;
      FieldNode := HeaderNode.AddChild('meses');
      FieldNode.Text := EdtMeses.Text;

      ClientDataSet.First;
      repeat
         RowNode := XMLDocument.DocumentElement.AddChild('item');

         for Field in ClientDataSet.Fields do
         begin
            FieldNode := RowNode.AddChild(LowerCase(Field.DisplayLabel));
            FieldNode.Text := Field.DisplayText;
         end;

         ClientDataSet.Next;
      until ClientDataSet.Eof;

      StringList.Add(XMLDocument.XML.Text);

      // -> Finaliza a exportação
      FinalizeExport('xml', StringList);
   finally
      FreeAndNil(StringList);
   end;
end;

procedure TFrmSimulador.FinalizeExport(const AExtensionFile: UnicodeString; const AStringList: TStringList);
var
   FileName: UnicodeString;
begin
   // -> Obtém o nome do arquivo baseado na data/hora
   FileName := UtilsFile.GetCommonFileName(AExtensionFile);

   // -> Salva o arquivo na pasta padrão
   AStringList.SaveToFile(FileName);

   // -> Abre o arquivo
   UtilsFile.TryOpenFileWithConfirmation(FileName);
end;

procedure TFrmSimulador.FormClose(Sender: TObject; var Action: TCloseAction);
begin
   ClearForm;
   Action := caFree;
   Release;
   FrmSimulador := nil;
end;

procedure TFrmSimulador.FormKeyPress(Sender: TObject; var Key: Char);
begin
   // -> Vai para o próximo componente após apertar ENTER
   if (Key = #13) then
      Perform(WM_NEXTDLGCTL, 0, 0);
end;

function TFrmSimulador.GetCapital: Currency;
begin
   Result := UtilsConv.TryStrToCurrency(EdtCapital.Text);
end;

function TFrmSimulador.GetClientDataSet: TClientDataSet;
begin
   if (not Assigned(FClientDataSet)) then
      FClientDataSet := TClientDataSet.Create(nil);

   Result := FClientDataSet;
end;

function TFrmSimulador.GetDataSource: TDataSource;
begin
   if (not Assigned(FDataSource)) then
      FDataSource := TDataSource.Create(nil);

   Result := FDataSource;
end;

function TFrmSimulador.GetMeses: Integer;
begin
   Result := UtilsConv.TryStrToInteger(EdtMeses.Text);
end;

function TFrmSimulador.GetTaxaJuros: Currency;
begin
   Result := UtilsConv.TryStrToCurrency(EdtTaxaJuros.Text);
end;

procedure TFrmSimulador.InsertFirstLine(const ACapital: Currency);
begin
   ClientDataSet.Append;
   ClientDataSet.FieldByName('PARCELA').AsString := '0';
   ClientDataSet.FieldByName('JUROS').AsCurrency := 0;
   ClientDataSet.FieldByName('AMORTIZACAO').AsCurrency := 0;
   ClientDataSet.FieldByName('PAGAMENTO').AsCurrency := 0;
   ClientDataSet.FieldByName('SALDODEVEDOR').AsCurrency := ACapital;
   ClientDataSet.Post;
end;

procedure TFrmSimulador.InsertLastLine(const AFinanciamento: TFinanciamento);
begin
   ClientDataSet.Append;
   ClientDataSet.FieldByName('PARCELA').AsString := 'Totais';
   ClientDataSet.FieldByName('JUROS').AsCurrency := AFinanciamento.TotalJuros;
   ClientDataSet.FieldByName('AMORTIZACAO').AsCurrency := AFinanciamento.Capital;
   ClientDataSet.FieldByName('PAGAMENTO').AsCurrency := AFinanciamento.Capital + AFinanciamento.TotalJuros;
   ClientDataSet.Post;
end;

procedure TFrmSimulador.PnlUpperMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
   // -> Possibilita a movimentação do Painel (que é a borda do form)
   inherited;
   ReleaseCapture;
   BringToFront;
   SendSystemCommand($F012);
end;

procedure TFrmSimulador.SendSystemCommand(const ACommand: Integer);
begin
   Perform(WM_SYSCOMMAND, ACommand, 0);

   if Assigned(Parent) then
      Parent.Repaint;
end;

procedure TFrmSimulador.SetCapital(const Value: Currency);
begin
   FCapital := Value;
end;

procedure TFrmSimulador.SetClientDataSet(const Value: TClientDataSet);
begin
   FClientDataSet := Value;
end;

procedure TFrmSimulador.SetDataSource(const Value: TDataSource);
begin
   FDataSource := Value;
end;

procedure TFrmSimulador.SetMeses(const Value: Integer);
begin
   FMeses := Value;
end;

procedure TFrmSimulador.SetTaxaJuros(const Value: Currency);
begin
   FTaxaJuros := Value;
end;

procedure TFrmSimulador.Simulate;
var
   Simulator: TAppSimulatorController;
   Financiamento: TFinanciamento;
begin
   if Validate then
   begin
      Simulator := TAppSimulatorController.Create(Capital, TaxaJuros, Meses);
      try
         // -> Obtém o objeto com a simulação do financiamento
         Financiamento := Simulator.Execute;

         if Assigned(Financiamento) then
         begin
            AppendDataOnClientDataSet(Financiamento);
            FreeAndNil(Financiamento);
         end;
      finally
         FreeAndNil(Simulator);
      end;
   end;
end;

function TFrmSimulador.Validate: Boolean;
begin
   if (Capital <= 0) then
   begin
      UtilsMsg.ShowMessageInformation('Obrigatório informar o valor de capital!');
      UtilsComp.FocusIndicator(EdtCapital);
      Exit(False);
   end;

   if (TaxaJuros <= 0) then
   begin
      UtilsMsg.ShowMessageInformation('Obrigatório informar a taxa de juros!');
      UtilsComp.FocusIndicator(EdtTaxaJuros);
      Exit(False);
   end;

   if (Meses <= 0) then
   begin
      UtilsMsg.ShowMessageInformation('Obrigatório informar a quantidade de meses!');
      UtilsComp.FocusIndicator(EdtMeses);
      Exit(False);
   end;

   Result := True;
end;

end.
