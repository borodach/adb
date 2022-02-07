unit T_Net;
interface

uses sharemem,
Windows,
MainForm,
SysUtils,
Forms,
doswin,
comctrls,
classes,
MyStream,
dbtables,
ExternDll;
type
//������� �������� ��������� �������

//
//�������� ����
//

CreateProc = function (p: Pointer): Integer; cdecl;
SaveProc = function (p: Pointer): Integer; cdecl;
LoadProc = function (p: Pointer): Integer; cdecl;

//
//����������� ����
//

DestroyProc = procedure (p: Pointer); cdecl;

//
//�������� ����
//

LearnProc = function (p: Pointer;
a,
b: Integer): Integer; cdecl;

//
//������� ������ � ����
//

ShowProc = procedure (p: Pointer); cdecl;

//
// ����� �� ��������� ���������
//

PropertyProc = function (p: Pointer): Integer; cdecl;

//
//��� ��� �� ����
//

InfoProc = function (p: Pointer): Integer; cdecl;

//
//��������� ���� ������ ����
//

RunProc = function (p, info: Pointer): Pointer; cdecl;

//
//������� �����, � ������� ���� ���������� ���������
//

FreeResProc = procedure (p: Pointer); cdecl;

//
//��������� �������� � �����������
//

PreCreateProc = function (hw: HWND;
pPr,
pSNet,
pFind,
pGetP,
pGetPole,
pSetPos,
pGetPos,
pRead,
pFreeRes,
pStep,
Set_sv: Pointer): Pointer; cdecl;

{
    �-��� ������� ��������� ���� � ��������� �� � ���������
    pSNet - ��������� �� '��������' ����
    pFind - ������� ������  � �������
    pGetP - ������ � ������ �������
    pGetPole - ������ � ���� �������
    pSetPos - ���������������� � �������
    pRead - ������ �� �������
    pFreeRes - ������� ������ ������ � ��������
    pStep - ����������� ���� ��������   procedure Step(curr,all,unk:Integer);stdcall;
    }



Field_View = record
    Num: integer; //Num ����� ����, ���������� � 1, ���� <0, �� �����
    porog: double; //����� ������������� ������
    dt: Double;
    minVal: Double;
    cnt: integer;
    initialized: integer;
    frozen: integer;
end;

PF = ^Field_View;


TNet = class
    
    _parent: Pointer; //��������� �� �������
    In_Fields: PF;
    Out_Fields: PF; // ^Field_View; //������ �������/�������� �����
    //���� � ���� �������������, �� ����� ��� �����
    In_Count: Integer;
    Out_Count: Integer; //���������� ������/������� ����
    _type: integer; //�������, �������������, ����� ����������;
    dt: TDateTime; //����� �������� ����
    file_name: PChar;
    Rem: PChar;
    is_saved: integer;
    
    
    pNet: Pointer; //��������� �� ����, ������������� � DLL
    dll_file_name: PChar; //���� � �����������
    lib: LongInt ; //���������� ����������
    
    //
    //��������� �� ������� � dll
    //
    
    DllCreateNet: CreateProc;
    DllSaveNet: SaveProc;
    DllLoadNet: LoadProc;
    DllDestroyNet: DestroyProc;
    DllLearnNet: LearnProc;
    DllShowNet: ShowProc;
    DllProperty: PropertyProc;
    Dll_Who_Are_You: InfoProc;
    DllRunNet: RunProc;
    DllFreeResult: FreeResProc;
    DllPreCreate: PreCreateProc;
    
    id: Pointer;
    
    m_nFirstRec, m_nLastRec: Integer;
    
    
    
    function ReadData (io: Integer): Pointer;stdcall;
    //io 1 - in, 2 - out, 3 - in out
    {
            	������ ����������:������� - ����� ������ ������, ����� - ������,
            	���, ������.
            	}
    
    procedure FreeResult (p: Pointer); stdcall; //������� �����
    procedure SetPos (a, b: Integer); stdcall;
    procedure GetPos (a, b: Pointer); stdcall;
    
    function Save: Boolean;
    function Load: Boolean;
    function InitNet: Boolean;
    function Learn: Integer;
    function CreateNet: Boolean;
    procedure DestroyNet;
    procedure Run;
    procedure ShowNet;
    procedure Set_Param;
    procedure Init (p: Pointer);
    procedure AddIn (i: Integer; f: Boolean);
    procedure AddOut (i: Integer; f: Boolean);
    procedure DelIn (i: Integer);
    procedure DelOut (i: Integer);
    procedure Minim (var ar: PF; var siz: Integer);
    procedure showInfo (var f: Text; p0, p1: Integer);
