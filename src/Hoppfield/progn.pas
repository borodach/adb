unit progn;

interface
uses ShareMem, MyNet, NeuralBaseComp,
HoppfieldNetEx,
NeuralBaseTypes, MyStream,
classes, prop, windows, sysutils;
type
TProgn = class (TMyNet)
public
    constructor Do_Init;
    destructor Destroy; override;
    function Init: Integer;override;
    function Save: Integer;override;
    function Load: Integer;override;
    function Learn (a, b: Integer): Integer;override;
    function Run (p: Pointer): Pointer;override;
    procedure Show;override;
    function Prop: Integer;override;
public
    //base_net: TNeuralNetHopf;
    
    back, front, ic, oc: Integer;
    
end;

implementation
uses gate, IOMaster, assoc;
constructor TProgn.Do_Init;
begin
    Create;
    base_net := nil;
end;
destructor TProgn.Destroy;
begin
    base_net.Free;
    inherited Destroy;
end;


function TProgn.Init: Integer;
var dlg: TOKRightDlg;
res, t: Integer;
m: TIOMaster;
begin
    result := 0;
    
    try
        try
            m := nil;
            dlg := nil;
            
            m := TIOMaster.Init;
            m.client := self;
            ic := m.calc (true);
            oc := m.calc (false);
            
            dlg := TOKRightDlg.Create (nil);
            res := dlg.ShowModal ();
            if res < 0 then
            begin
                result := 1;
                exit;
            end;
            t := trunc (dlg.RxSpinEdit1.value);
            back := trunc (dlg.RxSpinEdit2.value);
            front := trunc (dlg.RxSpinEdit3.value);
            
            try
                base_net := TNeuralNetHopfEx.Create (nil);
                (base_net as TNeuralNetHopf).InputNeuronCount := ic * back + oc * front;
                
                (base_net as TNeuralNetHopf).Init;
                
                (base_net as TNeuralNetHopf).InitWeights;
                (base_net as TNeuralNetHopf).MaxIterCount := t;
                
                
                
                except
                base_net.free;
                base_net := nil;
                ic := 0;
                oc := 0;
                result := 1;
                MessageBox (hw, 'Не могу создать сеть.', 'Ошибка.', 0);
                exit;
            end;
            
            
            
        finally
            m.free;
            dlg.Free;
        end;
        
        except
        MessageBox (hw, 'Не могу создать окно параметров сети.', 'Ошибка.', 0);
    end;
    
    
end;
function TProgn.Save: Integer;
var nnm: String;
fn: TMyStream;
pos: Longint;
b: double;
i, j, sz, buf: Integer;
begin
    result := 1;
    try
        try
            nnm := String (project.Cur_Dir) + String (net.file_name);
            fn := nil;
            try
                fn := TMyStream.Create (nnm, fmOpenWrite);
                except
                Exit;
            end;
            
        fn.seek (0, soFromEnd);
        pos := fn.Position;
        
        fn.Write (back, sizeof (back));
        fn.Write (ic, sizeof (ic));
        fn.Write (front, sizeof (front));
        fn.Write (oc, sizeof (oc));
        
        
        with (base_net as TNeuralNetHopf) do
        begin
            fn.Write (MaxIterCount, sizeof (MaxIterCount));
            // buf:=Layers[1].NeuronCount;
            // fn.Write(buf,sizeof(buf));
            
            for i := 0 to Layers [1].NeuronCount - 1 do
            for j := 0 to Layers [1].NeuronCount - 1 do
            begin
                b := Layers [1].Neurons [i].Weights [j];
                fn.Write (b, sizeof (b));
            end;
            
            
        end;
        
        
        fn.Write (pos, sizeof (pos));
        result := 0;
        
    finally
        fn.Free;
        fn := nil;
    end;
    except
    
end;


end;


function TProgn.Load: Integer;
var nnm: String;
fn: TMyStream;
pos: Longint;
b: double;
i, j, sz, buf, itc: Integer;
begin
    result := 1;
    try
        try
            nnm := String (project.Cur_Dir) + String (net.file_name);
            fn := nil;
            try
                fn := TMyStream.Create (nnm, fmOpenRead);
                except
                Exit;
            end;
            
        fn.seek (- sizeof (pos), soFromEnd);
        fn.Read (pos, sizeof (pos));
        
        
        fn.seek (pos, soFromBeginning);
        
        fn.Read (back, sizeof (back));
        fn.Read (ic, sizeof (ic));
        fn.Read (front, sizeof (front));
        fn.Read (oc, sizeof (oc));
        
        base_net := TNeuralNetHopfEx.Create (nil);
        
        
        with (base_net as TNeuralNetHopf) do
        begin
            
            fn.Read (itc, sizeof (itc));
            InputNeuronCount := ic * back + oc * front;
            //fn.Read(buf,sizeof(buf));
            //Layers[1].NeuronCount:=buf;
            (base_net as TNeuralNetHopf).Init;
            //(base_net as TNeuralNetHopf).InitWeights;
            MaxIterCount := itc;
            
            for i := 0 to Layers [1].NeuronCount - 1 do
            for j := 0 to Layers [1].NeuronCount - 1 do
            begin
                fn.Read (b, sizeof (b));
                Layers [1].Neurons [i].Weights [j] := b;
                
            end;
            
            
        end;
        
        
        
        result := 0;
        
    finally
        fn.Free;
        fn := nil;
    end;
    except
    if base_net <> nil then
    begin
        base_net.Destroy;
        base_net := nil;
    end;
