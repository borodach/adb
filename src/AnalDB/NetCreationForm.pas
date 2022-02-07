unit NetCreationForm;

interface

uses sharemem,
Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
StdCtrls, ExtCtrls, T_Net, dyn_array, Dictonary, checklst, RXCtrls, RXSpin,
Math;

type
PField = ^Field_View;
TCreateForm = class (TForm)
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    addButton: TButton;
    addtButton: TButton;
    StaticText4: TStaticText;
    StaticText5: TStaticText;
    StaticText6: TStaticText;
    StaticText8: TStaticText;
    Edit1: TEdit;
    Edit2: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    RadioGroup1: TRadioGroup;
    StaticText7: TStaticText;
    StaticText9: TStaticText;
    Button1: TButton;
    RadioButton1: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    Button2: TButton;
    StaticText10: TStaticText;
    StaticText11: TStaticText;
    StaticText12: TStaticText;
    StaticText13: TStaticText;
    StaticText14: TStaticText;
    addButton1: TButton;
    addtButton1: TButton;
    delButton: TButton;
    delButton1: TButton;
    RadioButton2: TRadioButton;
    Label1: TLabel;
    ListBox5: TTextListBox;
    ListBox4: TTextListBox;
    ListBox1: TTextListBox;
    ListBox2: TTextListBox;
    ListBox3: TTextListBox;
    StaticText15: TStaticText;
    StaticText16: TStaticText;
    intMinVal: TRxSpinEdit;
    intStep: TRxSpinEdit;
    intCount: TRxSpinEdit;
    trend: TRxSpinEdit;
    ComboBox1: TComboBox;
    Label2: TLabel;
    procedure FormActivate (Sender: TObject);
    procedure ListBox4Click (Sender: TObject);
    procedure ListBox5Click (Sender: TObject);
    procedure RadioButton1Click (Sender: TObject);
    procedure add1ButtonClick (Sender: TObject);
    procedure addtButtonClick (Sender: TObject);
    procedure Button3Click (Sender: TObject);
    procedure addButtonClick (Sender: TObject);
    procedure addtButton1Click (Sender: TObject);
    procedure delButton1Click (Sender: TObject);
    procedure delButtonClick (Sender: TObject);
    procedure Edit3Change (Sender: TObject);
    procedure Button2Click (Sender: TObject);
    procedure Button1Click (Sender: TObject);
    procedure RadioButton2Click (Sender: TObject);
    procedure RadioButton3Click (Sender: TObject);
    procedure RadioButton4Click (Sender: TObject);
    procedure Edit4Change (Sender: TObject);
    procedure ListBox1Click (Sender: TObject);
    procedure ListBox2Click (Sender: TObject);
    procedure ListBox3Click (Sender: TObject);
    procedure FormCreate (Sender: TObject);
    procedure ListBox2DragOver (Sender, Source: TObject; X, Y: Integer;
    State: TDragState; var Accept: Boolean);
    procedure ListBox1DragDrop (Sender, Source: TObject; X, Y: Integer);
    procedure ListBox2DragDrop (Sender, Source: TObject; X, Y: Integer);
    procedure ListBox3DragDrop (Sender, Source: TObject; X, Y: Integer);
    procedure ListBox2DblClick (Sender: TObject);
    
    procedure CreateInterval (f: PField);
    procedure ComboBox1Click (Sender: TObject);
    
    
private
    { Private declarations }
    procedure IntervalEnable (e: Boolean);
    procedure TrendEnable (e: Boolean);
public
    { Public declarations }
    ar: array [0..512] of Integer;
    sz: Integer;
    fl: Boolean;
    net: TNet;
    procedure Check_Ready;
    procedure InitDLLs;
    procedure SetRadioStatus;
    procedure on_focus (var msg: TMessage);message WM_Command;
    procedure show_info (lb: TTextlistBox; t: PField;b: TButton);
    procedure hide_info;
    procedure OnSelCh;
    procedure Add (io, t: Boolean);
    procedure Del (io: Boolean);
    
    procedure initTemplate (t: Integer);
    procedure copyTemplate (t: Integer);
    
    