end;

implementation

Uses Dictonary,
dyn_array,
NetCreationForm,
WaitForTraining,
main,
RecordSelectionForm,
PredictionForm,
ClusteringForm,
AssociativeSearchForm;

var fst, lst: Integer;
bigBuffer: array [0..32000] of integer;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TNet.ShowNet                                    //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

procedure TNet.ShowNet;
var f: ShowProc;
begin
    f := DllShowNet;
    f (pNet);
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TNet.Set_Param                                  //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

procedure TNet.Set_Param;
var f: PropertyProc;
begin
    f := DllProperty;
    f (pNet);
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TNet.AddIn                                      //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

procedure TNet.AddIn (i: Integer;f: Boolean);
var t1: PField;
//t: d_array;
begin
    ReallocMem (In_Fields,
    sizeof (Field_View) * (In_Count + 1));
    t1 := In_Fields;
    Inc (t1, In_Count);
    Inc (In_Count);
    
    if f then t1^.Num := - i else
    t1^.Num := i;
    
    t1^.porog := 0;
    // t:=Pole(Dict(_parent).GetField(i-1)).Voc;
    
    t1^.minVal := 0;
    t1^.dt := 0;
    t1^.cnt := 0;
    t1^.initialized := 0;
    t1^.frozen := 0;
    //t1^.pmin:=t.GetP(0);
    //t1^.pmax:=t.GetP(t.pos);
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TNet.AddOut                                     //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

procedure TNet.AddOut (i: Integer; f: Boolean);
var t1: ^Field_View;
//t: d_array;
begin
    
    ReallocMem (Out_Fields,
    sizeof (Field_View) * (Out_Count + 1));
    t1 := Out_Fields;
    Inc (t1, Out_Count);
    Inc (Out_Count);
    
    t1^.porog := 0;
    
    if f then t1^.Num := - i else
    t1^.Num := i;
    //  t:=Pole(Dict(_parent).GetField(i-1)).Voc;
    
    t1^.dt := 0;
    t1^.cnt := 0;
    t1^.minVal := 0;
    t1^.initialized := 0;
    t1^.frozen := 0;
    //t1^.pmin:=t.GetP(0);
    //t1^.pmax:=t.GetP(t.pos);
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TNet.DelIn                                      //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

procedure TNet.DelIn (i: Integer);
var j: Integer;
t1, t2: ^Field_View;
begin
    
    t1 := In_Fields;
    Inc (t1, i);
    t2 := t1;
    Inc (t2);
    Dec (In_Count);
    
    for j := i to In_Count do
    begin
        move (t2^, t1^, sizeof (Field_View));
        Inc (t1);
        Inc (t2);
    end;
    
    ReallocMem (In_Fields,
    sizeof (Field_View) * In_Count);
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TNet.DelOut                                     //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

procedure TNet.DelOut (i: Integer);
var j: Integer;
t1, t2: ^Field_View;
begin
    t1 := Out_Fields;
    Inc (t1, i);
    t2 := t1;
    Inc (t2);
    Dec (Out_Count);
    
    for j := i to Out_Count do
    begin
        move (t2^, t1^, sizeof (Field_View));
        Inc (t1);
        Inc (t2);
    end;
    
    ReallocMem (Out_Fields, sizeof (Field_View) * Out_Count);
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TNet.InitNet                                    //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

