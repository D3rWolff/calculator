unit UCalc;

interface

uses
  // Delphi
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.StrUtils, System.Generics.Collections;

type
  TCalcOperator = (coNone, coParenthesesLeft, coParenthesesRight, // Parentheses higher presedence is handeled in code
    coSubtract, coAdd, coDivide, coMultiply);                     // order is important - do not change!

  TValueRecord = record
    Value:      Double;
    IsOperator: Boolean;
  end;

  TCalculator = class
  private
    fValuesArray: TList<TValueRecord>;

    function ConvertListToString(aValuesList: TList<TValueRecord>): String;
    function GetCalcExpresion: String;
    function GetReversePolishNotation: TList<TValueRecord>;
    function GetReversePolishNotationString: String;
    function GetValueRecordFromString(aValue: String): TValueRecord;
    function ValidateValueAsDouble(aValue: String): Double;
    function VarTypeIsString(aValue: Variant): Boolean;
  public
    constructor Create;
    destructor Destroy;
    function AddInfixExpression(aInfixExpr: String): Boolean;
    procedure AddValue(aValue: TValueRecord);
    function Evaluate: Double;
    procedure ResetCalculator;
  published
    property CalcExpresion: String read GetCalcExpresion;
    property ReversePolishNotationString: String read GetReversePolishNotationString;
  end;

implementation

const
  cInvalidNumber                    = '"%s" is not a valid number!';
  cInvalidExpressinOperator         = 'Invalid expression: insufficient operands.';
  cInvalidExpressinLeftOverOperator = 'Invalid expression: leftover operands.';
  cErrorDevideByZero                = 'Division by zero.';
  cErrorUnknownOperator             = 'Unknown operator.';

{ TCalculator }

// add an InfixExpression space separated eg: "( 1 + 2 ) * 3"
function TCalculator.AddInfixExpression(aInfixExpr: String): Boolean;
var
  aToken: String;
  aValue: TValueRecord;
begin
  if not aInfixExpr.IsEmpty then
  begin
    for aToken in aInfixExpr.Split([' ']) do
    begin
      aValue := GetValueRecordFromString(aToken);
      AddValue(aValue);
    end;
  end;
end;

// add aValue to the array
procedure TCalculator.AddValue(aValue: TValueRecord);
const
  cOperatorMultiply: TValueRecord = (Value: Integer(coMultiply); IsOperator:True);
var
  aHighBound:    Integer;
  aStrVal:       String;
  aVarValue:     Variant;
  aValRecord:    TValueRecord;
  aCalcOperator: TCalcOperator;
  aIsOperator:   Boolean;
  aLastValue:    TValueRecord;
begin
  aHighBound := fValuesArray.Count;
  aValRecord := aValue;

  if VarTypeIsString(aValRecord.Value) then
  begin
    aStrVal    := VarToStr(aValRecord.Value);

    if aStrVal.IsEmpty then
      exit; // do nothing

    aValRecord := GetValueRecordFromString(aStrVal);

  end
  else
  begin
    if aValRecord.IsOperator then
    begin
      aCalcOperator := TCalcOperator(Round(aValRecord.Value));
      if (aCalcOperator = coNone) then
        exit;

      if (aHighBound > 1) then
      begin
        aLastValue := fValuesArray[aHighBound - 1];
        if aLastValue.IsOperator and  // current: "1,+"
           not (TCalcOperator(Round(aLastValue.Value)) in [coParenthesesLeft..coParenthesesRight]) and
           (aCalcOperator in [coSubtract..coMultiply]) then // action:  "*"
        begin                                           // new: "1" --> "+" was deleted
          // last action was an operator of -, +, /, *
          // needs to be deleted and the new one will be added later
          fValuesArray.Delete(aHighBound - 1);
          Dec(aHighBound);
        end
        else if (aCalcOperator = coParenthesesLeft) then
        begin
          // action to be added: "("
          if not aIsOperator or // current: "1,+,2" or "1"
             (aIsOperator and   // current: "(,1,+,2,)"
              (TCalcOperator(Round(fValuesArray[aHighBound - 1].Value)) = coParenthesesRight)) then
            fValuesArray.Add(cOperatorMultiply); // if nothing is supplied, multiply is assumed for previous Operator
        end;
      end;
    end;
  end;

  if aValRecord.IsOperator and                                     // wanting to add an operator
    (aHighBound = 0) and                                           // no previous entries
    (TCalcOperator(Round(aValRecord.Value)) <> coParenthesesLeft) then // new action is not left parentheses
    exit;                                                          // do not add

  fValuesArray.Add(aValRecord);
end;

function TCalculator.ConvertListToString(aValuesList: TList<TValueRecord>): String;
var
  aValue: TValueRecord;
