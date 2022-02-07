unit IOMaster;
interface
uses ShareMem, main, MyNet, classes, Sysutils, windows, NeuralBaseTypes,
NeuralBaseComp, progn;
type
    //TByteVector=array of Integer;//!!!!!!!!!!!!!
    PB = ^Shortint;
    PINT = ^Integer;
    PD = ^Double;
    PC = ^Currency;
    PSS = ^PChar;

    TIOMaster = class
    public
        constructor Init;
        destructor reset;

        function parse (inp: PB; iof: Integer; var out_buf: TVectorFloat; ps:Integer): Integer;
        function extract (fl: Boolean): PB;
        function calc (io: Boolean): Integer;

    public
        all, ep: integer;
        ntrend:boolean;
        client: TMyNet;
        io: Boolean;         //������ ������ ������ ��� � �������
end;

implementation
    uses gate;

///////////////////////////////////////////////////////////////////////////////
//
//      constructor TIOMaster.Init;
//
///////////////////////////////////////////////////////////////////////////////

constructor TIOMaster.Init;
begin
    ntrend := false;
end;

///////////////////////////////////////////////////////////////////////////////
//
//      function TIOMaster.extract (fl: Boolean): PB;
//
///////////////////////////////////////////////////////////////////////////////

function TIOMaster.extract (fl: Boolean): PB;
var i, ind:Integer;
    field: PF;
    maxp, pos, res: PB;
    pp, tp, addr: Pole;
    base, sz, my_ind: Integer;
    value:	Double;
begin
    //ps:=ep;//base;
    base := ep;
    all := 0;
    field := client.net.Out_Fields;
    sz := client.net.Out_Count - 1;
    if fl then
    begin
        field := client.net.In_Fields;
        sz := client.net.In_Count - 1;
    end;

    //������� ������ ������
    for i := 0 to sz do
    begin
        ind := abs (field.Num) - 1;
        pp := client.pGetPole (Dict (client.net._parent), ind);
        addr := pp;
        if ( (field.Num < 0) and (not ntrend)) then
        begin
            tp := client.pGetPole (Dict (client.net._parent), pp.tr_num);
            addr := tp;
        end;

        value := (client.base_net as TNeuralNetBP).Output [ep];

        //
        //##��������� ��������
        //

        value := (value + 1) / 2;
        Inc (ep);

        if field.porog = 0 then
        begin
            if (field.cnt <> 0) then inc (all, sizeof (integer))
            else
            begin

                case addr.F_Type of
                0: Inc (all, sizeof (integer));
                1: Inc (all, sizeof (double));
                2: Inc (all, sizeof (Currency));
                3:
                    begin
                        my_ind := round (value * addr.voc.siz);
                        if (my_ind < 0) then my_ind := 0;
                        if (my_ind >= addr.voc.siz) then
                            my_ind := addr.voc.siz - 1;
                        maxp := PB (PSS (client.pGetP (addr.voc, my_ind))^);
                        Inc (all, strlen (PChar (maxp)) + 1);
                    end;
                end;
            end;
        end
        else inc (all);

        Inc (field);
    end;

    //������

    result := nil;
    GetMem (res, all);
    result := res;
    pos := res;
    ep := base;
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

        value:= (client.base_net as TNeuralNetBP).Output[ep];
        Inc (ep);

        if field.porog = 0 then
        begin
            if (field.cnt <> 0) then
            begin
                if value < 0 then value := 0;
                if value > 1 then value := 1;

                PINT (pos)^:=round (value*field.Cnt);
                inc (pos, sizeof (integer));
            end
            else
            begin
                maxp := PB (client.pGetP (addr.voc, addr.voc.siz - 1));
                case addr.F_Type of
                    0:
                    begin
                      PINT (pos)^ := round (value * PINT (maxp)^);
                      Inc (pos, sizeof (integer));
                    end;
                    1:
                    begin
                      PD (pos)^ := value * PD (maxp)^;
                      Inc (pos, sizeof (double));
                    end;
                    2:
                    begin
                      PC (pos)^:=round (value * PC (maxp)^);
                      Inc (pos, sizeof (Currency));
                    end;
                    3:
                    begin
                        my_ind := round (value * addr.voc.siz);
                        if  (my_ind < 0) then my_ind := 0;
                        if  (my_ind >= addr.voc.siz) then my_ind := addr.voc.siz - 1;
                        maxp:=PB (PSS (client.pGetP (addr.voc, my_ind))^);//PSS (client.pGetP (addr.voc, my_ind))^
                        strcopy (PChar (pos), PChar (maxp));
                        Inc (pos, strlen (PChar (maxp)) + 1);

                    end;
                end;
            end;
        end
        else
        begin
            pos^ := 0;
            if value > 0 then pos^ := 1;
            if value < 0 then pos^ := -1;
            inc (pos);
        end;

        Inc (field);
    end;