function TNet.InitNet: Boolean;
var tt: PreCreateProc;
begin
    InitNet := False;
    lib := LoadLibrary (dll_file_name);
    if lib < 32 then
    begin
        MessageBox (Form1.Handle,
        PChar ('�� ���� ������� ���������� ' +
        dll_file_name),
        '������',
        0);
        Exit;
    end;
    
    DllCreateNet := GetProcAddress (lib, 'CreateNet');
    DllLoadNet := GetProcAddress (lib, 'LoadNet');
    DllSaveNet := GetProcAddress (lib, 'SaveNet');
    DllDestroyNet := GetProcAddress (lib, 'DestroyNet');
    DllLearnNet := GetProcAddress (lib, 'LearnNet');
    DllShowNet := GetProcAddress (lib, 'ShowNet');
    DllProperty := GetProcAddress (lib, 'NetProperty');
    Dll_Who_Are_You := GetProcAddress (lib, 'Who_Are_You');
    DllRunNet := GetProcAddress (lib, 'RunNet');
    DllFreeResult := GetProcAddress (lib, 'FreeResult');
    DllPreCreate := GetProcAddress (lib, 'PreCreateNet');
    
    //DllGetError:=GetProcAddress(lib,'GetError');
    tt := DllPreCreate;
    
    if (Addr (DllPreCreate) = nil) or
    (Addr (DllFreeResult) = nil) or
    (Addr (DllRunNet) = nil) or
    (Addr (Dll_Who_Are_You) = nil) or
    (Addr (DllProperty) = nil) or
    (Addr (DllShowNet) = nil) or
    (Addr (DllLearnNet) = nil) or
    (Addr (DllDestroyNet) = nil) or
    (Addr (DllSaveNet) = nil) or
    (Addr (DllLoadNet) = nil) or
    (Addr (DllCreateNet) = nil) then
    begin
        FreeLibrary (lib);
        MessageBox (Form1.Handle,
        PChar ('���������� ' + dll_file_name +
        ' ����������.'),
        '������',
        0);
        Exit;
    end;
    
    pNet := tt (Form1.Handle,
    pr,
    self,
    Addr (d_array.Find),
    Addr (Dict.GetField),
    Addr (d_array.GetP),
    Addr (TNet.SetPos),
    Addr (TNet.GetPos),
    Addr (TNet.ReadData),
    Addr (TNet.FreeResult),
    Addr (SetProgress),
    Addr (TProject.Set_Saved));
    
    if pNet = nil then
    FreeLibrary (lib)
    else
    InitNet := TRUE;
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TNet.Init                                       //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

procedure TNet.Init (p: Pointer);
begin
    
    _parent := p;
    Rem := nil;
    dll_file_name := nil;
    pNet := nil;
    In_Fields := nil;
    Out_Fields := nil;
    In_Count := 0;
    Out_Count := 0;
    
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TNet.Save                                       //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

function TNet.Save: Boolean;
var r, cod: Integer;
res: Boolean;
fn: TMystream;
nnm: string;
tmp: SaveProc;
begin
    
    tmp := DllSaveNet;
    if (pr.Save_As = 0) and (is_saved = 1) then
    begin
        Save := true;
        Exit;
    end;
    
    //fl:=true;
    Save := False;
    nnm := String (pr.Cur_Dir) + String (file_name);
    fn := nil;
    
    try
        fn := TMyStream.Create (nnm, fmCreate);
        except
        fn.Free;
        fn := nil;
        Exit;
    end;
    
    try
        cod := $9a966;
        fn.Write (cod, sizeof (integer));
        
        if (not MySaveStr (fn, Rem)) then
        raise Exception.Create ('������');
        
        if (not MySaveStr (fn, dll_file_name)) then
        raise Exception.Create ('������');
        
        fn.Write (dt, sizeof (dt));
        
        fn.Write (m_nFirstRec, sizeof (m_nFirstRec));
        fn.Write (m_nLastRec, sizeof (m_nLastRec));
        
        fn.Write (_type, sizeof (_type));
        
        fn.Write (In_Count, sizeof (In_Count));
        
        fn.Write (In_Fields^, sizeof (Field_View) * In_Count);
        
        fn.Write (Out_Count, sizeof (Out_Count));
        
        fn.Write (Out_Fields^, sizeof (Field_View) * Out_Count);
        //fl:=False;
        fn.Free;
        fn := nil;
        
        res := (tmp (pNet) = 0);
        Save := res;
        
        if res then is_saved := 1;
        except
        on e: EInOutError do
        begin
            try
                fn.Free;
                except
            end;
            
            DeleteFile (nnm);
            MessageBox (Form1.Handle,
            PChar (e.Message),
            PChar ('������ .'),
            0);
        end;
        
        on e: Exception do
        begin
            
            try
                fn.Free;
                except
            end;
            
            DeleteFile (nnm);
            MessageBox (Form1.Handle,
            PChar (e.Message),
            PChar ('������.'),
            0);
        end
    end;
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TNet.Load                                       //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

