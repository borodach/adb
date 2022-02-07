unit ChartPropertiesForm;

interface

uses sharemem,
Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
StdCtrls, checklst, ComCtrls, ExtCtrls, Buttons, T_Net, dbtables, ChartForm, PredictionForm,
TeEngine, Series, RXCombos, RXSpin;

type
Series_Info = record
    l_s, l_w, l_c: Integer;
    l_s0, l_w0, l_c0: Integer;
    f_s, f_c: Integer;
    f_s0, f_c0: Integer;
    ch: Boolean;
    c_num: Integer;
end;
PS = ^Series_Info;
TDiagr = class (TForm)
    CheckListBox1: TCheckListBox;
    ComboBox1: TComboBox;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    ComboBox2: TComboBox;
    StaticText6: TStaticText;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText5: TStaticText;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    StaticText7: TStaticText;
    StaticText8: TStaticText;
    StaticText9: TStaticText;
    StaticText10: TStaticText;
    StaticText11: TStaticText;
    RxSpinEdit2: TRxSpinEdit;
    RxSpinEdit3: TRxSpinEdit;
    RxSpinEdit4: TRxSpinEdit;
    ColorComboBox1: TColorComboBox;
    RxSpinEdit1: TRxSpinEdit;
    ColorComboBox2: TColorComboBox;
    procedure ComboBox1DrawItem (Control: TWinControl; Index: Integer;
    Rect: TRect; State: TOwnerDrawState);
    procedure ComboBox2DrawItem (Control: TWinControl; Index: Integer;
    Rect: TRect; State: TOwnerDrawState);
    procedure FormCreate (Sender: TObject);
    procedure CheckListBox1Click (Sender: TObject);
    procedure FormDestroy (Sender: TObject);
    procedure ComboBox1Click (Sender: TObject);
    procedure ComboBox2Click (Sender: TObject);
    procedure Edit1Change (Sender: TObject);
    procedure Button5Click (Sender: TObject);
    procedure FormActivate (Sender: TObject);
    procedure Button4Click (Sender: TObject);
    procedure Button3Click (Sender: TObject);
    procedure CheckListBox1ClickCheck (Sender: TObject);
    procedure RadioButton1Click (Sender: TObject);
    procedure RxSpinEdit1Change (Sender: TObject);
    procedure ColorComboBox1Change (Sender: TObject);
    procedure ColorComboBox2Change (Sender: TObject);
    procedure RxSpinEdit4Change (Sender: TObject);
    procedure RxSpinEdit2Change (Sender: TObject);
    procedure RxSpinEdit3Change (Sender: TObject);
    procedure ComboBox2Change (Sender: TObject);
    procedure ComboBox1Change (Sender: TObject);
private
    { Private declarations }
public
    size: Integer;
    inf, t: PS;
    //c1,c2:TColor;
    procedure Make_Series (s: TChartSeries);
    procedure SetItems;
    procedure Apply;
    { Public declarations }
end;

var
Diagr: TDiagr;

implementation

uses PredictionReport;

{$R *.DFM}

procedure TDiagr.ComboBox1DrawItem (Control: TWinControl; Index: Integer;
Rect: TRect; State: TOwnerDrawState);
var br: TBrush;
pn: TPen;
begin
    br := TComboBox (Control).Canvas.Brush;
    pn := TComboBox (Control).Canvas.Pen;
    if (odSelected in State) then
    begin
        TComboBox (Control).Canvas.Brush.Color := clHighlight;
        TComboBox (Control).Canvas.Pen.Color := clHighlightText;
    end
    else
    begin
        TComboBox (Control).Canvas.Brush.Color := clWindow;
        TComboBox (Control).Canvas.Pen.Color := clWindowText;
    end;
    TComboBox (Control).Canvas.FillRect (Rect);
    
    TComboBox (Control).Canvas.Pen.Style := TPenStyle (Index);
    TComboBox (Control).Canvas.Pen.Width := 1;
    TComboBox (Control).Canvas.MoveTo (Rect.Left + 1, (Rect.Bottom + Rect.Top) shr 1);
    TComboBox (Control).Canvas.LineTo (Rect.Right - 1, (Rect.Bottom + Rect.Top) shr 1);
    
    TComboBox (Control).Canvas.Brush := br;
    TComboBox (Control).Canvas.Pen := pn;
