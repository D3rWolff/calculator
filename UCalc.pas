unit UCalc;

interface

uses
  // Delphi
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.StrUtils;

type
  TCalcOperator = (coNone, coMultiply, coDivide, coAdd, coSubtract);

  TCalculator = class
  private
    fValuesArray:    Variant;

    function VarTypeIsString(aValue: Variant): Boolean;
    procedure GetBounds(
      var aLowBound:  Integer;
      var aHighBound: Integer);
  public
    constructor Create;
    destructor Destroy;
    procedure ResetCalculator;
    procedure AddValue(aValue: Variant);
    function GetCalcString: String;
    function GetResult: String;
  end;

implementation

{ TCalculator }

// wert dem Array hinzufügen
procedure TCalculator.AddValue(aValue: Variant);
var
  aHighBound: Integer;
  aPrevValue: Integer;
  aValInt:    Integer;
  aValDbl:    Double;
  aError:     Integer;
  aTestVal:   Variant;
begin
  aHighBound := VarArrayHighBound(fValuesArray, 1) + 1;

  if not VarTypeIsString(aValue) then
  begin
    if (TCalcOperator(aValue) = coNone) then
      exit;

    aPrevValue := aHighBound - 1;
    if (aPrevValue > 1) then
    begin
      if not(VarTypeIsString(VarArrayGet(fValuesArray, aPrevValue))) then
      begin
        aTestVal := VarArrayGet(fValuesArray, aPrevValue);
        if (TCalcOperator(aTestVal) in [coMultiply..coSubtract]) then
        begin
          VarArrayRedim(fValuesArray, aPrevValue); // vorherigen Operator löschen
          Dec(aHighBound);
        end;
      end;
    end;
  end;

  VarArrayRedim(fValuesArray, aHighBound);
  if (VarTypeIsString(aValue) and (VarToStr(aValue) <> '')) or
     (not VarTypeIsString(aValue) and (TCalcOperator(aValue) > coNone)) then
    VarArrayPut(fValuesArray, aValue, aHighBound); // nur hinzufügen wenn nicht leer
end;

constructor TCalculator.Create;
begin
 fValuesArray := VarArrayCreate([0, 0], varVariant);
 ResetCalculator;
end;

destructor TCalculator.Destroy;
begin
  ResetCalculator;
  VarClear(fValuesArray);
end;

// die Größe des Array ermitteln
procedure TCalculator.GetBounds(
  var aLowBound:  Integer;
  var aHighBound: Integer);
begin
  aLowBound  := VarArrayLowBound(fValuesArray, 1) + 1;
  aHighBound := VarArrayHighBound(fValuesArray, 1);
end;

// die Funktion als String zurück geben
function TCalculator.GetCalcString: String;
var
  aLowBound:  Integer;
  aHighBound: Integer;
  i:          Integer;
  aValue:     Variant;
begin
  GetBounds(aLowBound, aHighBound);
  Result     := '';

  for i := aLowBound to aHighBound do
  begin
    if Result <> '' then
      Result := Result + ' ';

    aValue := VarArrayGet(fValuesArray, i);

    if VarTypeIsString(aValue) then
      Result := Result + VarToStr(aValue)
    else
      case TCalcOperator(aValue) of
        coMultiply: Result := Result + '*';
        coDivide:   Result := Result + '/';
        coAdd:      Result := Result + '+';
        coSubtract: Result := Result + '-';
      end;
  end;
end;

// Den Wert berechnen der Reihe nach
function TCalculator.GetResult: String;
var
  aLowBound:  Integer;
  aHighBound: Integer;
  aValue:     Variant;
  i:          Integer;
  aValue1:    Double;
  aValue2:    Double;
  aOperator:  TCalcOperator;
  aResult:    Double;
  aStart:     Boolean;
  aDoCalc:    Boolean;
  aHasCalc:   Boolean;
begin
  GetBounds(aLowBound, aHighBound);
  aStart    := True;
  aDoCalc   := False;
  aHasCalc  := False;
  aOperator := coNone;

  for i := aLowBound to aHighBound do
  begin
    aValue := VarArrayGet(fValuesArray, i);
    if VarTypeIsString(aValue) then
    begin
      if aStart then
      begin
        aValue1 := VarArrayGet(fValuesArray, i);
        aStart  := False;
      end
      else if aHasCalc then
        aValue1 := aResult;

      if aDoCalc then
      begin
        aValue2 := VarArrayGet(fValuesArray, i);

        case aOperator of
          coMultiply: aResult := aValue1 * aValue2;
          coDivide:   aResult := aValue1 / aValue2;
          coAdd:      aResult := aValue1 + aValue2;
          coSubtract: aResult := aValue1 - aValue2;
        end;

        aOperator := coNone;
        aDoCalc   := False;
        aHasCalc  := True;
      end;
    end
    else
    begin
      aOperator := VarArrayGet(fValuesArray, i);
      aDoCalc   := True;
    end;
  end;

  Result := aResult.ToString;
end;

// alle werte löschen
procedure TCalculator.ResetCalculator;
begin
  VarArrayRedim(fValuesArray, 0);
end;

// prüfen ob der bestimmte Variant einer der String-Arten ist
function TCalculator.VarTypeIsString(aValue: Variant): Boolean;
begin
  Result := (VarType(aValue) = varString) or
    (VarType(aValue) = varOleStr) or
    (VarType(aValue) = varUString);
end;

end.