function TNet.Load: Boolean;
var t, cod: Integer;
tn: TTreeNode;
err: Integer;
nnm: String;
//cn: CreateProc;
//res:Boolean;
tmp: LoadProc;
fn: TStream;
begin
    Load := False;
    id := nil;
    Init (_parent);
    
    nnm := String (pr.Cur_Dir) + String (file_name);
    fn := nil;
    try
        fn := TMyStream.Create (nnm, fmOpenRead);
        {if(IOResult<>0) then
                       	 begin
                     		CloseFile(fn);
                     		Exit;
                       	end; }
        // try
        
        cod := 0;
        fn.read (cod, sizeof (Integer));
        if cod <> $9a966 then
        raise EInOutError.Create ('���������������� ������ ����� ��������� ����' + file_name + '.');
        
        if (not MyLoadStr (fn, @Rem)) then
        raise Exception.Create ('������');
        
        if (not MyLoadStr (fn, @dll_file_name)) then
        raise Exception.Create ('������');
        
        fn.Read (dt, sizeof (dt));
        
        fn.Read (m_nFirstRec, sizeof (m_nFirstRec));
        fn.Read (m_nLastRec, sizeof (m_nLastRec));
        
        fn.Read (_type, sizeof (_type));
        
        fn.Read (In_Count, sizeof (In_Count));
        t := sizeof (Field_View) * In_Count;
        GetMem (In_Fields, t);
        fn.Read (In_Fields^, t);
        
        fn.Read (Out_Count, sizeof (Out_Count));
        t := sizeof (Field_View) * Out_Count;
        GetMem (Out_Fields, t);
        fn.Read (Out_Fields^, t);
        fn.Free;
        fn := nil;
        
        if not InitNet then
        begin
            DestroyNet;
            Exit;
        end;
        
        {cn:=DllCreateNet;
                     	err:=cn(pNet);
                     	case err of
                     	0: ;
                     	else
                       	begin
                     	MessageBox(Form1.Handle,'������������ ������ ��� �������� ����.','������ 1.',0);
                     	exit;
                       	end;
                     	end;}
        
        id := createParser (Dict (_parent)._fields,
        Dict (_parent).Count,
        In_Fields,
        In_Count,
        Out_Fields,
        Out_Count);
        
        if not InitNet then
        begin
            DestroyNet;
            Exit;
        end;
        
        if self.DllLoadNet (pNet) <> 0 then
        begin
            DestroyNet;
            Exit;
        end;
        
        tn := Form1.Tree1.Items.AddChild (Form1.Tree1.Selected,
        Rem + ' ( ������� ' + DateTimeToStr (dt) + ', ����: ' +
        file_name + ').');
        
        if tn = nil then
        begin
            DestroyNet;
            MessageBox (Form1.Handle,
            '������������ ������ ��� �������� ����.',
            'Error',
            0);
            Exit;
        end;
        
        tn.Data := self;
        Load := True;
        is_saved := 1;
        except
        try
            fn.Free;
            except
        end;
        
        DestroyNet;
    end;
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TNet.DestroyNet                                 //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

procedure TNet.DestroyNet;
type pint = ^Integer;
var dp: DestroyProc;
begin
    dp := DLLDestroyNet;
    
    if pNet <> nil then
    begin
        dp (pNet);
        FreeLibrary (lib);
    end;
    
    destroyParser (id);
    
    myStrDispose (Rem);
    myStrDispose (file_name);
    myStrDispose (dll_file_name);
    FreeMem (In_Fields, sizeof (pInt) * In_Count);
    FreeMem (Out_Fields, sizeof (pInt) * Out_Count);
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TNet.GetPos                                     //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

procedure TNet.GetPos (a, b: Pointer); stdcall;
begin;
    Integer (a^) := pr.Query.RecNo;
    Integer (b^) := pr.Query.RecordCount;
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TNet.SetPos                                     //
//                                                            //
//  Description                                               //
//	a 0-���������� �� b,1- ���������� ����� 2- � ������       //
//	3 - � �����. ��������� - ����� �������                    //
//                                                            //
////////////////////////////////////////////////////////////////

procedure TNet.SetPos (a, b: Integer); stdcall;
begin
    with Pr.Query do
    begin
        case a of
            0: MoveBy (b);
            1: MoveBy (b - RecNo);
            2: First;
            3: Last;
        end;
    end;
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TNet.FreeResult                                 //
//                                                            //
//  Description  ������� �����                                //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

procedure TNet.FreeResult (p: Pointer); stdcall;
var i: Integer;
begin
    
    if p = nil then Exit;
    
    GlobalFree (HGLOBAL (p));
    
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TNet.ReadData                                   //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

function TNet.ReadData (io: Integer): Pointer; stdcall;
var i,
j,
siz,
v,
bb,
vi: Integer;

st: PChar;

tt: Pointer;

t: ^ShortInt;