end;

procedure TDiagr.ComboBox2DrawItem (Control: TWinControl; Index: Integer;
Rect: TRect; State: TOwnerDrawState);
var br: TBrush;
pn: TPen;
Color: TColor;
style: TBrushStyle;
begin
    br := TComboBox (Control).Canvas.Brush;
    pn := TComboBox (Control).Canvas.Pen;
    TComboBox (Control).Canvas.Pen.Style := psClear;
    Style := TBrushStyle (Index);
    if (odSelected in State) then
    begin
        Color := clHighlightText;
        TComboBox (Control).Canvas.Brush.Color := clHighlight;
    end
    else
    begin
        Color := clWindowText;
        TComboBox (Control).Canvas.Brush.Color := clWindow;
    end;
    
    TComboBox (Control).Canvas.Rectangle (Rect.left, rect.Top, rect.Right, rect.bottom);
    TComboBox (Control).Canvas.Brush.Color := Color;
    TComboBox (Control).Canvas.Brush.Style := Style;
    Dec (Rect.Bottom);
    Inc (Rect.Top, 1);
    Dec (Rect.Right);
    Inc (Rect.Left, 1);
    TComboBox (Control).Canvas.Rectangle (Rect.left, rect.Top, rect.Right, rect.bottom);
    TComboBox (Control).Canvas.Brush := br;
    TComboBox (Control).Canvas.Pen := pn;
end;



procedure TDiagr.FormCreate (Sender: TObject);
var i: Integer;
t: PS;
begin
    //c1:=clBlack;
    //c2:=clGreen;
    
    RXSpinEdit1.Enabled := False;
    size := TNet (Prognoz.p).Out_Count * Prognoz.len;
    inf := nil;
    GetMem (inf, sizeof (Series_Info) * size);
    t := inf;
    Randomize;
    ColorComboBox1.Enabled := false;
    for i := 0 to size - 1 do
    begin
        t.l_s0 := i mod 5;
        t.l_w0 := 1;
        t.l_c0 := TColor (ColorComboBox1.Items.Objects [Random (16)]);
        t.f_s0 := i mod 6;
        if t.f_s0 > 0 then Inc (t.f_s0);
        t.f_c0 := TColor (ColorComboBox1.Items.Objects [Random (16)]);
        t.c_num := 2 + (i div Prognoz.len ) * ((Prognoz.len shl 1) + 1) + ((i mod Prognoz.len)shl 1 + 1);
        t.ch := true;
        
        t.l_s := t.l_s0;
        t.l_w := t.l_w0;
        t.l_c := t.l_c0;
        t.f_s := t.f_s0;
        t.f_c := t.f_c0;
        
        CheckListBox1.Items.Add (Report1.Table1.Fields [t.c_num].FieldName);
        CheckListBox1.Checked [i] := true;
        Inc (t);
        
    end;
    ColorComboBox1.Enabled := true;
    for i := 0 to 5 do ComboBox1.Items.Add ('');
    for i := 0 to 7 do ComboBox2.Items.Add ('');
    RXSpinEdit2.Value := - 1;
    RXSpinEdit3.Value := 1;
    
    Apply;
    