end;

var
CreateForm: TCreateForm;

implementation

uses MainForm, main;
var md: Boolean;

{$R *.DFM}

/////////////////////////////////////////////////////////////////////////

procedure TCreateForm.IntervalEnable (e: Boolean);
var t: PField;
p: Pole;
tp: TValueType;
begin
    intCount.Enabled := e;
    intCount.Visible := e;
    intMinVal.Enabled := e;
    intMinVal.Visible := e;
    intStep.Enabled := e;
    intStep.Visible := e;
    
    if e then
    begin
        if fl then
        begin
            t := (net.In_Fields);
            Inc (t, listbox2.ItemIndex);
        end
        else
        begin
            t := PField (net.Out_Fields);
            Inc (t, listbox3.ItemIndex);
        end;
        if t.Num < 0 then Exit;
        p := Dict (net._parent).GetField (t.Num - 1);
        tp := vtFloat;
        if p.F_Type = 0 then tp := vtInteger;
        intMinVal.ValueType := tp;
        intStep.ValueType := tp;
    end;
    
end;

/////////////////////////////////////////////////////////////////////////

procedure TCreateForm.TrendEnable (e: Boolean);
begin
trend.Enabled := e;
trend.Visible := e;
end;


/////////////////////////////////////////////////////////////////////////

procedure TCreateForm.Check_Ready;
begin
    Button1.Enabled := (listbox4.ItemIndex >= 0) and (net.In_Count > 0)and
    (
    ((radiobutton1.Checked)and (net.Out_Count > 0)) or
    ((radiobutton2.Checked)and (net.Out_Count = 1)) or
    (radiobutton3.Checked) or
    (radiobutton4.Checked)
    );
end;

/////////////////////////////////////////////////////////////////////////

procedure TCreateForm.Add (io, t: Boolean);
var i: Integer;
begin
    if (not io) and (radiobutton2.Checked)then listbox3.Items.Clear;
    for i := 0 to listbox1.Items.count - 1 do
    if listbox1.Selected [i] then
    if io then
    begin
        if t then listbox2.Items.Add ('Тренд ' + listbox1.Items.strings [i])
        else listbox2.Items.Add (listbox1.Items.strings [i]);
        net.AddIn (i + 1, t);
    end
    else
    begin
        if t then listbox3.Items.Add ('Тренд ' + listbox1.Items.strings [i])
        else listbox3.Items.Add (listbox1.Items.strings [i]);
        net.AddOut (i + 1, t);
        if radiobutton2.Checked then break;
    end;
    Check_Ready;
end;

/////////////////////////////////////////////////////////////////////////

procedure TCreateForm.Del (io: Boolean);
var i: Integer;
begin
    i := 0;
    if io then
    begin
        while (i < listbox2.Items.Count) do
        if listbox2.Selected [i] then
        begin
            listbox2.Items.Delete (i);
            net.DelIn (i);
        end
        else inc (i);
        DelButton.Enabled := listbox2.Items.Count >= 1;
        if DelButton.Enabled then listbox2.Selected [0] := True;
    end
    else
    begin
        while (i < listbox3.Items.Count) do
        if listbox3.Selected [i] then
        begin
            listbox3.Items.Delete (i);
            net.DelOut (i);
        end
        else inc (i);
        
        DelButton1.Enabled := listbox3.Items.Count >= 1;
        if DelButton1.Enabled then listbox3.Selected [0] := True;
    end;
    Check_Ready;
end;

/////////////////////////////////////////////////////////////////////////

procedure TCreateForm.Hide_Info;
begin
    IntervalEnable (False);
    //##Edit3.Text:='Не активно.';
    //##Edit4.Enabled:=False;
    //##Edit4.Text:='Не активно.';
    TrendEnable (False);
    StaticText13.Caption := '-';
    StaticText13.Caption := '-';
end;

/////////////////////////////////////////////////////////////////////////

