unit recognize;

interface
uses ShareMem, MyNet, NeuralBaseComp, NeuralBaseTypes, MyStream,
classes, prop, windows, sysutils, progn, BPEx;
type
TRec = class (TProgn)
public
    constructor Do_Init;
    function Learn (a, b: Integer): Integer;override;
    function Run (p: Pointer): Pointer;override;
public
    //base_net: TNeuralNetHopf;
    //packet:	Integer;
    //back,front,ic,oc:Integer;
    
end;

implementation
uses gate, IOMaster;
constructor TRec.Do_Init; 
begin
    inherited;
    p_en := false;
end;
{
procedure outvect(var dbg:TextFile; vi: TVectorFloat);
  var i:Integer;
  begin
  		for i:=0 to Length(vi)-1 	do write(dbg,vi[i]:1:4,' ');
        writeln(dbg);
  end;
 }
function TRec.Learn (a, b: Integer): Integer;
var ii, all, unk, curr, icc, occ, i, j, ps, ip, op: Integer;
m: TIOMaster;
vi, vo: TVectorFloat;
data: PB;
//dbg: TextFile;
//cc:Integer;
begin
    //cc:=1;
    //  try
    //  Assign(dbg,'debug.txt');
    //  Append(dbg);
    //  write(dbg,'Обучение сети.');
    //  form5 := nil;
    try
        // form5 := TForm5.Create(nil);
        // form5.Init(100);
        all := b - a + 1; //число образцов
        ii := 0;
        result := - 1;
        if (all < 1) then
        begin
            pStep (- 1, - 1, - 1);
            exit;
        end;
        Set_sv (project, 0);
        result := 1;
        //sz:=ic*back+oc*front;
        op := (base_net as TNeuralNetBPEx).LayersBP [0].NeuronCount;
        setlength (vi, op);
        ip := (base_net as TNeuralNetBPEx).LayerCount - 1;
        op := (base_net as TNeuralNetBPEx).LayersBP [ip].NeuronCount;
        setlength (vo, op);
        
        m := nil;
        ip := a;
        try
            try
                m := TIOMaster.Init;
                m.client := self;
                
                unk := 0;
                pStep (0, all, unk);
                ii := 0;
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
                    inc (unk, m.parse (data, 1, vi, 0));
                    pFreeRes (net, data);
                    //##freemem(data);
                    //читаем входы
                    data := pRead (net, 2);
                    if (data = nil) then
                    begin
                        result := - 2;
                        exit;
                    end;
                    inc (unk, m.parse (data, 2, vo, 0));
                    pFreeRes (net, data);
                    //##FreeMem(data);
                    // outvect(dbg,vi);
                    // outvect(dbg,vo);
                    with ((base_net as TNeuralNetBPEx)) do
                    begin
                        AddPattern (vi, vo);
                        if ((curr = all) or (ii = packet - 1)) then
                        begin
                            ii := 0;
                            TeachOffLine;
                            ResetPatterns;
                            ContinueTeach := true;
                        end;
                        inc (ii);
                        
                        //TeachOffLine;
                        //InitWeights1;
                        //DeletePattern(1);
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
                setlength (vi, 0);
                setlength (vo, 0);
                
            end;
            except
            pStep (- 1, - 1, - 1);
            MessageBox (hw, 'Не могу обучить сеть.', 'Ошибка.', 0);
        end;
        //finally
        //  Closefile(dbg);
        //end;
        result := 0;
    finally
        //form5.Free;
    end;
    
end;


function TRec.Run (p: Pointer): Pointer;
var
all, unk, curr, sz, icc, occ, i, j, ps, ip, op, dt: Integer;
m: TIOMaster;
v: TVectorFLoat;
data, d0, tmp: PB;
//gg: Integer;
//rr:Double;
//dbg: TextFile;

begin
    v := nil;
    d0 := nil;
    result := nil;
    
    // try
    // Assign(dbg,'debug.txt');
    // Append(dbg);
    
    try
        setlength (v, (base_net as TNeuralNetBPEx).Layers [0].NeuronCount);
        try
            m := TIOMaster.Init;
            m.client := self;
            
            unk := 0;
            
            data := pRead (net, 1);
            if (data = nil) then
            begin
                result := nil;
                exit;
            end;
            
            inc (unk, m.parse (data, 1, v, 0));
            pFreeRes (net, data);
            //##freemem(data);
            pSetPos (net, 0, 1);
            
            // outvect(dbg,v);
            
            (base_net as TNeuralNetBPEx).Compute (v);
            
            
            // 		rr:=(base_net as TNeuralNetBPEx).Output[0];
            //       write(dbg,rr:1:4);
            
            // writeln(dbg);
            
            d0 := nil;
            tmp := nil;
            data := nil;
            op := 0;
            
            m.ep := 0;
            
            d0 := m.extract (false);
            
        finally
            if v <> nil then setlength (v, 0);
            v := nil;
        end;
        except
        MessageBox (hw, 'Runtime error.', 'Ошибка.', 0);
    end;
    //finally
    //	CloseFile(dbg);
    //end;
    PINT (p)^ := unk;
    result := d0;
end;
end.