end;
procedure TDiagr.SetItems;
var i: Integer;
e: Boolean;
begin
    i := CheckListBox1.ItemIndex;
    e := i <> - 1;
    // EnableWindow(b1,e);
    // EnableWindow(b2,e);
    ComboBox1.Enabled := e;
    ComboBox2.Enabled := e;
    RXSpinEdit1.Enabled := e;
    //Edit2.Enabled:=e;
    //Edit3.Enabled:=e;
    if not e then Exit;
    t := inf;
    Inc (t, i);
    //c1:=t.l_c;
    //c2:=t.f_c;
    ColorComboBox1.ColorValue := t.l_c;
    ColorComboBox2.ColorValue := t.f_c;
    RXSpinEdit1.Value := t.l_w;
    ComboBox1.ItemIndex := t.l_s;
    ComboBox2.ItemIndex := t.f_s;
    {  InvalidateRect(b1,nil,False);
          UpdateWindow(b1);
          InvalidateRect(b2,nil,False);
          UpdateWindow(b2);
        }
end;
procedure TDiagr.CheckListBox1Click (Sender: TObject);
begin
    SetItems;
end;

procedure TDiagr.FormDestroy (Sender: TObject);
begin
    if inf <> nil then FreeMem (inf, sizeof (Series_Info) * size);
    Close;
end;

procedure TDiagr.ComboBox1Click (Sender: TObject);
begin
    if not Button4.Enabled then Button4.Enabled := t.l_s <> ComboBox1.ItemIndex;
    t.l_s := ComboBox1.ItemIndex;
end;

procedure TDiagr.ComboBox2Click (Sender: TObject);
begin
    if not Button4.Enabled then Button4.Enabled := ComboBox2.ItemIndex <> t.f_s;
    t.f_s := ComboBox2.ItemIndex;
end;

procedure TDiagr.Edit1Change (Sender: TObject);
var i: Integer;
begin
    
end;

procedure TDiagr.Button5Click (Sender: TObject);
begin
    Close;
end;

procedure TDiagr.FormActivate (Sender: TObject);
var i: Integer;
begin
    t := inf;
    for i := 0 to size - 1 do
    begin
        t.l_s := t.l_s0;
        t.l_w := t.l_w0;
        t.l_c := t.l_c0;
        t.f_s := t.f_s0;
        t.f_c := t.f_c0;
        //CheckListBox1.Items.Add(Report1.Table1.Fields[t.c_num].FieldName);
        CheckListBox1.Checked [i] := t.ch;
        Inc (t);
    end;
    SetItems;
    Button4.Enabled := False;
end;


procedure TDiagr.Make_Series (s: TChartSeries);
var i, j, sz, col: Integer;
ar, tt: ^Double;
v, b, e: Double;
bl: Boolean;
begin
    e := 0;
    col := 0;
    bl := True;
    sz := trunc (RXSpinEdit4.Value);
    GetMem (ar, sizeof (double) * sz);
    try
        b := RXSpinEdit2.Value;
        except
        b := - 1;
    end;
    try
        e := RXSpinEdit3.Value;
        except
        b := 1;
    end;
    Report1.Table1.First;
    tt := ar;
    v := (e - b) / sz;
    for j := 0 to sz - 1 do
    begin
        tt^ := 0;
        Inc (tt);
    end;
    for j := 0 to (Prognoz.lst - Prognoz.fst) do
    begin
        if not Report1.Table1.Fields [t.c_num].IsNULL then
        begin
            i := Trunc ((Report1.Table1.Fields [t.c_num].AsFloat - b) / v);
            if (i >= 0)and (i < sz) then
            begin
                tt := ar;
                Inc (tt, i);
                tt^ := tt^ + 1;
                Inc (col);
            end;
        end;
        Report1.Table1.Next;
    end;
    tt := ar;
    if col > 0 then
    for j := 0 to sz - 1 do
    begin
        tt^ := tt^ / col;
        {if(j=0) then max:=tt^ else
                	 if tt^>max then max :=tt^;}
        s.AddXY (b + v * (j + 0.5), tt^ * sz, FloatToStr (b + v * (j + 0.5)), t.l_c);
        Inc (tt);
    end;
    
    //серия готова
    FreeMem (ar, sizeof (double) * sz);