procedure TCreateForm.Show_Info (lb: TTextListBox;t: PField;b: TButton);
var p: Pole;
p1, p2: Pointer;
begin
    b.Enabled := lb.SelCount >= 1;
    if (lb.SelCount <> 1)or ((radiobutton2.Checked)and (lb = listbox3)) then
    begin
        Hide_Info;
        Exit;
    end;
    if lb = listbox2 then IntervalEnable (not RadioButton2.Checked)
    else IntervalEnable (RadioButton1.Checked);
    Inc (t, lb.ItemIndex);
    //##Edit3.Text:=IntToStr(t.Count);
    md := false;
    intCount.Value := t.cnt;
    intMinVal.Value := t.minVal;
    intStep.Value := t.dt;
    md := true;
    
    if (t.Num < 0) then
    begin
        StaticText13.Caption := '-';
        StaticText14.Caption := '-';
        //##Edit3.text:='Не активно.';
        IntervalEnable (False);
        trendEnable (true);
        //##Edit4.Text:=FloatToStr(t.porog*100);
        //##Edit4.Enabled:=True;
    trend.Value := t.porog * 100;
    
    
    Exit;
end
else
begin
    trendEnable (False);
    //##Edit4.Text:='Не активно.';
    //##Edit4.Enabled:=False;
end;

p := Dict (net._parent).GetField (t.Num - 1);
p1 := p.voc.GetP (0);
p2 := p.voc.GetP (p.voc.pos);
case p.F_Type of
    0:
    begin
        StaticText13.Caption := IntToStr (Integer (p1^));
        StaticText14.Caption := IntToStr (Integer (p2^));
        //IntervalEnable:=False;
    end;
    1:
    begin
        StaticText13.Caption := FloatToStr (double (p1^));
        StaticText14.Caption := FloatToStr (double (p2^));
        
    end;
    2:
    begin
        StaticText13.Caption := CurrToStr (currency (p1^));
        StaticText14.Caption := CurrToStr (currency (p2^));
        
    end;
    else
    begin
        StaticText13.Caption := '-';
        StaticText14.Caption := '-';
        //##Edit3.text:='Не активно.';
        addtbutton.Enabled := false;
        addtbutton1.Enabled := false;
        IntervalEnable (false);
        Exit;
    end;
end;
//IntervalEnable(True);
end;


/////////////////////////////////////////////////////////////////////////

procedure TCreateForm.on_focus (var msg: TMessage);
var i: Integer;
begin
    if (msg.WParamLo = GetDlgCtrlID (listbox2.handle)) and ((msg.wparamhi = 4) or (msg.wparamhi = LBN_SELCHANGE )) then
    begin
        fl := True;
        for i := 0 to listbox3.Items.Count - 1 do Listbox3.Selected [i] := False;
        show_info (listbox2, PField (net.In_Fields), DelButton);
    end;
    if (msg.WParamLo = GetDlgCtrlID (listbox3.handle)) and ((msg.wparamhi = 4) or (msg.wparamhi = LBN_SELCHANGE )) then
    begin
        fl := False;
        for i := 0 to listbox2.Items.Count - 1 do Listbox2.Selected [i] := False;
        show_info (listbox3, PField (net.Out_Fields), DelButton1);
    end;
    if (msg.WParamLo = GetDlgCtrlID (listbox1.handle)) and (msg.wparamhi = LBN_SELCHANGE)
    then
    begin
        //##Edit4.text:='Не активно.';
        //##edit4.enabled:=false;
        trendEnable (false);
        OnSelCh;
    end;
    
    inherited;
end;

/////////////////////////////////////////////////////////////////////////

procedure TCreateForm.InitDLLs;
//InfoProc=function(p:Pointer): Integer;stdcall;
type pr = function (p: Pointer): Integer;stdcall;
var f, ld: Integer;
ts: TSearchRec;
s: PChar;
func: InfoProc;
begin
    ListBox5.Clear;
    ListBox4.Clear;
    sz := 0;
    f := FindFirst ('*.dll', faAnyFile, ts);
    while f = 0 do
    begin
        ld := LoadLibrary (PChar (ts.name));
        if ld > 31 then
        begin
            func := GetProcAddress (ld, 'Who_Are_You');
            if Addr (func) <> nil then
            begin
                ar [sz] := func (@s);
                Inc (sz);
                ListBox5.Items.Add (string (s));
                ListBox4.Items.Add (ExtractFileName (ts.name));
            end;
            FreeLibrary (ld);
        end;
        f := FindNext (ts);
    end;
    FindClose (ts);