end;

///////////////////////////////////////////////////////////////////////////////
//
//      function TIOMaster.parse
//
///////////////////////////////////////////////////////////////////////////////

function TIOMaster.parse (inp: PB; iof: Integer; var out_buf: TVectorFloat; ps:Integer): Integer;
var i, ind: Integer;
    field: PF;
    pos, maxp: PB;
    pp, tp, addr: Pole;
    size, unk, f, c, sz: Integer;
    value: double;
    z: boolean;
begin
  	z := false;
    unk := 0;
    c := 0;
    f := 0;
    field := client.net.In_Fields;
    sz := client.net.In_Count - 1;
    pos := inp;

    Inc (pos, sizeof (Integer));
    while (c < 2) do
    begin
        if c + iof <> 2 then
        begin
            for i := 0 to sz do
            begin
                ind := abs (field.Num) - 1;
                pp := client.pGetPole (Dict (client.net._parent), ind);
                addr:=pp;
                if ((not ntrend) and  (field.Num < 0)) then
                begin
                    tp := client.pGetPole (Dict (client.net._parent), pp.tr_num);
                    addr := tp;
                end;

                if field.porog = 0 then
                begin
                    if field.Cnt = 0 then
                    begin

                        if addr.F_Type <> 3 then
                            value := client.find (addr.voc, @f, pos)
                        else value := client.find (addr.voc, @f, @pos);

                        if (f = 0) then
                        begin
                            z := true;
                            value := 0;
                            Inc (unk);
                        end;

                        maxp := PB (client.pGetP (addr.voc, addr.voc.siz - 1));
                        case addr.F_Type of
                        0:  begin
                                if (PINT (maxp)^ = 0) then PINT (maxp)^ := 1;
                                value := PINT (pos)^ / PINT (maxp)^;
                                Inc (pos, sizeof (integer));
                            end;
                        1:  begin
                                if (PD (maxp)^ = 0) then PD (maxp)^ := 1;
                                value := PD (pos)^ / PD (maxp)^;
                                Inc (pos, sizeof (double));
                            end;
                        2:  begin
                                if (PC (maxp)^ = 0) then PC (maxp)^ := 1;
                                value := PC (pos)^ / PC (maxp)^;
                                Inc (pos, sizeof (currency));
                            end;
                        3:  begin
                                value := client.find (addr.voc, @f, @pos);
                                if addr.voc.siz <> 0 then value := value / addr.voc.siz;
                                Inc (pos, strlen (PChar (pos)) + 1);
                            end;
                        end;
                    end
                    else
                    begin
                        value := (PINT (pos))^ / field.Cnt;
                        if value > field.Cnt then
                        begin
                            value := 1;//field.Count;
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
                    end;
                end
                else
                begin
                    value := pos^;
                    Inc (pos);
                end;

                Inc (field);

                //
                //##��������� ��������
                //
                out_buf [ps] := 2 * value - 1;
                Inc (ps);
            end;
        end;
        Inc (c);
        field := client.net.Out_Fields;
        sz := client.net.Out_Count - 1;
    end;
    result := unk;
end;

///////////////////////////////////////////////////////////////////////////////
//
//      function TIOMaster.calc (io: Boolean): Integer;
//
///////////////////////////////////////////////////////////////////////////////

function TIOMaster.calc (io: Boolean): Integer;
var i, sz, ind, all: Integer;
    field: PF;
    pp, tp, addr: Pole;
    size: Integer;

begin
    if io then result := client.net.In_Count
    else result := client.net.Out_Count;
end;

///////////////////////////////////////////////////////////////////////////////
//
//      destructor TIOMaster.reset;
//
///////////////////////////////////////////////////////////////////////////////

destructor TIOMaster.reset;
begin
    Destroy;
end;

end.
