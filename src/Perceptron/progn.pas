unit progn;

interface
uses MyNet,NeuralBaseComp, NeuralBaseTypes,MyStream,
classes,prop,windows,sysutils, BPEx;
type
    TProgn=class(TMyNet)
    public
        constructor Do_Init;
        destructor Destroy; override;
        function Init:Integer;override;
        function Save:Integer;override;
        function Load:Integer;override;
        function Learn(a,b:Integer) : Integer;override;
        function Run(p:Pointer) : Pointer;override;
        procedure Show;override;
        function Prop:Integer;override;
    public
    //base_net: TNeuralNetHopf;
        p_en:	boolean;
        packet:	Integer;
        back, front, ic, oc:Integer;
end;

implementation
uses gate,IOMaster,recognize;

///////////////////////////////////////////////////////////////////////////////
//
//  constructor TProgn.Do_Init
//
///////////////////////////////////////////////////////////////////////////////

constructor TProgn.Do_Init;
begin
    Create;
    p_en:=true;
    base_net:=nil;
    packet:=5;
end;

///////////////////////////////////////////////////////////////////////////////
//
//  destructor TProgn.Destroy
//
///////////////////////////////////////////////////////////////////////////////

destructor TProgn.Destroy;
begin
    base_net.Free;
    inherited Destroy;
end;

///////////////////////////////////////////////////////////////////////////////
//
//  function TProgn.Init: Integer;
//
///////////////////////////////////////////////////////////////////////////////

function TProgn.Init:Integer;
var  dlg: TOKRightDlg;
     res,t,ww: Integer;
     m: TIOMaster;
     nn:TNeuralNetBPEx;
begin
    result:=0;
    try
        try
            m := nil;
            dlg := nil;
            m := TIOMaster.Init;
            m.client := self;
            ic := m.calc (true);
            oc := m.calc (false);
            try
                base_net := TNeuralNetBPEx.Create (nil);
                (base_net as TNeuralNetBPEx).pNet := self;

                (base_net as TNeuralNetBP).Alpha  := 5.0;
                (base_net as TNeuralNetBP).EpochCount := 1000;
                packet := 100;

                dlg := TOKRightDlg.Create (nil);
                if self is TRec then dlg.Par1.Value := 1;
                dlg.net := self;
                dlg.Par1.Enabled := p_en;
                dlg.Par2.Enabled := p_en;
                dlg.ic := ic;
                dlg.oc := oc;
                dlg.ListBox1.Items.AddObject ('������� ����',TObject (ic));
                dlg.ListBox1.Items.AddObject ('�s������ ����',TObject (oc));
                res := dlg.ShowModal ();
                if ((res < -1) or( res = 2)) then
                begin
                   result := 1;
                   exit;
                end;

                //t:=trunc(dlg.prop1.value);
                back := trunc (dlg.par1.value);
                front := trunc (dlg.par2.value);

                (base_net as TNeuralNetBPEx).ResetLayers;
                res := dlg.ListBox1.Items.Count - 1;
                for t := 0 to res do
                //ww:=Integer(dlg.ListBox1.Items.Objects[t]);
                    (base_net as TNeuralNetBPEx).AddLayer (Integer (dlg.ListBox1.Items.Objects [t]));

                (base_net as TNeuralNetBPEx).Init;
                (base_net as TNeuralNetBPEx).InitWeights;
                //   (base_net as TNeuralNetHopf).InitWeights;
            except
                base_net.free;
                base_net := nil;
                ic := 0;
                oc := 0;
                result := 1;
                MessageBox (hw, '�� ���� ������� ����.', '������.', 0);
                exit;
            end;
        finally
            m.free;
            dlg.Free;
        end;
    except
        MessageBox (hw, '�� ���� ������� ���� ���������� ����.', '������.', 0);
    end;

   (base_net as TNeuralNetBPEx).ContinueTeach := false;

end;

///////////////////////////////////////////////////////////////////////////////
//
//  function TProgn.Save: Integer;
//
///////////////////////////////////////////////////////////////////////////////

function TProgn.Save:Integer;
var nnm:String;
    fn: TMyStream;
    pos: Longint;
    b, tmp: double;
    bb: boolean;
    dd, i, j, l, k, sz, buf: Integer;