end;

/////////////////////////////////////////////////////////////////////////

procedure TCreateForm.SetRadioStatus;
var i: Integer;
begin
    i := listbox4.ItemIndex;
    if i < 0 then
    begin
        RadioButton1.Checked := False;
        RadioButton2.Checked := False;
        RadioButton3.Checked := False;
        RadioButton4.Checked := False;
        RadioButton1.Enabled := False;
        RadioButton2.Enabled := False;
        RadioButton3.Enabled := False;
        RadioButton4.Enabled := False;
        Exit;
    end;
    RadioButton1.Enabled := (ar [i] and 1) <> 0;
    RadioButton2.Enabled := (ar [i] and 2) <> 0;
    RadioButton3.Enabled := (ar [i] and 4) <> 0;
    RadioButton4.Enabled := (ar [i] and 8) <> 0;
    if RadioButton1.Enabled then RadioButton1.Checked := true
    else
    if RadioButton2.Enabled then RadioButton2.Checked := true
    else
    if RadioButton3.Enabled then RadioButton3.Checked := true
    else
    if RadioButton4.Enabled then RadioButton4.Checked := true;
end;

/////////////////////////////////////////////////////////////////////////

procedure TCreateForm.FormActivate (Sender: TObject);
var i: Integer;
t: ^Pole;
var baseName: String;
begin
    
    if (Dict (net._parent).file_name <> nil)
    then baseName := Copy (Dict (net._parent).file_name,
    0,
    length (Dict (net._parent).file_name ) -
    length (ExtractFileExt (Dict (net._parent).file_name ) )
    )
    else baseName := 'Dict';
    
    baseName := baseName + '_net.nnt';
    
    InitDlls;
    InitTemplate (- 1);
    SetRadioStatus;
    DelButton.Enabled := False;
    DelButton1.Enabled := False;
    ListBox1.Clear;
    ListBox2.Clear;
    ListBox3.Clear;
    //##Edit3.Text:='Не активно';
    IntervalEnable (False);
    staticText13.Caption := '-';
    staticText14.Caption := '-';
    Edit1.Text := '';
    Edit2.Text := pr.GetUniqueDictName (baseName );
    Button1.Enabled := False;
    t := Dict (net._parent)._fields;
    for i := 1 to Dict (net._parent).Count do
    begin
        if t.tr_num < 0 then break;
        ListBox1.Items.Add (t.name);
        Inc (t);
    end;
    OnSelCh;
end;

/////////////////////////////////////////////////////////////////////////

procedure TCreateForm.ListBox4Click (Sender: TObject);
begin
    ListBox5.ItemIndex := ListBox4.ItemIndex;
    SetRadioStatus;
    OnSelCh;
    Check_Ready;
end;

/////////////////////////////////////////////////////////////////////////

procedure TCreateForm.ListBox5Click (Sender: TObject);
begin
    ListBox4.ItemIndex := ListBox5.ItemIndex;
    SetRadioStatus;
    OnSelCh;
    Check_Ready;
end;

/////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////

procedure TCreateForm.add1ButtonClick (Sender: TObject);
begin
    Add (false, False);
end;

/////////////////////////////////////////////////////////////////////////

procedure TCreateForm.addtButtonClick (Sender: TObject);
begin
    Add (true, true);
end;

/////////////////////////////////////////////////////////////////////////

procedure TCreateForm.Button3Click (Sender: TObject);
var i: Integer;
begin
    i := ListBox3.ItemIndex;
    if i < 0 then Exit;
    ListBox1.Items.Add (ListBox3.Items.Strings [i]);
    ListBox3.Items.Delete (i);
