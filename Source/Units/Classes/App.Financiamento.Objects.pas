{=====================================================}
{          Developer: Rafael Gustavo Dal Bosco        }
{       2022 - Datapar® - All Rights Reserved ™       }
{=====================================================}
unit App.Financiamento.Objects;

interface

uses
   System.Generics.Collections, System.SysUtils;

type

   TFinanciamentoParcela = class
   strict private
      FSaldoDevedor: Currency;
      FJuros: Currency;
      FPagamento: Currency;
      FAmortizacao: Currency;
      FParcela: Integer;
      procedure SetAmortizacao(const Value: Currency);
      procedure SetJuros(const Value: Currency);
      procedure SetPagamento(const Value: Currency);
      procedure SetSaldoDevedor(const Value: Currency);
      procedure SetParcela(const Value: Integer);
   public
      property Parcela: Integer read FParcela write SetParcela;
      property Juros: Currency read FJuros write SetJuros;
      property SaldoDevedor: Currency read FSaldoDevedor write SetSaldoDevedor;
      property Amortizacao: Currency read FAmortizacao write SetAmortizacao;
      property Pagamento: Currency read FPagamento write SetPagamento;
   end;

   TFinanciamento = class
   strict private
      FTaxaJuros: Currency;
      FQuantidadeParcelas: Integer;
      FCapital: Currency;
      FParcelas: TObjectList<TFinanciamentoParcela>;
      FTotalJuros: Currency;
      procedure SetTotalJuros(const Value: Currency);
      procedure SetCapital(const Value: Currency);
      procedure SetQuantidadeParcelas(const Value: Integer);
      procedure SetTaxaJuros(const Value: Currency);
      procedure SetParcelas(const Value: TObjectList<TFinanciamentoParcela>);
   public
      property Capital: Currency read FCapital write SetCapital;
      property TaxaJuros: Currency read FTaxaJuros write SetTaxaJuros;
      property QuantidadeParcelas: Integer read FQuantidadeParcelas write SetQuantidadeParcelas;
      property TotalJuros: Currency read FTotalJuros write SetTotalJuros;
      property Parcelas: TObjectList<TFinanciamentoParcela> read FParcelas write SetParcelas;

      constructor Create; overload;
      destructor Destroy; override;
   end;

implementation

{ TFinanciamento }

constructor TFinanciamento.Create;
begin
   FParcelas := TObjectList<TFinanciamentoParcela>.Create;
   inherited Create;
end;

destructor TFinanciamento.Destroy;
begin
   if Assigned(FParcelas) then
      FreeAndNil(FParcelas);

   inherited Destroy;
end;

procedure TFinanciamento.SetCapital(const Value: Currency);
begin
   FCapital := Value;
end;

procedure TFinanciamento.SetParcelas(const Value: TObjectList<TFinanciamentoParcela>);
begin
   FParcelas := Value;
end;

procedure TFinanciamento.SetQuantidadeParcelas(const Value: Integer);
begin
   FQuantidadeParcelas := Value;
end;

procedure TFinanciamento.SetTaxaJuros(const Value: Currency);
begin
   FTaxaJuros := Value;
end;

procedure TFinanciamento.SetTotalJuros(const Value: Currency);
begin
   FTotalJuros := Value;
end;

{ TFinanciamentoParcela }

procedure TFinanciamentoParcela.SetAmortizacao(const Value: Currency);
begin
   FAmortizacao := Value;
end;

procedure TFinanciamentoParcela.SetJuros(const Value: Currency);
begin
   FJuros := Value;
end;

procedure TFinanciamentoParcela.SetPagamento(const Value: Currency);
begin
   FPagamento := Value;
end;

procedure TFinanciamentoParcela.SetParcela(const Value: Integer);
begin
   FParcela := Value;
end;

procedure TFinanciamentoParcela.SetSaldoDevedor(const Value: Currency);
begin
   FSaldoDevedor := Value;
end;

end.
