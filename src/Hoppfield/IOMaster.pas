unit IOMaster;
interface
uses ShareMem, main, MyNet, classes, Sysutils, windows, NeuralBaseTypes,
NeuralBaseComp, progn;
type
//TByteVector=array of Integer;//!!!!!!!!!!!!!
TVectorBool = array of boolean;

PB = ^Shortint;
PINT = ^Integer;
PD = ^Double;
PC = ^Currency;
PSS = ^PChar;
TIOMaster = class
public
    constructor Init;
    function parse (inp: PB;
    iof: Integer;
    out_buf: TVectorInt;
    freez: TVectorBool;
    ps: Integer
    ): Integer;
    function extract (fl: Boolean): PB;
    function calc (io: Boolean): Integer;
    
    
public
    all, ep: integer;
    ntrend: boolean;
    
    destructor reset;
public
    client: TMyNet;
    
    //out_buf: TByteVector;//выходные данные
    
    io: Boolean; //чтение только входов или и выходов
    
end;
implementation
uses gate;
constructor TIOMaster.Init;
begin
ntrend := false;
//out_buf:=nil;
end;

function my_log (i: Integer): Integer;
var r: Integer;
begin
    r := 0;
    dec (i);
    while (i > 0) do
    begin
        i := i shr 1;
        Inc (r);
    end;
    if r = 0 then r := 1;
    result := r;
end;

function TIOMaster.extract (fl: Boolean): PB;
var i, ind: Integer;
field: PF;
pos, res: PB;
pp, tp, addr: Pole;
value, size, f, c, sz, ps: Integer;
begin
    
    ps := ep;//base;
    all := 0;
    field := client.net.Out_Fields;
    sz := client.net.Out_Count - 1;
    if fl then
    begin
        field := client.net.In_Fields;
        sz := client.net.In_Count - 1;
    end;
    
    for i := 0 to sz do
    begin
        ind := abs (field.Num) - 1;
        pp := client.pGetPole (Dict (client.net._parent), ind);
        addr := pp;
    if ((field.Num < 0) and (not ntrend)) then
    begin
        tp := client.pGetPole (Dict (client.net._parent), pp.tr_num);
        addr := tp;
    end;
    if field.porog = 0 then
    begin
        if field.Cnt = 0 then size := my_log (addr.voc.siz)
        else size := my_log (field.Cnt);
    end
    else size := 2;
    //поле и размер
    
    
    value := 0;
    for f := 1 to size do
    begin
        c := trunc (client.base_net.Layers [client.base_net.LayerCount - 1].Neurons [ps].Output);
        if c < 0 then c := 0;
        value := (value or (c shl (f - 1)));
        Inc (ps);
    end;
    //value - number
    
    
    if field.porog = 0 then
    begin
        if (field.Cnt <> 0) then inc (all, sizeof (integer))
        else
        begin
            
            case addr.F_Type of
                0:
                Inc (all, sizeof (integer));
                1:
                Inc (all, sizeof (double));
                2:
                Inc (all, sizeof (Currency));
                3:
                begin
                    if (value < 0) then value := 0;
                    if (value >= addr.voc.siz) then value := addr.voc.siz - 1;
                    Inc (all, strlen (PSS (client.pGetP (addr.voc, value))^) + 1);
                end;
            end;
        end;
    end
    else inc (all);
    
    Inc (field);
end;
//размер

result := nil;

GetMem (res, all);
result := res;

pos := res;

//ep:=0;//base;

field := client.net.Out_Fields;
sz := client.net.Out_Count - 1;

if fl then
begin
    field := client.net.In_Fields;
    sz := client.net.In_Count - 1;
end;

for i := 0 to sz do
begin
    ind := abs (field.Num) - 1;
    with (client) do
    pp := pGetPole (Dict (client.net._parent), ind);
    addr := pp;
if ((field.Num < 0) and (not ntrend)) then
begin
    tp := client.pGetPole (Dict (client.net._parent), pp.tr_num);
    addr := tp;
end;
if field.porog = 0 then
begin
    if field.Cnt = 0 then size := my_log (addr.voc.siz)
    else size := my_log (field.Cnt + 1);
end
else size := 2;


value := 0;

for f := 1 to size do
begin
    c := trunc ((client.base_net as TNeuralNetHopf) .Input [ep]);
    if c < 0 then c := 0;
    value := (value or (c shl (f - 1)));
    Inc (ep);
end;

//value - number

// to_log('извлекли '+IntToStr(size)+' '+IntToStr(value));

if field.porog = 0 then
begin
    
    if (field.Cnt <> 0) then
    begin
        PINT (pos)^ := value;
        inc (pos, sizeof (integer));
    end
    else
    begin
        
        if (value < 0) then value := 0;
        if (value >= addr.voc.siz) then value := addr.voc.siz - 1;
        
        case addr.F_Type of
            0:
            begin
                PINT (pos)^ := PINT (client.pGetP (addr.voc, value))^;
                Inc (pos, sizeof (integer));
            end;
            1:
            begin
                PD (pos)^ := PD (client.pGetP (addr.voc, value))^;
                Inc (pos, sizeof (double));
            end;
            2:
            begin
                PC (pos)^ := PC (client.pGetP (addr.voc, value))^;
                Inc (pos, sizeof (Currency));
            end;
            3:
            begin
                strcopy (PChar (pos), PSS (client.pGetP (addr.voc, value))^);
                Inc (pos, strlen (PChar (pos)) + 1);
                
            end;
        end;
    end;