end;

/////////////////////////////////////////////////////////////////////////

procedure TCreateForm.addButtonClick (Sender: TObject);
begin
    Add (true, false);
end;

/////////////////////////////////////////////////////////////////////////

procedure TCreateForm.addtButton1Click (Sender: TObject);
begin
    Add (false, true);
end;

/////////////////////////////////////////////////////////////////////////

procedure TCreateForm.delButton1Click (Sender: TObject);
begin
    Del (false);
end;

/////////////////////////////////////////////////////////////////////////

procedure TCreateForm.delButtonClick (Sender: TObject);
begin
    Del (true);
end;

/////////////////////////////////////////////////////////////////////////

procedure TCreateForm.Edit3Change (Sender: TObject);
var j: integer;
t: PField;
begin
    //##j:=StrToIntDef(Edit3.Text,-1);
    //j:=tDef(Edit3.Text,-1);
    // if j<0 then Exit;
    if not md then exit;
    if fl then
    begin
        t := (net.In_Fields);
        Inc (t, listbox2.ItemIndex);
    end
    else
    begin
        t := PField (net.Out_Fields);
        Inc (t, listbox3.ItemIndex);
    end;
    try
        t.dt := intStep.Value;
        t.minVal := intminVal.Value;
        t.cnt := trunc (intCount.Value);
        except
        intStep.Value := t.dt;
        intminVal.Value := t.minVal;
        intCount.Value := t.cnt;
    end;
    
end;

/////////////////////////////////////////////////////////////////////////

procedure TCreateForm.Button2Click (Sender: TObject);
begin
    ModalResult := 2;
end;

/////////////////////////////////////////////////////////////////////////

procedure TCreateForm.Button1Click (Sender: TObject);
begin
    
    if not (pr.IsDictNameUnique (Edit2.Text)) then
    begin
        MessageBox (handle, 'Имя файла введено некорректно. Оно либо отсутствует, либо совпадает с уже существующим.', 'Предупреждение.', 0);
        Edit2.Text := pr.GetUniqueDictName (Edit2.Text);
        Edit2.SetFocus;
        ModalResult := 0;
        Exit;
    end;
    
    
    if (radiobutton1.Checked) then net._type := 0;
    if (radiobutton2.Checked) then net._type := 1;
    if (radiobutton3.Checked) then net._type := 2;
    if (radiobutton4.Checked) then net._type := 3;
    try
        net.rem := myStrNew (PChar (Edit1.Text));
        net.file_name := myStrNew (PChar (Edit2.Text));
        net.dll_file_name := myStrNew (PChar (ListBox4.Items.strings [listbox4.ItemIndex]));
        ModalResult := 1;
        except
        on e: EOutOfMemory do
        begin
            MessageBox (Handle, PChar (e.Message), PChar ('Ошибка копирования данных.'), 0);
            ModalResult := 2;
        end;
        {    on e:Exception do
                      begin
                	MessageBox(Handle,PChar(e.Message),PChar('Не все параметры определены.'),0);
                	ModalResult:=0;
                      end;}
    end;
end;


procedure TCreateForm.RadioButton1Click (Sender: TObject);
begin
    OnSelCh;
    initTemplate (1);
    Check_Ready;
    
end;

procedure TCreateForm.RadioButton2Click (Sender: TObject);
var i: Integer;
t: PField;
begin
    initTemplate (2);
    if not fl then intervalEnable (false);
    
    trendEnable (false);
    t := (net.In_Fields);
    for i := 0 to listbox2.Items.Count - 1 do
    begin
        listbox2.Selected [i] := (t.Num < 0);
        Inc (t);
    end;
    Del (true);
    
    for i := 0 to listbox3.Items.Count - 1 do
    listbox3.Selected [i] := i <> 0;
    
    t := (net.Out_Fields);
    if t <> nil then
    begin
        //##t.Count:=0;
        t.porog := 0;
        if (t.Num < 0) then
        begin
            listbox3.Items [0] := Copy (listbox3.Items [0], 7, 1024);
            t.Num := - t.Num;
        end;
        
        if (t.cnt > 0) then
        begin
            t.cnt := 0;
            t.dt := 0;
            t.minVal := 0;
            t.frozen := 0;
            t.initialized := 0;
            
            
        end;
        
    end;
    Del (false);
    OnSelCh;
    Check_Ready;