// tmp:^Field_View;
pp: Pole;

vf,
db: double;

vc: Currency;

pMin,
pMax: Pointer;

begin
    result := nil;
    j := 0;
    // ������� ������� ������
    
    with pr.Query do
    begin
        siz := getSize (id, pr.Query, io) + sizeof (integer);
        //tmp:=In_Fields;
        
        if (siz > 512) then
        tt := Pointer (GlobalAlloc (GMEM_FIXED, siz))
        else
        tt := Pointer (GlobalAlloc (GMEM_FIXED, 512));
        
        //GetMem(tt,siz);
        
        //tt:=@bigBuffer;
        
        
        if tt = nil then
        begin
            result := nil;
            exit;
        end;
        
        //
        //���������� ������
        //
        
        t := tt;
        pint (t)^ := siz;
        Inc (t, sizeof (Integer));
        
        //
        //����� ������
        //
        
        writeBuffer (id, @t, pr.Query, io);
        
        result := tt;
        
    end;
end;


{
    ������ ����������:������� - ����� ������ ������, ����� ������ ���� ������
    �������� � ����, �������, ������� ������������� ��������� � �������� In_Fields � Out_Fields,
    ��� �������� �� DLL }

////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TNet.Minim                                      //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

procedure TNet.Minim (var ar: PF; var siz: Integer);
var i, j: Integer;
tt,
tt1,
tt2: ^Field_View;

begin
    i := 0;
    tt := ar;
    
    while i < siz - 1 do
    begin
        tt1 := tt;
        Inc (tt1);
        j := i + 1;
        
        while j < siz do
        begin
            if (tt1^.Num = tt^.Num) and
            (tt1^.dt = tt^.dt) and
            (tt1^.minVal = tt^.minVal) and
            (tt1^.porog = tt^.porog) then
            begin
                tt2 := tt1;
                Inc (tt2);
                move (tt2^, tt1^, sizeof (Field_View) * (siz - j - 1));
                Dec (Siz);
            end
            
            else
            begin
                Inc (j);
                Inc (tt1);
            end;
        end;
        
        Inc (i);
        Inc (tt);
    end;
    
    ReallocMem (ar, siz * sizeof (Field_View));
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TNet.CreateNet                                  //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

function TNet.CreateNet: Boolean;
var err: Integer;
cn: CreateProc;
tn: TTreeNode;
begin
    CreateNet := False;
    id := nil;
    
    try
        CreateForm := TCreateForm.Create (Application);
        except
        CreateForm.Free;
        MessageBox (Form1.Handle,
        '�� ���� ������� ����.',
        '������.',
        0);
        Exit;
    end;
    
    CreateForm.net := self;
    
    if CreateForm.ShowModal <> 1 then
    begin
        CreateForm.Destroy;
        Exit;
    end;
    
    CreateForm.Destroy;
    Minim (In_Fields, In_Count);
    Minim (Out_Fields, Out_Count);
    
    id := createParser (Dict (_parent)._fields,
    Dict (_parent).Count,
    In_Fields,
    In_Count,
    Out_Fields,
    Out_Count);
    
    if not InitNet then Exit;
    
    cn := DllCreateNet;
    err := cn (pNet);
    
    case err of
        0: ;
        
        else
        begin
            //MessageBox(Form1.Handle,'������������ ������ ��� �������� ����.','������ 1.',0);
            exit;
        end;
    end;
    
    err := Learn;
    
    case err of
        - 2:
        begin
            MessageBox (Form1.Handle,
            '��������� �������� ������� ���.',
            PChar ('������ ' + IntToStr (err) + '.'),
            0);
            Exit;
        end;
        
        - 1:
        begin
            MessageBox (Form1.Handle,
            '������ ���� ������ ��� ��������� ������.',
            PChar ('������ ' + IntToStr (err) + '.'),
            0);
            Exit;
        end;
        
        0: ;
        
        1: Exit;
        
        else
        begin
            MessageBox (Form1.Handle,
            '����������� ������.',
            PChar ('������ ' + IntToStr (err) + '.'),
            0);
            exit;
        end;
    end;
    
    dt := Now;
    tn := Form1.Tree1.Items.AddChild (Form1.Tree1.Selected, Rem +
    ' (������� ' + DateTimeToStr (dt) + ' ,����: ' +
    file_name + ').');
    
    if tn = nil then
    begin
        MessageBox (Form1.Handle,
        '������ ��������� ������.',
        '������',
        0);
        Exit;
    end;
    
    tn.Data := self;
    is_saved := 0;
    pr.Set_Saved (0);
    CreateNet := true;
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TNet.Run  	                                  //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

