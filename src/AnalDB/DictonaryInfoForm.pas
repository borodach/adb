unit DictonaryInfoForm;

interface

uses
sharemem, Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
StdCtrls, Dictonary, dyn_array, main, doswin;

type
TDict_Param_Form = class (TForm)
    GroupBox3: TGroupBox;
    GroupBox2: TGroupBox;
    Static1: TStaticText;
    F_Type: TStaticText;
    GroupBox1: TGroupBox;
    Names: TComboBox;
    Values: TListBox;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    StaticText5: TStaticText;
    FieldsCount: TStaticText;
    ValuesCount: TStaticText;
    AllCount: TStaticText;
    StaticText6: TStaticText;
    StaticText7: TStaticText;
    Date: TStaticText;
    Siz: TStaticText;
    OkButton: TButton;
    StaticText8: TStaticText;
    NetCount: TStaticText;
    StaticText1: TStaticText;
    procedure OkButtonClick (Sender: TObject);
    procedure NamesChange (Sender: TObject);
    procedure UpdateV (i: Integer);
    procedure FormShow (Sender: TObject);
private
    { Private declarations }
public
    p: Dict;
    { Public declarations }
end;

var
oDict_Param_Form: TDict_Param_Form;

implementation

{$R *.DFM}

procedure TDict_Param_Form.OkButtonClick (Sender: TObject);
begin
    Close;
end;

procedure TDict_Param_Form.UpdateV (i: Integer);
type pint = ^Integer;
pfl = ^double;
pc = ^currency;
var j: Integer;
t: Pole;
st: string;
begin
    Values.Clear;
    t := p.GetField (i);
    case t.F_Type of
        0:
        begin;
            F_Type.Caption := 'Целые числа';
            for j := 0 to t.voc.pos do
            begin
                Values.Items.Add (IntToStr (PInt (t.voc.GetP (j))^));
            end;
        end;
        1:
        begin
            F_Type.Caption := 'Дробные числа';
            for j := 0 to t.voc.pos do
            begin
                Values.Items.Add (FloatToStr (PFl (t.voc.GetP (j))^));
            end;
        end;
        2:
        begin
            F_Type.Caption := 'Денежный';
            for j := 0 to t.voc.pos do
            begin
                Values.Items.Add (CurrToStr (PC (t.voc.GetP (j))^));
            end;
        end;
        3:
        begin
            F_Type.Caption := 'Строки';
            for j := 0 to t.voc.pos do
            begin
                if pr.DW then st := DosToWinStr (PChar (t.voc.GetP (j)^), 65535)
                else
                st := PChar (t.voc.GetP (j)^);
                Values.Items.Add (st);
            end;
        end;
    end;
    ValuesCount.Caption := IntToStr (t.voc.pos + 1);
    ValuesCount.Show;
    F_Type.Show;
    Values.Show;
end;
procedure TDict_Param_Form.NamesChange (Sender: TObject);
begin
    UpdateV (Names.ItemIndex);
end;

procedure TDict_Param_Form.FormShow (Sender: TObject);
type PPole = ^Pole;
var i, j: Integer;
t: PPole;
begin
    j := 0;
    t := p._fields;
    Names.Clear;
    for i := 1 to p.Count do
    begin
        Names.Items.Add (t.name);
        Inc (j, t.voc.pos + 1);
        Inc (t);
    end;
    Names.ItemIndex := 0;
    FieldsCount.Caption := IntToStr (p.Count);
    Date.Caption := DateTimeToStr (p.dt);
    Siz.Caption := IntToStr (p.sz);
    NetCount.Caption := IntToStr (p.Nets_Count);
    AllCount.Caption := IntToStr (j);
    UpdateV (0);
    AllCount.Update;
    FieldsCount.Update;
    Date.Update;
    Siz.Update;
    NetCount.Update;
    Names.Update;
end;
end.