end;


end;

function TProgn.Learn (a, b: Integer): Integer;
var all, unk, curr, sz, icc, occ, i, j, ps, ip, op: Integer;
m: TIOMaster;
v: TVectorInt;
data: PB;
begin
    all := b - a + 1 - front - back + 1; //число образцов
    icc := ic * back;
    occ := oc * front;
    sz := icc + occ;
    pSetPos (net, 1, a);
    result := - 1;
    if (all < 1) then
    begin
        pStep (- 1, - 1, - 1);
        exit;
    end;
    Set_sv (project, 0);
    result := 1;
    sz := ic * back + oc * front;
    setlength (v, sz);
    m := nil;
    ip := a;
    op := a + back;
    
    try
        try
            m := TIOMaster.Init;
            m.client := self;
            
            unk := 0;
            pStep (0, all, unk);
            for curr := 1 to all do
            begin
                if curr = 1 then
                begin
                    ps := icc - ic;
                    //читаем входы
                    for j := 0 to back - 1 do
                    begin
                        pSetPos (net, 1, ip);
                        Inc (ip);
                        
                        data := pRead (net, 1);
                        if (data = nil) then
                        begin
                            result := - 2;
                            exit;
                        end;
                        inc (unk, m.parse (data, 1, v, nil, ps));
                        pFreeRes (net, data);
                        
                        {
                                                                for i:=0 to ic-1 do
                                                                begin
                                                                   v[ps+i]:=trunc(m.out_buf[i]);
                                                                   //Inc(ps);
                                                                end; }
                        Dec (ps, ic);
                        
                    end;
                    
                    ps := icc;//sz-oc;
                    //читаем выходы
                    for j := 0 to front - 1 do
                    begin
                        
                        pSetPos (net, 1, op);
                        Inc (op);
                        
                        data := pRead (net, 2);
                        
                        if (data = nil) then
                        begin
                            result := - 2;
                            exit;
                        end;
                        inc (unk, m.parse (data, 2, v, nil, ps));
                        pFreeRes (net, data);
                        
                        {for i:=0 to oc-1 do
                                                                 begin
                                                                    v[ps+i]:=trunc(m.out_buf[i]);
                                                                    //inc(ps);
                                                                 end;}
                        //Dec(ps,oc);
                        Inc (ps, oc);
                        
                    end
                    
                end
                else
                begin
                    //читаем вход
                    pSetPos (net, 1, ip);
                    Inc (ip);
                    
                    data := pRead (net, 1);
                    if (data = nil) then
                    begin
                        result := - 2;
                        exit;
                    end;
                    
                    //сдвигаем данные на ic
                    for i := icc - 1 downto ic do v [i] := v [i - ic];
                    
                    inc (unk, m.parse (data, 1, v, nil, 0));
                    pFreeRes (net, data);
                    
                    //записываем новые данные
                    //for i:=0 to ic-1 do v[i]:=trunc(m.out_buf[i]);
                    
                    
                    //читаем выходы
                    pSetPos (net, 1, op);
                    Inc (op);
                    
                    data := pRead (net, 2);
                    
                    if (data = nil) then
                    begin
                        result := - 2;
                        exit;
                    end;
                    
                    //сдвиг выходов
                    //for i:=sz-1 downto icc+oc do v[i]:=v[i-oc];
                    for i := icc to sz - oc - 1 do v [i] := v [i + oc];
                    
                    
                    inc (unk, m.parse (data, 2, v, nil, sz - oc));
                    pFreeRes (net, data);
                    
                    
                    //добавили новые
                    // for i:=icc to icc+oc-1 do v[i]:=trunc(m.out_buf[i-icc]);
                    
                end;
                with ((base_net as TNeuralNetHopfEx)) do
                begin
                    AddPattern (v);
                    InitWeights;
                    DeletePattern (1);
                end;
                
                if (pStep (curr, all, unk) = 1) then
                begin
                    result := 1;
                    pStep (- 1, - 1, - 1);
                    exit;
                end;
            end;
            
            //base_net.InitWeights1;
            
            // pStep(all+1,all+1,unk);
            
            
        finally
            m.Free;
            setlength (v, 0);
        end;
        except
        pStep (- 1, - 1, - 1);
        MessageBox (hw, 'Не могу обучить сеть.', 'Ошибка.', 0);
    end;
    
    result := 0;
