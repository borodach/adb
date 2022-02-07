unit Pack;
interface uses sharemem,
Db,
T_Net,
Dictonary,
SysUtils,
dbtables,
ExternDll;

type
{TScan=record
  case byte of
  0: (pp:^Char);
  1: (pi:^Integer);
  2: (pr: ^Double);
  3: (pc:^Currency);
  4: (pv:Pointer);
  5: (pb:^ShortInt)
  end;
 }
TPack = class
    net: TNet;
    fl: ^Field_View;
    pos: Integer;
    resultLength: Integer;
    buffer: Pointer;

    procedure Init (nt: TNet;bf: Pointer);
    procedure Read_To_Field (field, df, f0: TField;needDiff: Integer);
    procedure Read_To_String (var st, df: String;f0: string;needDiff: Integer);
    function Get_Name (i: Integer;var tf: TField;var b: Boolean): String;

    destructor Destroy; override;

end;
implementation uses main, dyn_array, doswin;

destructor TPack.Destroy;
begin
    if net <> nil then destroyParser (net.id);
    inherited Destroy;

end;

procedure TPack.Init (nt: TNet;bf: Pointer);
begin
    net := nt;
    buffer := bf;
    pos := 0;
    if nt.Out_Count > 0 then
    begin
        //fl:=net.Out_Fields;
        resultLength := net.Out_Count;
    end
    else
    begin
        //fl:=net.In_Fields;
        resultLength := net.In_Count;
    end;

end;

procedure TPack.Read_To_Field (field, df, f0: TField; needDiff: Integer);
var s0, s1, s2: String;
begin
    s0 := field.AsString;
    s1 := df.AsString;
    s2 := f0.AsString;
    Read_To_String (s0, s1, s2, needDiff);
    field.AsString := s0;
    df.AsString := s1;
end;

procedure TPack.Read_To_String (var st, df: String;f0: String; needDiff: Integer);
var pl: Pole;
dd0, dl0, dl1, dr, d0, d1, dd: double;
cc0, cl0, cl1, dc, c0, c1, cc: Currency;
pMin, pMax: Pointer;
i0, vl0, vl1, i, v0, v1: integer;
ss: string;
begin
    dr := 0;
    //pl:=Dict(net._parent).GetField(abs(fl.Num)-1);
    //pMin:=pl.voc.GetP(0);
    //pMax:=pl.voc.GetP(pl.voc.pos);
    pr.Query.Next;
    //целые числа

    getString (net.id,
    @buffer,
    pos,
    pr.Query,
    st,
    df,
    f0,
    needDiff
    );
    pos := (pos + 1) mod resultLength;
end;

function TPack.Get_Name (i: Integer;var tf: TField;var b: Boolean): String;
var t: ^Field_View;
begin
    if net.Out_Count > 0 then t := net.Out_Fields
    else t := net.In_Fields;

    b := False;
    Inc (t, i);
    tf := pr.Query.Fields [Dict (net._parent).GetField (abs (t.Num) - 1).num];
    if t.Num > 0 then
    begin
        if t.cnt = 0 then result := tf.FieldName
        else
        begin
            result := tf.FieldName + '_' + IntToStr (t.cnt) + '_';
            b := true;
        end;
    end
    else
    result := Dict (net._parent).GetField (abs (t.Num) - 1).Name + '_t';
end;
end.