begin
    result:=1;
        try
            try
                nnm := String (project.Cur_Dir) + String (net.file_name);
                fn:=nil;

                try
                    fn := TMyStream.Create (nnm,fmOpenWrite);
                except
                    Exit;
            end;

            fn.seek( 0, soFromEnd);
            pos := fn.Position;

            fn.Write (back, sizeof (back));
            fn.Write (front, sizeof (front));

            with (base_net as TNeuralNetBPEx) do
            begin
                sz := LayerCount;
                fn.Write (sz, sizeof (sz));

                for k := 0 to LayerCount - 1 do
                begin
                    sz := LayersBP [k].NeuronCount;
                    fn.Write (sz, sizeof (sz));
                end;

                b := (base_net as TNeuralNetBPEx).Alpha;
                fn.Write (b, sizeof (b));
                b := (base_net as TNeuralNetBPEx).TeachRate;
                fn.Write (b, sizeof (b));
                bb := (base_net as TNeuralNetBPEx).Epoch;
                fn.Write (bb, sizeof (bb));
                dd := (base_net as TNeuralNetBPEx).EpochCount;
                fn.Write (dd, sizeof (dd));
                b := (base_net as TNeuralNetBPEx).Momentum;
                fn.Write (b, sizeof (b));
                b := (base_net as TNeuralNetBPEx).IdentError;
                fn.Write (b, sizeof (b));
                dd := packet;
                fn.Write (dd, sizeof (dd));

                for k := 1 to LayerCount - 1 do
                begin
                    sz := length (LayersBP [k]. Neurons [0].FWeights);//*sizeof(LayersBP[k].Neurons[0].FWeights[0]);
                    for i := 0 to LayersBP [k].NeuronCount-1 do
                    //fn.Write(LayersBP[k].Neurons[i].FWeights,sz);
                    for l := 0 to sz - 1 do
                    begin
                        tmp := LayersBP [k].Neurons [i].FWeights [l];
                        fn.Write(tmp, sizeof (tmp));
                    end;
                end;
            end;

            fn.Write( pos, sizeof (pos));
            result := 0;
        finally
            fn.Free;
            fn := nil;
        end;
    except

    end;
end;

///////////////////////////////////////////////////////////////////////////////
//
//      function TProgn.Load: Integer;
//
///////////////////////////////////////////////////////////////////////////////

function TProgn.Load:Integer;
var nnm: String;
    fn: TMyStream;
    pos: Longint;
    b, tmp: double;
    bb: boolean;
    dd, i, j, k, sz,l , buf, itc: Integer;
begin
    result := 1;
        try
	        try
	            nnm := String (project.Cur_Dir) + String (net.file_name);
	            fn := nil;
	            try
	                fn := TMyStream.Create (nnm,fmOpenRead);
	            except
	                Exit;
	            end;

                fn.seek ( - sizeof (pos), soFromEnd);
                fn.Read (pos, sizeof (pos));
                fn.seek (pos, soFromBeginning);
                fn.Read (back, sizeof (back));
                fn.Read (front, sizeof (front));
                base_net := TNeuralNetBPEx.Create (nil);
                (base_net as TNeuralNetBPEx).pNet := self;

                (base_net as TNeuralNetBPEx).ResetLayers;

                with (base_net as TNeuralNetBPEx) do
                begin
                    fn.Read (sz, sizeof (sz));
                    Dec (sz);

                    for k := 0 to sz do
                    begin
                        fn.Read (buf, sizeof (buf));
                        (base_net as TNeuralNetBPEx).AddLayer (buf);
                    end;

                    (base_net as TNeuralNetBPEx).Init;
                    fn.Read (b, sizeof (b));
                    (base_net as TNeuralNetBPEx).Alpha := b;
                    fn.Read(b,sizeof(b));
                    (base_net as TNeuralNetBPEx).TeachRate := b;
                    fn.Read(bb,sizeof(bb));
                    (base_net as TNeuralNetBPEx).Epoch := bb;

                    fn.Read (dd, sizeof (dd));
                    (base_net as TNeuralNetBPEx).EpochCount := dd;
                    fn.Read (b, sizeof (b));
                    (base_net as TNeuralNetBPEx).Momentum := b;
                    fn.Read (b, sizeof (b));
                    (base_net as TNeuralNetBPEx).IdentError := b;
                    fn.Read (dd, sizeof (dd));
                    packet := dd;

                    for k := 1 to sz do
                    begin
                        buf := length (LayersBP [k].Neurons [0].FWeights);//*sizeof(LayersBP[k].Neurons[0].FWeights[0]);
                        for i := 0 to LayersBP [k].NeuronCount - 1 do
                            for l := 0 to buf - 1 do
                            begin
                                fn.Read (tmp, sizeof (tmp));
                                LayersBP [k].Neurons [i].FWeights [l] := tmp;
                            end;
                      //fn.Read(LayersBP[k].Neurons[i].FWeights,1);
                    end;

	            result:=0;
	        end;

	        ic := (base_net as TNeuralNetBPEx).LayersBP [0].NeuronCount div back;
	        oc := (base_net as TNeuralNetBPEx).LayersBP [sz].NeuronCount div front;

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

    (base_net as TNeuralNetBPEx).ContinueTeach := true;