end;


function TProgn.Run (p: Pointer): Pointer;
var
all, unk, curr, sz, icc, occ, i, j, ps, ip, op, dt: Integer;
m: TIOMaster;
//v: TVectorInt;
data, d0, tmp: PB;
begin
    d0 := nil;
    result := nil;
    if PINT (p)^ = 0 then
    begin
        PINT (p)^ := front;
        exit;
    end;
    if PINT (p)^ = - 1 then
    begin
        PINT (p)^ := back;
        exit;
    end;
    
    PINT (p)^ := 0;
    
    icc := ic * back;
    occ := oc * front;
    sz := icc + occ;
    
    pGetPos (net, @ip, @op);
    
    dt := back - ip;
    
    if dt < 0 then dt := 0;
    
    
    pSetPos (net, 0, dt - back + 1);
    
    sz := ic * back + oc * front;
    
    { setlength(v,sz);}
    
    m := nil;
    
    try
        try
            m := TIOMaster.Init;
            m.client := self;
            
            unk := 0;
            
            ps := icc - ic * (dt + 1);
            
            for i := icc - ic * dt to sz - 1 do
            begin
                (base_net as TNeuralNetHopf).Input [i] := 0;
                //v[icc-i]:=0;
            end;
            
            //читаем входы
            for j := 0 to back - 1 - dt do
            begin
                data := pRead (net, 1);
                if (data = nil) then
                begin
                    result := nil;
                    exit;
                end;
                
                inc (unk, m.parse (data, 1, nil, nil, ps));
                pFreeRes (net, data);
                pSetPos (net, 0, 1);
                
                {
                                        for i:=0 to ic-1 do
                                        begin
                                           //v[ps+i]:=trunc(m.out_buf[i]);
                                           base_net.Input[ps+i]:=trunc(m.out_buf[i]);
                                           //Inc(ps);
                                        end;}
                Dec (ps, ic);
            end;
            
            
            (base_net as TNeuralNetHopf).Calc;
            
            d0 := nil;
            tmp := nil;
            data := nil;
            op := 0;
            
            m.ep := 0;
            
            for i := 1 to front do
            begin
                
                d0 := m.extract (false);
                
                GetMem (tmp, op + m.all);
                
                
                if data <> nil then
                begin
                    move (data^, tmp^, op);
                    FreeMem (data);
                end;
                data := tmp;
                
                Inc (tmp, op);
                move (d0^, tmp^, m.all);
                
                FreeMem (d0);
                
                Inc (op, m.all);
                
                tmp := nil;
                d0 := nil;
                
            end
            
            
            
            
        finally
            if d0 <> nil then FreeMem (d0);
            if tmp <> nil then FreeMem (tmp);
            m.Free;
        end;
        except
        MessageBox (hw, 'Runtime error.', 'Ошибка.', 0);
    end;
    
    PINT (p)^ := unk;
    result := data;
end;




procedure TProgn.Show;
begin
    MessageBox (hw, 'Данная библиотека не поддерживает графическое представление сети.', 'Сообщение.', 0);
end;


function TProgn.Prop: Integer;
var dlg: TOKRightDlg;
res: integer;
begin
    result := 0;
    try
        try
            dlg := nil;
            dlg := TOKRightDlg.Create (nil);
            dlg.RxSpinEdit1.value := (base_net as TNeuralNetHopf).MaxIterCount;
            dlg.RxSpinEdit2.value := back;
            dlg.RxSpinEdit3.value := front;
            dlg.RxSpinEdit2.Enabled := false;
            dlg.RxSpinEdit3.Enabled := false;
            res := dlg.ShowModal ();
            if res < 0 then
            begin
                exit;
            end;
            if trunc (dlg.RxSpinEdit1.value) <> (base_net as TNeuralNetHopf).MaxIterCount then result := 1;
            (base_net as TNeuralNetHopf).MaxIterCount := trunc (dlg.RxSpinEdit1.value);
        finally
            dlg.Free;
        end;
        
        except
        MessageBox (hw, 'Не могу создать окно параметров сети.', 'Сообщение.', 0);
        result := 0;
    end;
    
end;
end.