begin
  Result := '';

  for aValue in aValuesList do
  begin
    if not Result.IsEmpty then
      Result := Result + ' ';

    if aValue.IsOperator then
    begin
      case TCalcOperator(Round(aValue.Value)) of
        coMultiply:         Result := Result + '*';
        coDivide:           Result := Result + '/';
        coAdd:              Result := Result + '+';
        coSubtract:         Result := Result + '-';
        coParenthesesLeft:  Result := Result + '(';
        coParenthesesRight: Result := Result + ')';
      end;
    end
    else
      Result := Result + VarToStr(aValue.Value);
  end;
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
function TCalculator.GetCalcExpresion: String;
begin
  Result := ConvertListToString(fValuesArray);
end;

// calculate the value of the expression
function TCalculator.Evaluate: Double;
var
  aRPN:       TList<TValueRecord>;
  aStack:     TStack<Double>;
  aToken:     TValueRecord;
  aRight:     Double;
  aLeft:      Double;
  aResultVal: Double;
begin
  aRPN := GetReversePolishNotation; // list<>.Create happens inside --> need to free
  try
    aStack := TStack<Double>.Create;
    try
      for aToken in aRPN do
      begin
        if aToken.IsOperator then
        begin
          if aStack.Count < 2 then
            raise Exception.Create(cInvalidExpressinOperator);

          aRight := aStack.Pop; // store the second value and delete from stack
          aLeft  := aStack.Pop; // store the first value and delete from stack

          // do calculation
          case TCalcOperator(Round(aToken.Value)) of
            coAdd:      aResultVal := aLeft + aRight;
            coSubtract: aResultVal := aLeft - aRight;
            coMultiply: aResultVal := aLeft * aRight;
            coDivide:
            begin
              if aRight = 0 then
                raise Exception.Create(cErrorDevideByZero);

              aResultVal := aLeft / aRight;
            end;
          else
            raise Exception.Create(cErrorUnknownOperator);
          end;

          aStack.Push(aResultVal); // add calculation to stack
        end
        else
          aStack.Push(aToken.Value); // add to stack
      end;

      if aStack.Count <> 1 then
        raise Exception.Create(cInvalidExpressinLeftOverOperator);

      Result := aStack.Pop;
    finally
      aStack.Free;
    end;
  finally
    aRPN.Free;
  end;
end;

// using the Shunting Yard algorithm
function TCalculator.GetReversePolishNotation: TList<TValueRecord>;

  function GetStackPeek(aStack: TStack<TValueRecord>): TValueRecord;
  begin
    if (aStack.Count > 0) then
      Result := aStack.Peek
    else
    begin
      // defaults
      Result.Value      := Integer(coNone);
      Result.IsOperator := True;
    end;
  end;

var
  aStack:        TStack<TValueRecord>;
  aToken:        TValueRecord;
  aTop:          TValueRecord;
  aCalcOperator: TCalcOperator;
begin
  Result := TList<TValueRecord>.Create;
  aStack  := TStack<TValueRecord>.Create;

  try
    for aToken in fValuesArray do
    begin
      if not aToken.IsOperator then
        Result.Add(aToken)
      else
      begin
        aCalcOperator := TCalcOperator(Round(aToken.Value));
        aTop          := GetStackPeek(aStack);

        case aCalcOperator of
          coParenthesesLeft: aStack.Push(aToken); // add operator to stack -->  "("
          coParenthesesRight:
          begin
            // add all operators from Stack until left parentheses is reached
            // and delete from Stack
            while (aStack.Count > 0) and (TCalcOperator(Round(aTop.Value)) <> coParenthesesLeft) do
            begin
              Result.Add(aStack.Pop);      // add to result, delete from stack
              aTop := GetStackPeek(aStack);
            end;

            // delete left parentheses from Stack
            aStack.Pop;
          end;
          else // all other operators
          begin
            while (aStack.Count > 0) and (aTop.Value >= aToken.Value) do
            begin
              Result.Add(aStack.Pop);
              aTop := GetStackPeek(aStack);
            end;

            aStack.Push(aToken);
          end;
        end;
      end;
    end;

    while aStack.Count > 0 do
      Result.Add(aStack.Pop);
  finally
    aStack.Free;
  end;
end;

function TCalculator.GetReversePolishNotationString: String;
begin
  Result := ConvertListToString(GetReversePolishNotation);
end;

function TCalculator.GetValueRecordFromString(aValue: String): TValueRecord;
begin
  if aValue.Length = 1 then
  begin
    Result.IsOperator := True;
    case aValue[1] of
      '*': Result.Value := Integer(coMultiply);
      '/': Result.Value := Integer(coDivide);
      '+': Result.Value := Integer(coAdd);
      '-': Result.Value := Integer(coSubtract);
      '(': Result.Value := Integer(coParenthesesLeft);
      ')': Result.Value := Integer(coParenthesesRight);
      else
      begin
        Result.Value      := ValidateValueAsDouble(aValue);
        Result.IsOperator := False;
      end;
    end;
  end
  else
    Result.Value := ValidateValueAsDouble(aValue);
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