end;


procedure TDiagr.Apply;
var i: Integer;
s, ttt: TChartSeries;
//max:Double;
begin
    //Edit4.Text:=IntToStr(StrToIntDef(Edit4.Text,10));
    t := inf;
    for i := 0 to size - 1 do
    begin
        t.l_s0 := t.l_s;
        t.l_w0 := t.l_w;
        t.l_c0 := t.l_c;
        t.f_s0 := t.f_s;
        t.f_c0 := t.f_c;
        t.ch := CheckListBox1.Checked [i];
        Inc (t);
    end;
    for i := 0 to Form3.Chat1.SeriesCount - 1 do
    begin
        ttt := Form3.Chat1.Series [0];
        Form3.Chat1.RemoveSeries (ttt);
        ttt.Free;
    end;
    
    t := inf;
    for i := 0 to size - 1 do // TChart
    begin
        if t.ch then
        begin
            if RadioButton1.Checked then
            begin
                s := TBarSeries.Create (Form3);
                TBarSeries (s).BarBrush.Color := t.f_c0;
                //TBarSeries(s).SeriesColor:=t.f_c0;
                TBarSeries (s).BarBrush.Style := TBrushStyle (t.f_s0);
                
                TBarSeries (s).BarPen.Color := t.l_c0;
                TBarSeries (s).BarPen.Style := TPenStyle (t.l_s0);
                TBarSeries (s).BarPen.Width := t.l_w0;
            end
            else
            begin
                s := TLineSeries.Create (Form3);
                TLineSeries (s).LinePen.Color := t.l_c0;
                TLineSeries (s).LinePen.Style := TPenStyle (t.l_s0);
                TLineSeries (s).LinePen.Width := t.l_w0;
            end;
            s.Title := CheckListBox1.Items.Strings [i];
            s.Marks.Visible := false;
            Report1.DataSource1.Enabled := false;
            Make_Series (s);
            Report1.DataSource1.Enabled := true;
            {f i=0 then max:=c else
                               if c>max then max:=c;}
            Form3.Chat1.AddSeries (s);
        end;
        
        Inc (t);
    end;
    SetItems;
end;
procedure TDiagr.Button4Click (Sender: TObject);
begin
    Apply;
    Button4.Enabled := False;
end;

procedure TDiagr.Button3Click (Sender: TObject);
begin
    Close;
    Apply;
end;

procedure TDiagr.CheckListBox1ClickCheck (Sender: TObject);
begin
    Button4.Enabled := True;
end;

procedure TDiagr.RadioButton1Click (Sender: TObject);
begin
    Button4.Enabled := True;
end;

procedure TDiagr.RxSpinEdit1Change (Sender: TObject);
var i: integer;
begin
    i := trunc (RXSpinEdit1.Value);
    if (RXSpinEdit1.Enabled) then
    begin
        if not Button4.Enabled then Button4.Enabled := t.l_w <> i;
        t.l_w := i;
    end;
end;

procedure TDiagr.ColorComboBox1Change (Sender: TObject);
begin
    t.l_c := ColorComboBox1.ColorValue;
    Button4.Enabled := True;
end;

procedure TDiagr.ColorComboBox2Change (Sender: TObject);
begin
    t.f_c := ColorComboBox2.ColorValue;
end;

procedure TDiagr.RxSpinEdit4Change (Sender: TObject);
begin
    Button4.Enabled := True;
end;

procedure TDiagr.RxSpinEdit2Change (Sender: TObject);
begin
    Button4.Enabled := True;
end;

procedure TDiagr.RxSpinEdit3Change (Sender: TObject);
begin
    Button4.Enabled := True;
end;

procedure TDiagr.ComboBox2Change (Sender: TObject);
begin
    Button4.Enabled := True;
end;

procedure TDiagr.ComboBox1Change (Sender: TObject);
begin
    Button4.Enabled := True;
end;

end.