end;
{
  procedure outvect(var dbg:TextFile; vi: TVectorFloat);
  var i:Integer;
  begin
  		for i:=0 to Length(vi)-1 	do write(dbg,vi[i]:1:4);
        writeln(dbg);
  end;
 }

///////////////////////////////////////////////////////////////////////////////
//
//      function TProgn.Learn (a, b: Integer): Integer;
//
///////////////////////////////////////////////////////////////////////////////

function TProgn.Learn (a, b: Integer): Integer;
var all, unk, curr, icc, occ, i, j, ps, ip, op: Integer;
    m: TIOMaster;
    vi, vo: TVectorFloat;
    data: PB;
begin
    all := b - a + 1 - front - back + 1;    //����� ��������
    icc := ic * back;
    occ := oc * front;
    pSetPos (net, 1, a);
    result := -1;
    if (all < 1) then
    begin
        pStep (-1, -1, -1);
        exit;
    end;

    result := 1;

    setlength (vi, icc);
    setlength (vo, occ);
    m := nil;
    ip := a;
    op := a + back;

    try
        try
            m := TIOMaster.Init;
            m.client := self;
            Set_sv (project, 0);
            unk := 0;
            pStep (0, all, unk);

            for  curr := 1  to all  do
            begin
                if curr = 1 then
                begin
                    ps := icc - ic;
                    //������ �����
                    for j := 0 to back - 1 do
                    begin
                        pSetPos (net, 1, ip);
                        Inc (ip);
                        data := pRead (net, 1);
                        if (data = nil) then
                        begin
                            result := -2;
                            exit;
                        end;

                        inc (unk, m.parse (data, 1, vi,ps));
                        pFreeRes (net, data);
                        Dec(ps,ic);
                    end;

                    ps := 0;
                    //������ ������
                    for j := 0 to front - 1 do
                    begin
                        pSetPos (net, 1, op);
                        Inc (op);

                        data := pRead (net, 2);

                        if (data = nil) then
                        begin
                            result := -2;
                            exit;
                        end;

                        inc (unk, m.parse (data, 2, vo, ps));
                        pFreeRes (net, data);
                        Inc (ps,oc);
                    end
                end
                else
                begin
                    //������ ����
                    pSetPos (net, 1, ip);
                    Inc (ip);
                    data := pRead (net, 1);

                    if (data = nil) then
                    begin
                        result := -2;
                        exit;
                    end;

                    //�������� ������ �� ic
                    for i := icc - 1 downto ic do
                        vi [i] := vi [i - ic];

                    inc (unk, m.parse (data, 1, vi, 0));
                    pFreeRes (net, data);

                    //������ ������
                    pSetPos (net, 1, op);
                    Inc (op);
                    data := pRead (net,2);

                    if (data = nil) then
                    begin
                        result := -2;
                        exit;
                    end;

                    //����� �������
                    for i := 0  to occ - oc-1 do
                        vo [i] := vo [i + oc];

                    inc (unk, m.parse (data, 2, vo, occ - oc));
                    pFreeRes (net, data);
                end;

                (base_net as TNeuralNetBPEx).AddPattern (vi, vo);
                if (curr = all) or (curr mod packet = 0) then
                begin
                    (base_net as TNeuralNetBPEx).TeachOffLine;
                    (base_net as TNeuralNetBPEx).ResetPatterns;
                    (base_net as TNeuralNetBPEx).ContinueTeach := true;
                end;

                if (pStep (curr, all, unk) = 1) then
                begin
                    result := 1;
                    pStep (-1, -1, -1);
                    exit;
                end;
            end;
        finally
            m.Free;
            setlength (vi, 0);
            setlength (vo, 0);
        end;
    except
        pStep (-1, -1, -1);
        MessageBox (hw, '�� ���� ������� ����.', '������.', 0);
    end;

    result := 0;
