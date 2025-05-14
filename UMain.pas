unit UMain;

interface

uses
  // Delphi
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons, Vcl.Clipbrd,

  // Calculator
  UCalc;

// uncomment this for Test Infor
{$DEFINE Testing}

type
  TCalc = class(TForm)
    pnlInput: TPanel;
    edtCalcStr: TEdit;
    edtInput: TEdit;
    pnlTopSpace: TPanel;
    pnl789: TPanel;
    Panel456: TPanel;
    Panel1: TPanel;
    btnDel: TBitBtn;
    btn8: TBitBtn;
    btn7: TBitBtn;
    btnDiv: TBitBtn;
    btn9: TBitBtn;
    btn4: TBitBtn;
    btn5: TBitBtn;
    btn6: TBitBtn;
    btnMulti: TBitBtn;
    btnClear: TBitBtn;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    btn1: TBitBtn;
    btn2: TBitBtn;
    btn3: TBitBtn;
    btnSubtract: TBitBtn;
    Panel5: TPanel;
    btn0: TBitBtn;
    btnDecimal: TBitBtn;
    btnAdd: TBitBtn;
    btnTotal: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnDivClick(Sender: TObject);
    procedure btnMultiClick(Sender: TObject);
    procedure btnSubtractClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnTotalClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnDelClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
  private
    { Private-Deklarationen }
    fCalculator: TCalculator;

    procedure AddOperatorToCalculator(aValue: TValueRecord);
    procedure AddToCalculator;
    procedure CalculateResult;
    procedure NumericButtonClick(Sender: TObject);
    function PrepareCalculatorOperatorValue(aOperator: TCalcOperator): TValueRecord;
    procedure SetEditFocus(
      aEdit:      TEdit;
      aSelectAll: Boolean = False);
  public
    { Public-Deklarationen }
  end;

var
  Calc: TCalc;

implementation

{$R *.dfm}

// einer der Operatoren zum Calculator hinzufügen
procedure TCalc.AddOperatorToCalculator(aValue: TValueRecord);
begin
  if (edtInput.Text <> '') then
    AddToCalculator;

  fCalculator.AddValue(aValue);
  edtCalcStr.Text := fCalculator.CalcExpresion;
  edtInput.Text   := '';

  SetEditFocus(edtInput);
end;

// den Input zum Calculator hinzufügen
procedure TCalc.AddToCalculator;
var
  aValue: TValueRecord;
begin
  aValue.Value      := StrToFloat(edtInput.Text);
  aValue.IsOperator := False;
  fCalculator.AddValue(aValue);
  SetEditFocus(edtInput);
end;

procedure TCalc.btnAddClick(Sender: TObject);
begin
  AddOperatorToCalculator(PrepareCalculatorOperatorValue(coAdd));
  SetEditFocus(edtInput);
end;

procedure TCalc.btnClearClick(Sender: TObject);
begin
  fCalculator.ResetCalculator;
  edtCalcStr.Text := '';
  edtInput.Text   := '';
  SetEditFocus(edtInput);
end;

procedure TCalc.btnDelClick(Sender: TObject);
begin
  edtInput.Text := Copy(edtInput.Text, 1, Length(edtInput.Text) - 1);
  SetEditFocus(edtInput);
end;

procedure TCalc.btnDivClick(Sender: TObject);
begin
  AddOperatorToCalculator(PrepareCalculatorOperatorValue(coDivide));
  SetEditFocus(edtInput);
end;

procedure TCalc.btnMultiClick(Sender: TObject);
begin
  AddOperatorToCalculator(PrepareCalculatorOperatorValue(coMultiply));
  SetEditFocus(edtInput);
end;

procedure TCalc.btnSubtractClick(Sender: TObject);
begin
  AddOperatorToCalculator(PrepareCalculatorOperatorValue(coSubtract));
  SetEditFocus(edtInput);
end;

procedure TCalc.btnTotalClick(Sender: TObject);
begin
  CalculateResult;
  SetEditFocus(edtInput);
end;

// einer der numerischen Buttons klicken
procedure TCalc.NumericButtonClick(Sender: TObject);
var
  aFormatSettings: TFormatSettings;
