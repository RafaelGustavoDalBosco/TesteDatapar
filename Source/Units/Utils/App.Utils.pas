{=====================================================}
{          Developer: Rafael Gustavo Dal Bosco        }
{       2022 - Datapar® - All Rights Reserved ™       }
{=====================================================}
unit App.Utils;

interface

uses

{$REGION ' |SYSTEM| '}
   System.SysUtils,
   System.Classes,
   System.UITypes,
   Winapi.Windows,
   ShellApi,
{$ENDREGION}

{$REGION ' |APP| '}
   App.Utils.Component.Border,
{$ENDREGION}

{$REGION ' |VCL| '}
   Vcl.Dialogs,
   Vcl.Forms,
   Vcl.StdCtrls,
   Vcl.Controls;
{$ENDREGION}

type

   TAppUtilsComponent = class
   public
      /// <summary>
      ///    Método que controla a digitação apenas de números
      /// </summary>
      class procedure KeyPressCurrency(var AKey: Char); static;

      /// <summary>
      ///    Seta o foco a um determinado componente
      /// </summary>
      class procedure SetFocus(const AComponent: TComponent); static;

      /// <summary>
      ///    Seta o foco a um determinado componente, e sinaliza ao usuário
      /// </summary>
      class procedure FocusIndicator(const AComponent: TComponent); static;

      /// <summary>
      ///    Limpa todos os componentes de um form (no caso o Form descende da classe TComponent)
      /// </summary>
      class procedure ClearComponents(const AComponent: TComponent); static;
   end;

   TAppUtilsConverter = class
   public
      /// <summary>
      ///    Tenta converter um valor String para Currency
      /// </summary>
      class function TryStrToCurrency(const AValue: UnicodeString): Currency; static;

      /// <summary>
      ///    Tenta conver um valor Sttring para Integer
      /// </summary>
      class function TryStrToInteger(const AValue: UnicodeString): Integer; static;
   end;

   TAppUtilsMessages = class
   public
      /// <summary>
      ///    Mostra a mensagem do Windows de informação
      /// </summary>
      class function ShowMessageInformation(const AMessage: UnicodeString): Boolean; static;

      /// <summary>
      ///    Mostra a mensagem do Windows de Warning
      /// </summary>
      class function ShowMessageWarning(const AMessage: UnicodeString): Boolean; static;

      /// <summary>
      ///    Msotra a mensagem do Windows de confirmação
      /// </summary>
      class function ShowMessageConfirm(const AMessage: UnicodeString): Boolean; static;
   end;

   TAppUtilsFiles = class
   public
      /// <summary>
      ///    Abre qualquer arquivo baseado no programa padrão do Windows
      /// </summary>
      class procedure OpenAnyFile(const AFilePath: UnicodeString); static;

      /// <summary>
      ///    Obtém o nome do arquivo padrão baseado no caminho do aplicativo + a extensão do arquivo
      /// </summary>
      class function GetCommonFileName(const AExtension: UnicodeString): UnicodeString; static;

      /// <summary>
      ///    Tenta abrir um arquivo com dialog de confirmação
      /// </summary>
      class procedure TryOpenFileWithConfirmation(const AFileName: UnicodeString); static;

      /// <summary>
      ///    Cria uma pasta
      /// </summary>
      class procedure CreateDirectory(const APath: UnicodeString); static;
   end;

var
   UtilsComp: TAppUtilsComponent;
   UtilsMsg: TAppUtilsMessages;
   UtilsFile: TAppUtilsFiles;
   UtilsConv: TAppUtilsConverter;

implementation

{ TAppUtilsComponent }

class procedure TAppUtilsComponent.ClearComponents(const AComponent: TComponent);
var
   Loop: TComponent;
begin
   for Loop in AComponent do
   begin
      if Loop is TEdit then
         TEdit(Loop).Text := EmptyStr;

      if Loop is TMemo then
         TMemo(Loop).Lines.Text := EmptyStr;
   end;
end;


class procedure TAppUtilsComponent.FocusIndicator(const AComponent: TComponent);
var
   WinControl: TWinControl;
begin
   WinControl := TComponent(AComponent) as TWinControl;

   BorderControl(WinControl);

   UtilsComp.SetFocus(AComponent);
end;

class procedure TAppUtilsComponent.KeyPressCurrency(var AKey: Char);
begin
   if (not CharInSet(AKey,['0'..'9', ',', #8])) then
      AKey := #0
end;

class procedure TAppUtilsComponent.SetFocus(const AComponent: TComponent);
var
   WinControl: TWinControl;
begin
   WinControl := TComponent(AComponent) as TWinControl;

   if WinControl.CanFocus then
      WinControl.SetFocus;
end;

{ TAppUtilsConverter }

class function TAppUtilsConverter.TryStrToCurrency(const AValue: UnicodeString): Currency;
var
   InputValue: UnicodeString;
begin
   if (not AValue.IsEmpty) then
   begin
      InputValue := StringReplace(AValue, '.', '', [rfReplaceAll]);

      if (not TryStrToCurr(InputValue, Result)) then
         UtilsMsg.ShowMessageWarning(Format('Não foi possível converter o texto %s para um número corrente válido!', [AValue]));
   end
   else
      Result := 0;
end;

class function TAppUtilsConverter.TryStrToInteger(const AValue: UnicodeString): Integer;
begin
   if (not AValue.IsEmpty) then
   begin
      if (not TryStrToInt(AValue, Result)) then
         UtilsMsg.ShowMessageWarning(Format('Não foi possível converter o texto %s para um número inteiro válido!', [AValue]));
   end
   else
      Result := 0;
end;

{ TAppUtilsMessages }

class function TAppUtilsMessages.ShowMessageConfirm(const AMessage: UnicodeString): Boolean;
begin
   Result := MessageDlg(AMessage, mtConfirmation, [mbYes, mbNo], 0) > 0;
end;

class function TAppUtilsMessages.ShowMessageInformation(const AMessage: UnicodeString): Boolean;
begin
   Result := MessageDlg(AMessage, TMsgDlgType.mtInformation, [mbOK], 0) > 0;
end;

class function TAppUtilsMessages.ShowMessageWarning(const AMessage: UnicodeString): Boolean;
begin
   Result := MessageDlg(AMessage, TMsgDlgType.mtWarning, [mbOK], 0) > 0;
end;

{ TAppUtilsFiles }

class procedure TAppUtilsFiles.CreateDirectory(const APath: UnicodeString);
begin
   if (not System.SysUtils.DirectoryExists(APath)) then
      System.SysUtils.ForceDirectories(APath);
end;

class function TAppUtilsFiles.GetCommonFileName(const AExtension: UnicodeString): UnicodeString;
var
   DirectoryPath: UnicodeString;
begin
   DirectoryPath := ExtractFilePath(Application.ExeName) + 'Arquivos Exportados\';
   UtilsFile.CreateDirectory(DirectoryPath);
   Result := DirectoryPath + FormatDateTime('dd-mm-yyyy-hh-mm-ss', Now) + '.' + AExtension;
end;

class procedure TAppUtilsFiles.OpenAnyFile(const AFilePath: UnicodeString);
begin
   ShellExecute(0, 'Open', PChar(AFilePath), nil, '', SW_SHOWNORMAL);
end;

class procedure TAppUtilsFiles.TryOpenFileWithConfirmation(const AFileName: UnicodeString);
begin
   if UtilsMsg.ShowMessageConfirm('Deseja abrir o arquivo agora?') then
      UtilsFile.OpenAnyFile(AFileName);
end;

end.
