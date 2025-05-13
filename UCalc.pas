unit UCalc;

interface

uses
  // Delphi
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.StrUtils, System.Generics.Collections;

type
  TCalcOperator = (coNone, coMultiply, coDivide, coAdd, coSubtract);

  TValueRecord = record
    Value:      Double;
    IsOperator: Boolean;
  end;

  TCalculator = class
  private
//    fValuesArray:    Variant;
    fValuesArray: TList<TValueRecord>;

    function VarTypeIsString(aValue: Variant): Boolean;
    function ValidateValueAsDouble(aValue: String): Double;
  public
    constructor Create;
    destructor Destroy;
    procedure ResetCalculator;
    procedure AddValue(aValue: Variant);
    function GetCalcString: String;
    function GetResult: String;
  end;

implementation

const
  cInvalidNumber = '"%s" is not a valid number!';

{ TCalculator }

// add aValue to the array
procedure TCalculator.AddValue(aValue: Variant);
var
  aHighBound: Integer;
  aStrVal:    String;
  aVarValue:  Variant;
  aValRecord: TValueRecord;
begin
  aHighBound            := fValuesArray.Count;
  aValRecord.IsOperator := False;

  if VarTypeIsString(aValue) then
  begin
    aStrVal := VarToStr(aValue);
    if Length(aStrVal) = 1 then
    begin
      aValRecord.IsOperator := True;
      case aStrVal[1] of
        '*': aValRecord.Value := Integer(coMultiply);
        '/': aValRecord.Value := Integer(coDivide);
        '+': aValRecord.Value := Integer(coAdd);
        '-': aValRecord.Value := Integer(coSubtract);
        else
        begin
          aValRecord.Value      := ValidateValueAsDouble(aStrVal);
          aValRecord.IsOperator := False;
        end;
      end;
    end
    else
      aValRecord.Value      := ValidateValueAsDouble(aStrVal);
  end
  else if VarType(aValue) = varDouble then
    aValRecord.Value := aValue
  else
  begin
    if (TCalcOperator(aValue) = coNone) then
      exit;

    aValRecord.Value      := aValue;
    aValRecord.IsOperator := True;

    if (aHighBound > 1) and (fValuesArray[aHighBound - 1].IsOperator) then
      fValuesArray.Delete(aHighBound - 1);
  end;

  if aValRecord.IsOperator and (fValuesArray.Count = 0) then
    exit; // only add the operator

  fValuesArray.Add(aValRecord);
end;

constructor TCalculator.Create;
begin
 fValuesArray := TList<TValueRecord>.Create;
 ResetCalculator;
end;

destructor TCalculator.Destroy;
begin
  ResetCalculator;
  fValuesArray.Free;
end;

// return the function as a string for display
function TCalculator.GetCalcString: String;
var
  aValue: TValueRecord;
begin
  Result := '';

  for aValue in fValuesArray do
  begin
    if Result <> '' then
      Result := Result + ' ';

    if aValue.IsOperator then
    begin
      case TCalcOperator(Round(aValue.Value)) of
        coMultiply: Result := Result + '*';
        coDivide:   Result := Result + '/';
        coAdd:      Result := Result + '+';
        coSubtract: Result := Result + '-';
      end;
    end
    else
      Result := Result + VarToStr(aValue.Value);
  end;
end;

// calculate the value of the expression
function TCalculator.GetResult: String;
var
  aValue:     TValueRecord;
  aValue1:    Double;
  aValue2:    Double;
  aOperator:  TCalcOperator;
  aResult:    Double;
  aStart:     Boolean;
  aDoCalc:    Boolean;
  aHasCalc:   Boolean;
begin
  aStart    := True;
  aDoCalc   := False;
  aHasCalc  := False;
  aOperator := coNone;

  for aValue in fValuesArray do
  begin
    if aValue.IsOperator then
    begin
      aOperator := TCalcOperator(Round(aValue.Value));
      aDoCalc   := True;
    end
    else
    begin
      if aStart then
      begin
        aValue1 := aValue.Value;
        aStart  := False;
        aResult := aValue1;      // save first value to Result
      end
      else if aHasCalc then
        aValue1 := aResult;

      if aDoCalc then
      begin
        aValue2 := aValue.Value;

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
    end;
  end;

  Result := aResult.ToString;
end;

// clear all values
procedure TCalculator.ResetCalculator;
begin
  fValuesArray.Clear;
end;

// validate a given string and return it as double
function TCalculator.ValidateValueAsDouble(aValue: String): Double;
var
  aValDbl: Double;
begin
  Result := 0.0;
  if TryStrToFloat(aValue, aValDbl) then
    Result := aValDbl
  else
    raise Exception.Create(Format(cInvalidNumber, [aValue]));
end;

// validate if the variant is any of the string types
function TCalculator.VarTypeIsString(aValue: Variant): Boolean;
begin
  Result := (VarType(aValue) = varString) or
    (VarType(aValue) = varOleStr) or
    (VarType(aValue) = varUString);
end;

end.