end
else
begin
    pos^ := 0;
    if value = 0 then pos^ := - 1;
    if value = 3 then pos^ := 1;
    inc (pos);
end;


Inc (field);
end;

end;





function TIOMaster.parse (inp: PB;
iof: Integer;
out_buf: TVectorInt;
freez: TVectorBool;
ps: Integer ): Integer;
var i, ind: Integer;
field: PF;
pos: PB;
pp, tp, addr: Pole;
value, size, unk, f, c, sz: Integer;
z: boolean;
begin
    z := false;
    unk := 0;
    //ps:=beg;
    c := 0;
    f := 0;
    {
            if (iof and 1)=1 then Inc(f,client.net.In_Count*sizeof(Integer)*8);
            if (iof and 2)=2 then Inc(f,client.net.Out_Count*sizeof(Integer)*8);
        
        
            SetLength(out_buf,f);
            }
    //to_log('Длина равна '+InttoStr(f));
    field := client.net.In_Fields;
    sz := client.net.In_Count - 1;
    pos := inp;
    Inc (pos, sizeof (Integer));
    while (c < 2) do
    begin
        //to_log('Итерация '+IntToStr(c));
        if c + iof <> 2 then
        begin
            
            for i := 0 to sz do
            begin
                ind := abs (field.Num) - 1;
                //to_log(inttostr(ind));
                pp := client.pGetPole (Dict (client.net._parent), ind);
                addr := pp;
            if ((not ntrend) and (field.Num < 0)) then
            begin
                //to_log('Тренд');
                tp := client.pGetPole (Dict (client.net._parent), pp.tr_num);
                addr := tp;
            end;
            if (field.porog = 0) or (field.frozen = 1 ) then
            begin
                if field.Cnt = 0 then
                begin
                    size := my_log (addr.voc.siz);
                    if addr.F_Type <> 3 then value := client.find (addr.voc, @f, pos)
                    else value := client.find (addr.voc, @f, @pos);
                    if (f = 0) then
                    begin
                        
                        z := true;
                        value := 0;
                        Inc (unk);
                    end;
                    
                    case addr.F_Type of
                        0: Inc (pos, sizeof (integer));
                        1: Inc (pos, sizeof (double));
                        2: Inc (pos, sizeof (currency));
                        3:
                        begin
                            
                            Inc (pos, strlen (PChar (pos)) + 1);
                            
                        end;
                    end;
                    //to_log('value '+IntToStr(size)+' '+IntToStr(value));
                end
                else
                begin
                    size := my_log (field.Cnt + 1);
                    value := (PINT (pos))^;
                    if value > field.Cnt then
                    begin
                        value := field.Cnt;
                        z := true;
                        Inc (unk);
                    end;
                    if value < 0 then
                    begin
                        value := 0;
                        z := true;
                        Inc (unk);
                    end;
                    
                    
                    Inc (pos, sizeof (integer));
                    
                    //to_log('Interval'+IntToStr(size)+' '+IntToStr(value));
                end;
                //if field.Num
            end
            
            else
            begin
                value := pos^;
                if (value < 0) then value := 0
                else value := 3;
                if (pos^ = 0) then value := 2;
                size := 2;
                Inc (pos);
                //to_log('Кач. тренд'+IntToStr(size)+' '+IntToStr(value));
            end;
            
            
        z := z or (ntrend and (field.num < 0));
        
        
        if (out_buf <> nil) then
        for f := 1 to size do
        begin
            
            
            
            if z then out_buf [ps] := 0
            else
            begin
                out_buf [ps] := (value and 1);
                if out_buf [ps] = 0 then out_buf [ps] := - 1;
                value := value shr 1;
            end;
            Inc (ps);
        end
        else
        for f := 1 to size do
        begin
            
            if freez <> nil then
            freez [ps] := field.frozen <> 0;
            
            
            with (client.base_net.Layers [{client.base_net.LayerCount-}1]) do
            
            if z then Neurons [ps].Output := 0
            else
            begin
                Neurons [ps].Output := (value and 1);
                if Neurons [ps].Output = 0 then
                Neurons [ps].Output := - 1;
                value := value shr 1;
            end;
            Inc (ps);
        end;
        z := false;
        
        Inc (field);
        
    end;
end;


Inc (c);
field := client.net.Out_Fields;
sz := client.net.Out_Count - 1;
//if(c=1) then base:=ps;
end;
//SetLength(out_buf,ps);
result := unk;
end;


function TIOMaster.calc (io: Boolean): Integer;
var i, sz, ind, all: Integer;
field: PF;
pp, tp, addr: Pole;
size: Integer;

begin
    
    all := 0;
    if io then
    begin
        field := client.net.In_Fields;
        sz := client.net.In_Count - 1;
    end
    else
    begin
        field := client.net.Out_Fields;
        sz := client.net.Out_Count - 1;
    end;
    
    for i := 0 to sz do
    begin
        ind := abs (field.Num) - 1;
        pp := client.pGetPole (Dict (client.net._parent), ind);
        addr := pp;
        if (field.Num < 0) then
        begin
            tp := client.pGetPole (Dict (client.net._parent), pp.tr_num);
            addr := tp;
        end;
        if field.porog = 0 then
        begin
            if field.Cnt = 0 then size := my_log (addr.voc.siz)
            else size := my_log (field.Cnt);
        end
        else size := 2;
        
        Inc (all, size);
        
        Inc (field);
    end;
    
    result := all;
    
end;

destructor TIOMaster.reset;
begin
    //SetLength(out_buf,0);
    Destroy;
end;
end.