begin
  if TBitBtn(Sender).Name = 'btnDecimal' then
  begin
    if (edtInput.Text = '') then
      edtInput.Text := '0';

    aFormatSettings := TFormatSettings.Create;
    if Pos(aFormatSettings.DecimalSeparator, edtInput.Text) = 0 then
      edtInput.Text := edtInput.Text + aFormatSettings.DecimalSeparator;
  end
  else
  begin
    if (edtInput.Text = '') or (edtInput.Text = '0') then
      edtInput.Text := TBitBtn(Sender).Caption
    else
      edtInput.Text := edtInput.Text + TBitBtn(Sender).Caption;
  end;

  SetEditFocus(edtInput);
end;

function TCalc.PrepareCalculatorOperatorValue(aOperator: TCalcOperator): TValueRecord;
begin
  Result.Value      := Integer(aOperator);
  Result.IsOperator := True;
end;

procedure TCalc.SetEditFocus(
  aEdit:      TEdit;
  aSelectAll: Boolean = False);
begin
  aEdit.SetFocus;

  if aSelectAll then
    aEdit.SelectAll
  else
  begin
    aEdit.SelStart  := Length(aEdit.Text);
    aEdit.SelLength := 0;
  end;
end;

// Das Resultat berechnen
procedure TCalc.CalculateResult;
{$IFDEF Testing}
var
  aInfixNotation:   String;
  aPostfixNotation: String;
  aDisplayString:   String;
{$ENDIF Testing}
begin
  AddToCalculator;
{$IFDEF Testing}
  aInfixNotation   := fCalculator.CalcExpresion;
  aPostfixNotation := fCalculator.ReversePolishNotationString;
  edtCalcStr.Text  := aInfixNotation;
  aDisplayString   :=
    'Infix Notation:' + sLineBreak + aInfixNotation + sLineBreak + sLineBreak +
    'Reverse Polish Notation (PostFix notation):' + sLineBreak + aPostfixNotation;
  Clipboard.AsText := aDisplayString;
  MessageDlg(aDisplayString, mtInformation, [mbOk], 0);
{$ELSE}
  edtCalcStr.Text := fCalculator.CalcExpresion;
  edtInput.Text   := fCalculator.Evaluate.ToString;
{$ENDIF Testing}
  edtInput.Text   := fCalculator.Evaluate.ToString;
  fCalculator.ResetCalculator;
  SetEditFocus(edtInput);
end;

procedure TCalc.FormCreate(Sender: TObject);
begin
  fCalculator        := TCalculator.Create;
  btn0.OnClick       := NumericButtonClick;
  btn1.OnClick       := NumericButtonClick;
  btn2.OnClick       := NumericButtonClick;
  btn3.OnClick       := NumericButtonClick;
  btn4.OnClick       := NumericButtonClick;
  btn5.OnClick       := NumericButtonClick;
  btn6.OnClick       := NumericButtonClick;
  btn7.OnClick       := NumericButtonClick;
  btn8.OnClick       := NumericButtonClick;
  btn9.OnClick       := NumericButtonClick;
  btnDecimal.OnClick := NumericButtonClick;
end;

procedure TCalc.FormDestroy(Sender: TObject);
begin
  if Assigned(fCalculator) then
    FreeAndNil(fCalculator);
end;

procedure TCalc.FormKeyPress(Sender: TObject; var Key: Char);
var
  aClearKey: Boolean;
begin
  aClearKey := True;
  case Key of
    '*': AddOperatorToCalculator(PrepareCalculatorOperatorValue(coMultiply));
    '/': AddOperatorToCalculator(PrepareCalculatorOperatorValue(coDivide));
    '+': AddOperatorToCalculator(PrepareCalculatorOperatorValue(coAdd));
    '-': AddOperatorToCalculator(PrepareCalculatorOperatorValue(coSubtract));
    '(':
    begin
      AddOperatorToCalculator(PrepareCalculatorOperatorValue(coParenthesesLeft));
      aClearKey := True; // clear Key value
    end;
    ')':
    begin
      AddOperatorToCalculator(PrepareCalculatorOperatorValue(coParenthesesRight));
      aClearKey := True; // clear Key value
    end;
    '=': CalculateResult;
    Chr(VK_DELETE), Chr(VK_BACK): aClearKey := True; // clear Key value
    else
      aClearKey := False;
  end;

  if aClearKey then
    Key := #0;

  SetEditFocus(edtInput);
end;

procedure TCalc.FormShow(Sender: TObject);
begin
  SetEditFocus(edtInput);
end;

end.