end;

procedure TCreateForm.RadioButton3Click (Sender: TObject);
var t: PField;
i: Integer;
begin
    initTemplate (3);
    if not fl then intervalEnable (false);
    
    trendEnable (false);
    t := (net.In_Fields);
    for i := 0 to listbox2.Items.Count - 1 do
    begin
        listbox2.Selected [i] := t.Num < 0;
        Inc (t);
    end;
    Del (true);
    
    FreeMem (net.Out_Fields, net.Out_Count * sizeof (Field_View));
    net.Out_Fields := nil;
    net.Out_Count := 0;
    listbox3.Items.Clear;
    OnSelCh;
    Check_Ready;
end;

/////////////////////////////////////////////////////////////////////////

procedure TCreateForm.OnSelCh;
var i: Integer;
f: Boolean;
begin
    if listbox1.SelCount <= 0 then
    begin
        addButton.Enabled := False;
        addtButton.Enabled := False;
        addButton1.Enabled := False;
        addtButton1.Enabled := False;
        Exit;
    end;
    addButton.Enabled := True;
    addButton1.Enabled := (RadioButton1.Checked)or (RadioButton2.Checked);
    
    addtButton.Enabled := RadioButton1.Checked;
    addtButton1.Enabled := RadioButton1.Checked;
    for i := 0 to listbox1.Items.count - 1 do
    if listbox1.Selected [i] then
    if Pole (Dict (net._parent).GetField (i)).F_Type = 3 then
    begin
        addtButton.Enabled := False;
        addtButton1.Enabled := False;
        Exit;
    end;
    
end;
procedure TCreateForm.RadioButton4Click (Sender: TObject);
var t: PField;
i: Integer;
begin
    
    initTemplate (4);
    if not fl then intervalEnable (false);
    
    trendEnable (false);
    t := (net.In_Fields);
    for i := 0 to listbox2.Items.Count - 1 do
    begin
        listbox2.Selected [i] := t.Num < 0;
        Inc (t);
    end;
    Del (true);
    
    FreeMem (net.Out_Fields, net.Out_Count * sizeof (Field_View));
    net.Out_Fields := nil;
    net.Out_Count := 0;
    listbox3.Items.Clear;
    OnSelCh;
    Check_Ready;
end;

procedure TCreateForm.Edit4Change (Sender: TObject);
var j: double;
t: PField;
begin
    if fl then
    begin
        if listbox2.ItemIndex < 0 then exit;
        t := (net.In_Fields);
        Inc (t, listbox2.ItemIndex);
    end
    else
    begin
        if listbox3.ItemIndex < 0 then exit;
        t := PField (net.Out_Fields);
        Inc (t, listbox3.ItemIndex);
    end;
    //##j:=t.porog*100;
    try
        begin
            //##j:=StrToFloat(Edit4.Text);
        t.porog := trend.Value / 100;
    end;
    except
    on e: Exception do
    begin
    trend.Value := t.porog * 100;
end;

//##   trend.value:=j;
end;


end;

procedure TCreateForm.ListBox1Click (Sender: TObject);
var i: Integer;
begin
    //##Edit4.text:='Не активно.';
    //##edit4.enabled:=false;
    trendEnable (false);
    
    if listbox1.SelCount > 0 then listbox1.DragMode := dmAutomatic
    else listbox1.DragMode := dmManual;
    
    OnSelCh;
end;
procedure TCreateForm.ListBox2Click (Sender: TObject);
var i: Integer;
begin
    fl := True;
    
    if listbox2.SelCount > 0 then listbox2.DragMode := dmAutomatic
    else listbox2.DragMode := dmManual;
    
    for i := 0 to listbox3.Items.Count - 1 do Listbox3.Selected [i] := False;
    show_info (listbox2, PField (net.In_Fields), DelButton);
