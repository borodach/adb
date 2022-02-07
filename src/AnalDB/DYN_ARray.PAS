unit dyn_array;
interface
Uses sharemem, SysUtils, windows, MainForm, dialogs, classes;
{класс d_array содержит массив с динамическим наращиванием размера}
type
PInt = ^Integer;
func = function (a, b: Pointer): Integer;
d_array = class
    inf: Pointer;
    dsz, pos, siz, info_size: Integer;
    is_PChar: Boolean;
    Cmp: func;
    function Init (ds, s, i_s: cardinal;flag: Boolean ; f: func): Boolean;
    {s начальный размер массива, ds приращение размера массива,
         i_s размер данных, f - ф-ция сравнения эл-тов. flag нужно ли при уничтожении
          вызывать FreeMem для элементов}
    function Add (p: Pointer): boolean;
    procedure Reset;
    function Find (f: PInt;p: Pointer): Integer;stdcall;
    function GetP (ind: Integer): Pointer;stdcall;
    function Save (f: TStream): Boolean;
    function Load (f: TStream): Boolean;
    function Minimize: Boolean;
end;

Pole = class
    name: PChar;
    num: Integer;
    F_Type: Integer;
    tr_num: Integer;
    {поддерживаем целые, вещественные числа (здесь же дата - время), строки}
    voc: d_array;
    function Save (f: TStream): Boolean;
    function Load (f: TStream): Boolean;
    
    procedure Reset;
    {
            type  = (ftUnknown, ftString, ftSmallint, ftInteger, ftword,
             ftBoolean, ftFloat, ftCurrency, ftBCD, ftDate, ftTime, ftDateTime,
             ftBytes, ftVarBytes, ftAutoInc, ftBlob, ftMemo, ftGraphic, ftFmtMemo,
             ftParadoxOle, ftDBaseOle, ftTypedBinary, ftCursor);
            }
end;
function integer_cmp (a, b: Pointer): Integer;
function double_cmp (a, b: Pointer): Integer;
function currency_cmp (a, b: Pointer): Integer;
function string_cmp (a, b: Pointer): Integer;
function MySaveStr (f: TStream; st: PChar): Boolean;
function MyLoadStr (f: TStream; st: Pointer): Boolean;

implementation

function MySaveStr (f: TStream;st: PChar): Boolean;
var s: Integer;
begin
    s := StrLen (st);
    try
        f.Write (s, sizeof (s));
        f.Write (st^, s);
        Result := True;
        except
        on e: EInOutError do
        begin
            MessageBox (Form1.Handle, PChar (e.Message), PChar ('Ошибка записи.'), 0);
            Result := False;
        end;
    end;
end;
function MyLoadStr (f: TStream;st: Pointer): Boolean;
var s: Integer;
begin
    Result := False;
    try
        Pointer (st^) := nil;
        f.Read (s, sizeof (s));
        GetMem (Pointer (st^), s + 1);
        //if(s>7000) then raise Exception.Create('MyExcept');
        f.Read (Pointer (st^)^, s);
        //if(uu<s) then
        //uu:=78;
        PChar (st^) [s] := #0;
        Result := True;
        except
        on e: EInOutError do
        begin
            if Pointer (st^) <> nil then FreeMem (Pointer (st^), s + 1);
            MessageBox (Form1.Handle, PChar (e.Message), PChar ('Ошибка чтения.'), 0);
        end;
        on m: EOutOfMemory do
        begin
            MessageBox (Form1.Handle, PChar (m.Message), PChar ('Ошибка выделения памяти.'), 0);
        end;
    end;
end;

function d_array.Init (ds, s, i_s: cardinal;flag: Boolean ; f: func): Boolean;
begin
    try
        GetMem (inf, s * i_s);
        pos := - 1;
        siz := s;
        dsz := ds;
        info_size := i_s;
        is_PChar := flag;
        cmp := f;
        Init := True;
        except
        on e: EOutOfMemory do
        begin
            Init := False;
            MessageBox (Form1.Handle, PChar (e.Message), PChar ('Ошибка выделения памяти.'), 0);
        end;
    end
