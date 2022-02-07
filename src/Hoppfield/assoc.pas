unit assoc;

interface
uses ShareMem, MyNet, NeuralBaseComp, HoppfieldNetEx,
NeuralBaseTypes, MyStream,
classes, prop, windows, sysutils;
type
TAssoc = class (TMyNet)
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
    
    ic: Integer;
    
end;

implementation
uses gate, IOMaster;
constructor TAssoc.Do_Init;
begin
    Create;
    base_net := nil;
end;
destructor TAssoc.Destroy;
begin
    base_net.Free;
    inherited Destroy;
end;


function TAssoc.Init: Integer;
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
            
            
            dlg := TOKRightDlg.Create (nil);
            dlg.Label2.Visible := false;
            dlg.Label3.Visible := false;
            dlg.RxSpinEdit2.Visible := false;
            dlg.RxSpinEdit3.Visible := false;
            dlg.RxSpinEdit2.Value := 1;
            
            res := dlg.ShowModal ();
            if res < 0 then
            begin
                result := 1;
                exit;
            end;
            t := trunc (dlg.RxSpinEdit1.value);
            
            try
                base_net := TNeuralNetHopfEx.Create (nil);
                (base_net as TNeuralNetHopf).InputNeuronCount := ic;
                
                (base_net as TNeuralNetHopf).Init;
                
                (base_net as TNeuralNetHopf).InitWeights;
                (base_net as TNeuralNetHopf).MaxIterCount := t;
                
                
                
                except
                base_net.free;
                base_net := nil;
                ic := 0;
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
function TAssoc.Save: Integer;
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
        
        
        fn.Write (ic, sizeof (ic));
        
        
        
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


function TAssoc.Load: Integer;
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
        
        
        fn.Read (ic, sizeof (ic));
        
        base_net := TNeuralNetHopfEx.Create (nil);
        
        
        with (base_net as TNeuralNetHopf) do
        begin
            
            fn.Read (itc, sizeof (itc));
            InputNeuronCount := ic;
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

function TAssoc.Learn (a, b: Integer): Integer;
var all, unk, curr, sz, icc, occ, i, j, ip, op: Integer;
m: TIOMaster;
v: TVectorInt;
data: PB;
begin
    all := b - a + 1; //число образцов
    
    setlength (v, ic);
    pSetPos (net, 1, a);
    Set_sv (project, 0);
    result := 1;
    
    m := nil;
    ip := a;
    
    try
        try
            m := TIOMaster.Init;
            m.client := self;
        m.ntrend := true;
        
        
        unk := 0;
        pStep (0, all, unk);
        
        for curr := 1 to all do
        begin
            pSetPos (net, 1, ip);
            Inc (ip);
            
            data := pRead (net, 1);
            if (data = nil) then
            begin
                result := - 2;
                exit;
            end;
            inc (unk, m.parse (data, 1, v, nil, 0));
            pFreeRes (net, data);
            
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


function TAssoc.Run (p: Pointer): Pointer;
var
all, unk, curr, sz, icc, occ, i, j, ps, ip, op, dt: Integer;
m: TIOMaster;
//v: TVectorInt;
data: PB;
freez: TVectorBool;

begin
    
    result := nil;
    data := nil;
    
    
    
    m := nil;
    
    try
        try
            setlength (freez, ic);
            m := TIOMaster.Init;
            m.client := self;
        m.ntrend := true;
        
        unk := 0;
        
        inc (unk, m.parse (p, 1, nil, freez, 0));
        pFreeRes (net, p);
        
        
        (base_net as TNeuralNetHopfEx).CalcEx (freez );
        
        m.ep := 0;
        data := m.extract (true);
        
        
    finally
        m.Free;
        setlength (freez, 0);
    end;
    except
    MessageBox (hw, 'Runtime error.', 'Ошибка.', 0);
    FreeMem (data);
    data := nil;
end;

result := data;
end;




procedure TAssoc.Show;
begin
    MessageBox (hw, 'Данная библиотека не поддерживает графическое представление сети.', 'Сообщение.', 0);
end;


function TAssoc.Prop: Integer;
var dlg: TOKRightDlg;
res: integer;
begin
    result := 0;
    try
        try
            dlg := nil;
            dlg := TOKRightDlg.Create (nil);
            dlg.Label2.Visible := false;
            dlg.Label3.Visible := false;
            dlg.RxSpinEdit2.Visible := false;
            dlg.RxSpinEdit3.Visible := false;
            
            dlg.RxSpinEdit1.value := (base_net as TNeuralNetHopf).MaxIterCount;
            
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