end;

procedure TCreateForm.ListBox3Click (Sender: TObject);
var i: Integer;
begin
    fl := False;
    
    if listbox3.SelCount > 0 then listbox3.DragMode := dmAutomatic
    else listbox3.DragMode := dmManual;
    
    for i := 0 to listbox2.Items.Count - 1 do Listbox2.Selected [i] := False;
    show_info (listbox3, PField (net.Out_Fields), DelButton1);
end;


procedure TCreateForm.FormCreate (Sender: TObject);
begin
    md := true;
end;

procedure TCreateForm.ListBox2DragOver (Sender, Source: TObject; X,
Y: Integer; State: TDragState; var Accept: Boolean);
begin
    Accept := source <> Sender;
end;

procedure TCreateForm.ListBox1DragDrop (Sender, Source: TObject; X,
Y: Integer);
begin
    Del (Source = ListBox2)
end;

procedure TCreateForm.ListBox2DragDrop (Sender, Source: TObject; X,
Y: Integer);
var src, dst: PField;
i: Integer;
begin
    if Source = ListBox1 then Add (true, false)
    else
    begin
        src := net.Out_Fields;
        for i := 0 to listbox3.Items.Count - 1 do
        begin
            if Listbox3.Selected [i] then
            begin
                with (net) do
                begin
                    begin
                        ReallocMem (In_Fields, sizeof (Field_View) * (In_Count + 1));
                        dst := In_Fields;
                        Inc (dst, In_Count);
                        Inc (In_Count);
                        dst.Num := src.Num;
                        dst.porog := src.porog;
                        dst.dt := src.dt;
                        dst.minVal := src.minVal;
                        dst.cnt := src.Cnt;
                        ListBox2.Items.Add (ListBox3.Items [i]);
                    end;
                end;
            end;
            Inc (src);
        end;
        Check_Ready;
    end;
    
    
end;

procedure TCreateForm.ListBox3DragDrop (Sender, Source: TObject; X,
Y: Integer);
var src, dst: PField;
i: Integer;
begin
    if not RadioButton1.Enabled then exit;
    if RadioButton3.Checked then exit;
    if RadioButton4.Checked then exit;
    
    
    if Source = ListBox1 then
    begin
        Add (false, false)
    end
    else
    begin
        
        src := net.In_Fields;
        for i := 0 to listbox2.Items.Count - 1 do
        begin
            if Listbox2.Selected [i] then
            with (net) do
            begin
                if ((RadioButton1.Checked) or
                (
                (src.Num > 0) and
                (src.Cnt = 0) and
                (ListBox3.Items.Count = 0)
                )
                ) then
                begin
                    ReallocMem (Out_Fields, sizeof (Field_View) * (Out_Count + 1));
                    dst := Out_Fields;
                    Inc (dst, Out_Count);
                    Inc (Out_Count);
                    dst.Num := src.Num;
                    dst.porog := src.porog;
                    dst.dt := src.dt;
                    dst.minVal := src.minVal;
                    dst.cnt := src.Cnt;
                    ListBox3.Items.Add (ListBox2.Items [i]);
                    if not RadioButton1.Checked then Exit;
                end;
            end;
            Inc (src);
        end;
        Check_Ready;
    end;
end;

procedure TCreateForm.ListBox2DblClick (Sender: TObject);
var t: PField;
begin
    if Sender = ListBox2 then
    begin
        if listbox2.ItemIndex < 0 then exit;
        t := (net.In_Fields);
        Inc (t, listbox2.ItemIndex);
        CreateInterval (t);
        ListBox2Click (Sender);
    end
    else
    begin
        if listbox3.ItemIndex < 0 then exit;
        t := PField (net.Out_Fields);
        Inc (t, listbox3.ItemIndex);
        CreateInterval (t);
        ListBox3Click (Sender);
    end;
end;

procedure TCreateForm.CreateInterval (f: PField);
var p: Pole;
p1, p2: Pointer;

tmp: Double;

