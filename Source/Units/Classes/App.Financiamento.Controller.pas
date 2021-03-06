{=====================================================}
{          Developer: Rafael Gustavo Dal Bosco        }
{       2022 - Datapar® - All Rights Reserved ™       }
{=====================================================}
unit App.Financiamento.Controller;

interface

uses
   App.Financiamento.Objects, System.SysUtils, System.Generics.Collections, System.Math;

type

   TAppSimulatorController = class
   private
      FMeses: Integer;
      FTaxaJuros: Currency;
      FCapital: Currency;
      procedure SetCapital(const Value: Currency);
      procedure SetMeses(const Value: Integer);
      procedure SetTaxaJuros(const Value: Currency);
   protected
      property Capital: Currency read FCapital write SetCapital;
      property TaxaJuros: Currency read FTaxaJuros write SetTaxaJuros;
      property Meses: Integer read FMeses write SetMeses;
   strict protected
      /// <summary>
      ///    Obtém o valor do saldo devedor baseado em cada parcela
      /// </summary>
      function GetValorParcela(const AIndexParcela: Integer): Currency;
   public
      /// <summary>
      ///    Executa o cálculo do financiamento e retorna o objeto
      /// </summary>
      function Execute: TFinanciamento;

      constructor Create(const ACapital, ATaxaJuros: Currency; const AMeses: Integer); overload;
   end;

implementation

{ TAppSimulatorController }

constructor TAppSimulatorController.Create(const ACapital, ATaxaJuros: Currency; const AMeses: Integer);
begin
   SetCapital(ACapital);
   SetTaxaJuros(ATaxaJuros);
   SetMeses(AMeses);
   inherited Create;
end;

function TAppSimulatorController.Execute: TFinanciamento;
var
   FinanciamentoParcela: TFinanciamentoParcela;
   Juros, SaldoDevedor, OutValue: Currency;
   Loop: Integer;
begin
   if (FCapital > 0) and (FTaxaJuros > 0) and (FMeses > 0) then
   begin
      Result := TFinanciamento.Create;
      Result.Capital := FCapital;
      Result.TaxaJuros := FTaxaJuros;
      Result.QuantidadeParcelas := FMeses;
      OutValue := 0;

      for Loop := 1 to FMeses do
      begin
         // -> Calcula o valor da parcela
         SaldoDevedor := GetValorParcela(Loop);

         // -> Obtém o valor do juros deduzindo do capital e do valor anterior
         Juros := SaldoDevedor - FCapital - OutValue;

         // -> Armazena o valor anterior
         OutValue := OutValue + Juros;

         FinanciamentoParcela := TFinanciamentoParcela.Create;
         FinanciamentoParcela.Juros := Juros;
         FinanciamentoParcela.Parcela := Loop;
         FinanciamentoParcela.SaldoDevedor := SaldoDevedor;

         // -> Salva o total dos juros calculados
         Result.TotalJuros := Result.TotalJuros + Juros;

         // -> Se é a última parcela, então zera o saldo devedor e atribui o pagamento/amortização
         if (Loop = FMeses) then
         begin
            FinanciamentoParcela.SaldoDevedor := 0;
            FinanciamentoParcela.Pagamento := Result.Capital + Result.TotalJuros;
            FinanciamentoParcela.Amortizacao := Result.Capital;
         end;

         Result.Parcelas.Add(FinanciamentoParcela);
      end;
   end
   else
      Result := nil;
end;

function TAppSimulatorController.GetValorParcela(const AIndexParcela: Integer): Currency;
begin
   // ->  M = C (1 + I)n
   try
      Result := FCapital * Power((1 + (FTaxaJuros / 100)), AIndexParcela);
   except
      on E: Exception do
         raise Exception.Create('Valores inválidos para realizar o cálculo do montante!');
   end;
end;

procedure TAppSimulatorController.SetCapital(const Value: Currency);
begin
   FCapital := Value;
end;

procedure TAppSimulatorController.SetMeses(const Value: Integer);
begin
   FMeses := Value;
end;

procedure TAppSimulatorController.SetTaxaJuros(const Value: Currency);
begin
   FTaxaJuros := Value;
end;

end.