end;

procedure d_array.Reset;
var i: longint;
tmp: ^Pointer;
tt: Pointer;
begin
    tmp := inf;
    if (inf <> nil) then
    begin
        if (is_PChar) then
        for i := 0 to pos do
        begin
            if tmp^ <> nil then
            begin
                tt := GetP (i);
                FreeMem (Pointer (tt^), StrLen (PChar (tt^)) + 1);
            end;
            inc (tmp, 1);
        end;
        FreeMem (inf, siz * info_size);
        inf := nil;
    end;
    pos := - 1;
    siz := 0;
end;

function d_array.GetP (ind: Integer): Pointer;stdcall;
var tmp: ^byte;
begin
    tmp := inf;
    inc (tmp, ind * info_size);
    GetP := tmp;
end;

{двоичный поиск}
function d_array.Find (f: PInt;p: Pointer): Integer;stdcall;
var a, b, c, t: Integer;
pp: Pointer;
begin
    f^ := 0;
    if (pos = - 1) then
    begin
        Find := 0;
        Exit;
    end;
    a := 0; b := pos;
    repeat
    c := (a + b) shr 1;
    pp := GetP (c);
    t := Cmp (pp, p);
    if (t = 0) then
    begin
        Find := c;
        f^ := 1;
        exit;
    end;
    if (a = b) then
    begin
        if (t < 0) then Find := a + 1 else Find := a;
        exit;
    end;
    if (t > 0) then b := c
    else a := c + 1;
    until (False);
end;

function d_array.Add (p: Pointer): boolean;
var i, j: Integer;
fl: Integer;
a, b: ^byte;
begin
    Add := True;
    j := Find (@fl, p);
    if (fl = 1) then
    begin
        if is_PChar then FreeMem (Pointer (p^), StrLen (PChar (p^) + 1));
        Exit;
    end;
    if (pos = siz - 1) then
    begin
        try
            ReallocMem (inf, (siz + dsz) * info_size);
            except
            on e: EOutOfMemory do
            begin
                Add := False;
                MessageBox (Form1.Handle, PChar (e.Message), PChar ('Ошибка выделения памяти.'), 0);
                Exit;
            end;
        end;
        Inc (siz, dsz);
    end;
    Inc (pos);
    Inc (j);
    a := inf;
    inc (a, pos * info_size);
    b := a;
    Dec (b, info_size);
    for i := pos downto j do
    begin
        move (b^, a^, info_size);
        Dec (b, info_size);
        Dec (a, info_size);
    end;
    b := p;
    move (b^, a^, info_size);
end;


function d_array.Save (f: TStream): Boolean;
var real_res, i: cardinal;
tmp: ^Pointer;
begin
    tmp := inf;
    Save := False;
    try
        f.Write (pos, sizeof (pos));
        f.Write (dsz, sizeof (dsz));
        f.Write (info_size, sizeof (info_size));
        f.Write (is_PChar, sizeof (is_PChar));
        if (pos >= 0) then
        begin
            real_res := info_size * (pos + 1);
            if is_PChar then
            for i := 0 to pos do
            begin
                if (not MySaveStr (f, PChar (tmp^))) then exit;
                Inc (tmp);
            end
            else f.Write (inf^, real_res);
        end;
        Save := True;
        except
        on e: EInOutError do MessageBox (Form1.Handle, PChar (e.Message), PChar ('Ошибка записи.'), 0);
    end;
end;