begin
    if f.Num < 0 then exit;
    p := Dict (net._parent).GetField (f.Num - 1);
    if p.F_Type = 3 then exit;
    
    if ((f.dt = 0) and (f.Cnt = 0)) or (f.Num < 0 ) then exit;
    
    f.porog := 0;
    f.frozen := 0;
    f.initialized := 0;
    
    p1 := p.voc.GetP (0);
    p2 := p.voc.GetP (p.voc.pos);
    
    case p.F_Type of
        0:
        begin
            f.minVal := (Integer (p1^));
            if f.dt > 0 then
            f.cnt := Ceil ((Integer (p2^) - Integer (p1^)) / f.dt)
            else
            f.dt := (Integer (p2^) - Integer (p1^)) / f.cnt;
            //IntervalEnable:=False;
        end;
        1:
        begin
            f.minVal := double (p1^);
            if f.dt > 0 then
            f.cnt := Ceil ((double (p2^) - double (p1^)) / f.dt)
            else
            f.dt := (double (p2^) - double (p1^)) / f.cnt;
            
        end;
        2:
        begin
            f.minVal := currency (p1^);
            if f.dt > 0 then
            f.cnt := Ceil ((currency (p2^) - currency (p1^)) / f.dt)
            else
            f.dt := (currency (p2^) - currency (p1^)) / f.cnt;
        end;
        
    end;
    
    p1 := p.voc.GetP (0);
    p2 := p.voc.GetP (p.voc.pos);
    
    
end;


procedure TCreateForm.ComboBox1Click (Sender: TObject);
begin
    if (ComboBox1.ItemIndex > 0) then copyTemplate (ComboBox1.ItemIndex);
end;

procedure TCreateForm.initTemplate (t: Integer);
var nt: ^TNet;
i: Integer;
begin
    ComboBox1.Clear ();
    
    ComboBox1.Items.Add ('Пусто');
    nt := Dict (net._parent).Nets;
    
    for i := 0 to Dict (net._parent).Nets_Count - 2 do
    begin
        
        if (nt._type <> t - 1) then
        begin
            Inc (nt);
            continue;
        end;
        ComboBox1.Items.AddObject (nt.file_name + '(' + nt.Rem + ')', nt^);
        Inc (nt);
    end;
    
    
    
    
    
end;

procedure TCreateForm.copyTemplate (t: Integer);
var i, il, ol: Integer;
nt: TNet;
pf: PField;
st: String;

begin
    
    
    nt := ComboBox1.Items.Objects [t] as TNet;
    
    listbox2.Clear;
    listbox3.Clear;
    
    FreeMem (net.In_Fields);
    FreeMem (net.Out_Fields);
    
    net.In_Count := nt.In_Count;
    net.Out_Count := nt.Out_Count;
    
    il := net.In_Count * sizeof (Field_View);
    ol := net.Out_Count * sizeof (Field_View);
    
    GetMem (net.In_Fields, il );
    GetMem (net.Out_Fields, ol );
    
    
    Move ((nt.In_Fields)^, (net.In_Fields)^, il);
    Move ((nt.Out_Fields)^, (net.Out_Fields)^, ol);
    
    pf := nt.In_Fields;
    for i := 0 to nt.In_Count - 1 do
    begin
        
        if (pf.Num > 0) then st := listbox1.Items [pf.Num - 1]
        else
        begin
            st := 'Тренд ' + listbox1.Items [1 - pf.Num];
        end;
        
        listbox2.Items.Add (st);
        inc (pf);
    end;
    
    
    pf := nt.Out_Fields;
    for i := 0 to nt.Out_Count - 1 do
    begin
        if (pf.Num > 0) then st := listbox1.Items [pf.Num - 1]
        else
        begin
            st := 'Тренд ' + listbox1.Items [1 - pf.Num];
        end;
        listbox3.Items.Add (st);
        inc (pf);
    end;
    
    Check_Ready;
    TrendEnable (false);
    IntervalEnable (false);
    StaticText12.Caption := '-';
    StaticText14.Caption := '-';
    
    
end;

end.