end;

///////////////////////////////////////////////////////////////////////////////
//
//      function TProgn.Run (p: Pointer): Pointer;
//
///////////////////////////////////////////////////////////////////////////////

function TProgn.Run (p: Pointer): Pointer;
var all, unk, curr, sz, icc, occ, i, j, ps, ip, op, dt: Integer;
    m: TIOMaster;
    v: TVectorFLoat;
    data, d0, tmp: PB;
begin
    v := nil;
    d0 := nil;
    result := nil;
    if PINT (p)^ = 0 then
    begin
        PINT (p)^ := front;
        exit;
    end;

    if PINT (p)^ = -1 then
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
    m := nil;

    try
        setlength (v, icc);
        try
            m := TIOMaster.Init;
            m.client := self;
            unk:=0;
            ps := icc - ic * (dt + 1);

            //������ �����
            for j := 0 to back - 1 - dt do
            begin
                data := pRead (net, 1);
                if (data = nil) then
                begin
                    result := nil;
                    exit;
                end;

                inc (unk, m.parse (data, 1, v, ps));
                pFreeRes(net, data);
                pSetPos (net, 0, 1);
                Dec(ps,ic);
            end;

            (base_net as TNeuralNetBPEx).Compute (v);
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
                tmp:=nil;
                d0:=nil;
            end
        finally
            if v <> nil then setlength (v, 0);
            v := nil;
            if d0 <> nil then FreeMem (d0);
            if tmp <> nil then FreeMem (tmp);
            m.Free;
        end;
    except
        MessageBox (hw, 'Runtime error.', '������.', 0);
    end;

    PINT (p)^ := unk;
    result := data;
    
end;

///////////////////////////////////////////////////////////////////////////////
//
//      procedure TProgn.Show;
//
///////////////////////////////////////////////////////////////////////////////

procedure TProgn.Show;
begin
    MessageBox (hw,
                '������ ���������� �� ������������ ����������� ������������� ����.',
                '���������.',
                0);
end;

///////////////////////////////////////////////////////////////////////////////
//
//      function TProgn.Prop: Integer;
//
///////////////////////////////////////////////////////////////////////////////

function TProgn.Prop: Integer;
var dlg: TOKRightDlg;
    e, res, k, i: integer;
begin
    result := 0;
    try
        try
            dlg := nil;
            dlg := TOKRightDlg.Create (nil);
            dlg.par1.value := back;
            dlg.par2.value := front;
            dlg.ListBox1.Items.AddObject ('������� ����',TObject ((base_net as TNeuralNetBPEx).LayersBP [0].NeuronCount));
            dlg.ListBox1.Items.AddObject ('�������� ����',
                TObject ((base_net as TNeuralNetBPEx).LayersBP [(base_net as TNeuralNetBPEx).LayerCount - 1].NeuronCount));

            dlg.Cnt.Enabled := false;
            with (base_net as TNeuralNetBPEx) do
            begin
                for k := 1 to LayerCount - 2 do
                begin
                    i := dlg.ListBox1.Items.Count;
                    dlg.ListBox1.Items.InsertObject (i - 1, '���� �' + IntToStr (i),
                                                     TObject (LayersBP [k].NeuronCount));
                end;
            end;

	        dlg.net := self;
            dlg.par1.Enabled := false;
        	dlg.par2.Enabled := false;
	        res := dlg.ShowModal ();
	        if res <> 1 then
	        begin
	            exit;
	        end;
	        result := 1;
        finally
	        dlg.Free;
        end;
    except
	    MessageBox (hw, '�� ���� ������� ���� ���������� ����.',
                    '���������.', 0);
	    result := 0;
    end;
    
end;

end.