function d_array.Load (f: TStream): Boolean;
var real_res, i: integer;
tmp: ^Pointer;
begin
    Load := False;
    try
        f.Read (pos, sizeof (pos));
        siz := pos + 1;
        f.Read (dsz, sizeof (dsz));
        f.Read (info_size, sizeof (info_size));
        f.Read (is_PChar, sizeof (is_PChar));
        
        if pos >= 0 then
        begin
            real_res := info_size * (siz);
            GetMem (inf, real_res);
            tmp := inf;
            FillChar (inf^, real_res, #0);
            if is_PChar then
            for i := 0 to pos do
            begin
                if (not MyLoadStr (f, tmp)) then
                begin
                    Reset;
                    exit;
                end;
                Inc (tmp);
            end
            else f.Read (inf^, real_res);
        end;
        Load := True;
        except
        on e: EInOutError do MessageBox (Form1.Handle, PChar (e.Message), PChar ('Ошибка чтения.'), 0);
        on e: EOutOfMemory do MessageBox (Form1.Handle, PChar (e.Message), PChar ('Ошибка выделения памяти.'), 0);
    end;
end;
function d_array.Minimize: Boolean;
begin
    Minimize := False;
    try
        ReallocMem (inf, (pos + 1) * info_size);
        siz := pos + 1;
        Minimize := True;
        except
        on e: EInOutError do MessageBox (Form1.Handle, PChar (e.Message), PChar ('Ошибка чтения.'), 0);
    end;
    
end;
function integer_cmp (a, b: Pointer): Integer;
var c, d: ^Integer;
begin
    c := a;d := b;
    integer_cmp := - 1;
    if (c^ > d^) then integer_cmp := 1;
    if (c^ = d^) then integer_cmp := 0;
end;
function double_cmp (a, b: Pointer): Integer;
var c, d: ^double;
begin
    c := a;d := b;
    double_cmp := - 1;
    if (c^ > d^) then double_cmp := 1;
    if (c^ = d^) then double_cmp := 0;
end;
function currency_cmp (a, b: Pointer): Integer;
var c, d: ^currency;
begin
    c := a;d := b;
    currency_cmp := - 1;
    if (c^ > d^) then currency_cmp := 1;
    if (c^ = d^) then currency_cmp := 0;
end;
function string_cmp (a, b: Pointer): Integer;
var c, d: PChar;

begin
    c := PChar (a^);
    d := PChar (b^);
    string_cmp := StrComp (c, d);
end;

function pole.Save (f: TStream): Boolean;
var s: PChar;
begin
    Save := False;
    try
        f.Write (F_Type, sizeof (F_Type));
        f.Write (num, sizeof (num));
        f.Write (tr_num, sizeof (tr_num));
        if (name = nil) then s := '' else s := name;
        if (MySaveStr (f, s) = False) then Exit;
        if (not voc.Save (f)) then Exit;
        Save := True;
        except
        on e: EInOutError do MessageBox (Form1.Handle, PChar (e.Message), PChar ('Ошибка записи.'), 0);
    end;
    
end;
function pole.Load (f: TStream): Boolean;
begin
    Load := False;
    //if name <> nil then FreeMem(name,StrLen(name)+1);
    try
        f.Read (F_Type, sizeof (F_Type));
        f.Read (num, sizeof (num));
        f.Read (tr_num, sizeof (tr_num));
        if (not MyLoadStr (f, @name)) then Exit;
        if (voc.Load (f) = False) then
        begin
            FreeMem (name, StrLen (name) + 1);
            Exit;
        end;
        case F_Type of
            0: voc.Cmp := integer_cmp;
            1: voc.Cmp := double_cmp;
            2: voc.Cmp := currency_cmp;
            3: voc.Cmp := string_cmp;
        end;
        Load := True;
        except
        on e: Exception do MessageBox (Form1.Handle, PChar (e.Message), PChar ('Ошибка чтения.'), 0);
    end;
end;
procedure pole.reset ();
begin
    if (name <> nil) then FreeMem (name, StrLen (name) + 1);
    name := nil;
    num := - 1;
    voc.reset;
end;
end.

