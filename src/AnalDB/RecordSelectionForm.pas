unit RecordSelectionForm;

interface

uses sharemem,
Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
StdCtrls, ComCtrls, Mask, RXSpin;

type
TInter = class (TForm)
    Button1: TButton;
    Button2: TButton;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    Edit1: TRxSpinEdit;
    Edit2: TRxSpinEdit;
    procedure Button1Click (Sender: TObject);
    procedure Button2Click (Sender: TObject);
    procedure FormActivate (Sender: TObject);
    procedure Edit2Change (Sender: TObject);
    procedure Edit1Change (Sender: TObject);
private
    { Private declarations }
public
    b, e: ^Integer;
    procedure Init (aa, bb: Pointer);
    { Public declarations }
end;

var
Inter: TInter;

implementation

{$R *.DFM}
procedure TInter.Init (aa, bb: Pointer);
begin
    b := aa;
    e := bb;
end;
procedure TInter.Button1Click (Sender: TObject);
begin
    b^ := trunc (Edit1.Value);
    e^ := trunc (Edit2.Value);
    ModalResult := 1;
end;

procedure TInter.Button2Click (Sender: TObject);
begin
    ModalResult := - 1;
end;

procedure TInter.FormActivate (Sender: TObject);
begin
    Edit1.MinValue := b^;
    Edit1.MaxValue := e^;
    Edit2.MinValue := b^;
    Edit2.MaxValue := e^;
    Edit1.Value := b^;
    Edit2.Value := e^;
end;

procedure TInter.Edit2Change (Sender: TObject);
var i, j: Integer;
begin
    i := StrToIntDef (Edit2.Text, e^);
    j := StrToIntDef (Edit1.Text, b^);
    if i < j then Edit1.Text := IntToStr (i);
    if i > e^ then Edit2.Text := IntToStr (e^);
end;

procedure TInter.Edit1Change (Sender: TObject);
var i, j: Integer;
begin
    i := StrToIntDef (Edit2.Text, e^);
    j := StrToIntDef (Edit1.Text, b^);
    if i < j then Edit2.Text := IntToStr (j);
end;
end.


