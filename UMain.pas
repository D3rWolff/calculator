unit UMain;

interface

uses
  // Delphi
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,

  // Calculator
  UCalc;

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
    procedure edtInputKeyPress(Sender: TObject; var Key: Char);
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

    procedure NumericButtonClick(Sender: TObject);
    procedure AddToCalculator;
    procedure AddOperatorToCalculator(aValue: Variant; var aClearKey: Boolean);
    procedure CalculateResult;
  public
    { Public-Deklarationen }
  end;

var
  Calc: TCalc;

implementation

{$R *.dfm}

// einer der Operatoren zum Calculator hinzufügen
procedure TCalc.AddOperatorToCalculator(aValue: Variant; var aClearKey: Boolean);
begin
  if (edtInput.Text <> '') then
    AddToCalculator;

  fCalculator.AddValue(aValue);
  edtCalcStr.Text := fCalculator.GetCalcString;
  edtInput.Text   := '';
  aClearKey       := True;
end;

// den Input zum Calculator hinzufügen
procedure TCalc.AddToCalculator;
begin
  fCalculator.AddValue(edtInput.Text);
end;

procedure TCalc.btnAddClick(Sender: TObject);
var
  aClearKey: Boolean;
begin
  AddOperatorToCalculator(coAdd, aClearKey);
end;

procedure TCalc.btnClearClick(Sender: TObject);
begin
  fCalculator.ResetCalculator;
  edtCalcStr.Text := '';
  edtInput.Text   := '';
end;

procedure TCalc.btnDelClick(Sender: TObject);
begin
  edtInput.Text := Copy(edtInput.Text, 1, Length(edtInput.Text) - 1);
end;

procedure TCalc.btnDivClick(Sender: TObject);
var
  aClearKey: Boolean;
begin
  AddOperatorToCalculator(coDivide, aClearKey);
end;

procedure TCalc.btnMultiClick(Sender: TObject);
var
  aClearKey: Boolean;
begin
  AddOperatorToCalculator(coMultiply, aClearKey);
end;

procedure TCalc.btnSubtractClick(Sender: TObject);
var
  aClearKey: Boolean;
begin
  AddOperatorToCalculator(coSubtract, aClearKey);
end;

procedure TCalc.btnTotalClick(Sender: TObject);
begin
  CalculateResult;
end;

// einer der numerischen Buttons klicken
procedure TCalc.NumericButtonClick(Sender: TObject);
var
  aFormatSettings: TFormatSettings;
begin
  if TBitBtn(Sender).Name = 'btnDecimal' then
  begin
    aFormatSettings := TFormatSettings.Create;
    edtInput.Text   := edtInput.Text + aFormatSettings.DecimalSeparator;
  end
  else if (TBitBtn(Sender).Name = 'btn0') then
  begin
    if (edtInput.Text = '') then
      edtInput.Text := '0';
  end
  else
    edtInput.Text := edtInput.Text + TBitBtn(Sender).Caption;
end;

// Das Resultat berechnen
procedure TCalc.CalculateResult;
begin
  AddToCalculator;
  edtCalcStr.Text := fCalculator.GetCalcString;
  edtInput.Text   := fCalculator.GetResult;
  fCalculator.ResetCalculator;
end;

procedure TCalc.edtInputKeyPress(Sender: TObject; var Key: Char);
var
  aClearKey: Boolean;
begin
  aClearKey := False;
  case Key of
    '*': AddOperatorToCalculator(coMultiply, aClearKey);
    '/': AddOperatorToCalculator(coDivide, aClearKey);
    '+': AddOperatorToCalculator(coAdd, aClearKey);
    '-': AddOperatorToCalculator(coSubtract, aClearKey);
    '=': CalculateResult;
    Chr(VK_DELETE), Chr(VK_BACK): aClearKey := True; // Key leeren
  end;

  if aClearKey then
    Key := #0;
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
begin
  edtInputKeyPress(Sender, Key);
end;

procedure TCalc.FormShow(Sender: TObject);
begin
  edtInput.SetFocus;
end;

end.