procedure TNet.Run;
begin
    case _type of
        0:
        begin
            try
                Prognoz := TPrognoz.Create (Application);
                Prognoz.p := self;
                Prognoz.ShowModal;
                Prognoz.Destroy;
                except
                Prognoz.Free;
                MessageBox (Form1.handle,
                '�� ���� ������� ����.',
                '������.',
                0);
            end;
        end;
        
        1, 2:
        begin
            try
                Cluster := TCluster.Create (Application);
                Cluster.p := self;
                Cluster.ShowModal;
                Cluster.Destroy;
                except
                Cluster.Free;
                MessageBox (Form1.handle,
                '�� ���� ������� ����.',
                '������.',
                0);
            end;
        end;
        
        3:
        begin
            try
                Assoc := TAssoc.Create (Application);
                Assoc.p := self;
                Assoc.ShowModal;
                Assoc.Destroy;
                except
                Assoc.Free;
                MessageBox (Form1.handle,
                '�� ���� ������� ����.',
                '������.',
                0);
            end;
        end;
    end
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure f				                                  //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

function f (p: TNet): Integer;
var t: LearnProc;
//SecondSession: TSession;
begin{
    try
        SecondSession := TSession.Create (nil);
        SecondSession.SessionName := 'SecondSession';
        SecondSession.KeepConnections := False;
        SecondSession.Open;
        Pr.Query.Close;
        Pr.Query.SessionName := 'SecondSession';
        Pr.Query.Open; }
        t := p.DllLearnNet;
        f := t (p.pNet, p.m_nFirstRec, p.m_nLastRec);
    {
    finally
        Pr.Query.Close;
        Pr.Query.SessionName := '';
        SecondSession.Free;
        Pr.Query.Open;
    end; }
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TNet.Learn                                      //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

function TNet.Learn: Integer;

var id, c: Cardinal;

begin
    Result := 1;
    try
        Inter := TInter.Create (Application);
        m_nFirstRec := 1;
        if _type = 0 then
        begin
            
            if pr.Query.RecordCount < 2 then
            begin
                MessageBox (Form1.Handle,
                '������� ���� ������ ��� ��������. ��������� �� ����� 2 �����.',
                '������.',
                0);
                Exit;
            end;
            
            m_nLastRec := pr.Query.RecordCount - 1;
        end
        
        else
        begin
            
            if pr.Query.RecordCount < 1 then
            begin
                MessageBox (Form1.Handle,
                '������� ���� ������ ��� ��������. ��������� �� ����� 1 ������.',
                '������.',
                0);
                Exit;
            end;
            
            m_nLastRec := pr.Query.RecordCount;
        end;
        //lst:=pr.Query.RecordCount-1;
        
        Inter.Init (@m_nFirstRec, @m_nLastRec);
        
        Inter.Caption := '������� ��������� �������� ����.';
        
        if Inter.ShowModal < 0 then
        begin
            Inter.Destroy;
            Exit;
        end;
        
        Inter.Destroy;
        
        Form20 := TForm20.Create (Application);
        
        except
        Inter.Free;
        Form20.Free;
        MessageBox (Form1.Handle,
        '�� ���� ������� ����.',
        '������.',
        0);
        Result := 1;
        Exit;
        
    end;
    
    SetProgress (0, 0, 0);
    hThread := BeginThread (nil, 0, Addr (f), self, 0, id);
    Form20.ShowModal;
    Form20.Destroy;
    //repeat
    //GetExitCodeThread(d,c);
    //until(c<>Still_Active);

    WaitForSingleObject (hThread, INFINITE);
    GetExitCodeThread (hThread, c);
    CloseHandle (hThread);
    hThread := 0;
    Result := c;
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TNet.ShowInfo                                   //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

procedure TNet.ShowInfo (var f: Text; p0, p1: Integer);
begin
    
    write (f, '������������� ����: ');
    
    case _type of
        0:
        begin
            writeln (f, '�������');
            writeln (f, '������� �������: ', p0 );
            writeln (f, '������� ��������: ', p1);
        end;
        1: writeln (f, '�������������');
        3: writeln (f, '�������������');
        4: writeln (f, '����� ����������');
    end;
    
    writeln (f, '����� ������� �����: ', In_Count);
    writeln (f, '����� �������� �����: ', Out_Count);
    
end;


end.


