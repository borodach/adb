unit Prop;

interface

uses sharemem, Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
Buttons, ExtCtrls, RXSpin, NeuralBaseComp;

type
TOKRightDlg = class (TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel1: TBevel;
    Label2: TLabel;
    Label3: TLabel;
    Par1: TRxSpinEdit;
    Par2: TRxSpinEdit;
    Label1: TLabel;
    Bevel2: TBevel;
    Cnt: TRxSpinEdit;
    ListBox1: TListBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Button1: TButton;
    Button2: TButton;
    alfa: TRxSpinEdit;
    speed: TRxSpinEdit;
    epcnt: TRxSpinEdit;
    err: TRxSpinEdit;
    iner: TRxSpinEdit;
    GroupBox1: TGroupBox;
    Label7: TLabel;
    Label8: TLabel;
    epen: TCheckBox;
    Label10: TLabel;
    Label9: TLabel;
    pack_size: TRxSpinEdit;
    Label11: TLabel;
    procedure OKBtnClick (Sender: TObject);
    procedure CancelBtnClick (Sender: TObject);
    procedure ListBox1Click (Sender: TObject);
    procedure Button2Click (Sender: TObject);
    procedure Button1Click (Sender: TObject);
    procedure CntChange (Sender: TObject);
    procedure Button2Exit (Sender: TObject);
    procedure Par1Change (Sender: TObject);
    procedure Par2Change (Sender: TObject);
    procedure FormShow (Sender: TObject);
    procedure epenClick (Sender: TObject);
private
    { Private declarations }
public
    net: TObject;
    ic, oc: Integer;
    { Public declarations }
end;

var
OKRightDlg: TOKRightDlg;

implementation
uses progn;

{$R *.DFM}

procedure TOKRightDlg.OKBtnClick (Sender: TObject);
var res: Integer;
d: Double;
begin
    res := - 1;
    d := ((net as TProgn).base_net as TNeuralNetBP).Alpha;
    if (trunc (d * 10000) <> trunc (alfa.value * 10000)) then
    res := 1;
    d := ((net as TProgn).base_net as TNeuralNetBP).TeachRate;
    if (trunc (d * 10000) <> trunc (speed.value * 10000)) then
    res := 1;
    if (((net as TProgn).base_net as TNeuralNetBP).Epoch <> epen.checked) then
    res := 1;
    if (((net as TProgn).base_net as TNeuralNetBP).EpochCount <> epcnt.value) then
    res := 1;
    d := ((net as TProgn).base_net as TNeuralNetBP).Momentum;
    if (trunc (d * 10000) <> trunc (iner.value * 10000)) then
    res := 1;
    d := ((net as TProgn).base_net as TNeuralNetBP).IdentError;
    if (trunc (d * 10000) <> trunc (err.value * 10000)) then
    res := 1;
    
    if ((net as TProgn).packet <> pack_size.value) then
    res := 1;
    
    ((net as TProgn).base_net as TNeuralNetBP).Alpha := alfa.value;
    ((net as TProgn).base_net as TNeuralNetBP).TeachRate := speed.value;
    ((net as TProgn).base_net as TNeuralNetBP).Epoch := epen.checked;
    ((net as TProgn).base_net as TNeuralNetBP).EpochCount := trunc (epcnt.value);
    ((net as TProgn).base_net as TNeuralNetBP).Momentum := iner.value;
    ((net as TProgn).base_net as TNeuralNetBP).IdentError := err.value;
    (net as TProgn).packet := trunc (pack_size.value);
    modalresult := res;
end;

procedure TOKRightDlg.CancelBtnClick (Sender: TObject);
begin
    modalresult := - 2;
end;

procedure TOKRightDlg.ListBox1Click (Sender: TObject);
var b: Boolean;
begin
    b := (ListBox1.SelCount > 0)and (ListBox1.Selected [0] = false)and (ListBox1.Selected [ListBox1.Items.Count - 1] = false);
    Button2.Enabled := b;
    Cnt.Enabled := b;
    
    if ListBox1.SelCount = 1 then Cnt.Value := Integer (ListBox1.Items.Objects [ListBox1.ItemIndex]);
end;

procedure TOKRightDlg.Button2Click (Sender: TObject);
var i: Integer;
begin
    i := 0;
    while (i < ListBox1.Items.Count) do
    if ListBox1.Selected [i] then ListBox1.Items.Delete (i)
    else Inc (i);
    
end;

procedure TOKRightDlg.Button1Click (Sender: TObject);
var i: Integer;
begin
    i := ListBox1.Items.Count;
    ListBox1.Items.Insert (i - 1, 'Слой №' + IntToStr (i));
end;

procedure TOKRightDlg.CntChange (Sender: TObject);
var i, j, val: Integer;
begin
    val := trunc (cnt.value);
    j := ListBox1.Items.Count - 1;
    for i := 0 to j do
    if ListBox1.Selected [i] then ListBox1.Items.Objects [i] := TObject (val);
    
    
end;
procedure TOKRightDlg.Button2Exit (Sender: TObject);
begin
    ModalResult := - 1;
end;

procedure TOKRightDlg.Par1Change (Sender: TObject);
begin
    ListBox1.Items.Objects [0] := TObject (trunc (Par1.value) * ic);
    ListBox1.OnClick (nil);
end;

procedure TOKRightDlg.Par2Change (Sender: TObject);
begin
    ListBox1.Items.Objects [ListBox1.Items.Count - 1] := TObject (trunc (Par2.value) * oc);
    ListBox1.OnClick (nil);
end;

procedure TOKRightDlg.FormShow (Sender: TObject);
begin
    alfa.value := ((net as TProgn).base_net as TNeuralNetBP).Alpha;
    speed.value := ((net as TProgn).base_net as TNeuralNetBP).TeachRate;
    epen.checked := ((net as TProgn).base_net as TNeuralNetBP).Epoch;
    epcnt.value := ((net as TProgn).base_net as TNeuralNetBP).EpochCount;
    iner.value := ((net as TProgn).base_net as TNeuralNetBP).Momentum;
    err.value := ((net as TProgn).base_net as TNeuralNetBP).IdentError;
    pack_size.value := (net as TProgn).packet;
    //cont.checked:=((net as TProgn).base_net as TNeuralNetBP).ContinueTeach;
    Par1Change (nil);
    Par2Change (nil);
    
end;

procedure TOKRightDlg.epenClick (Sender: TObject);
begin
    epcnt.Enabled := epen.Checked;
end;

end.


