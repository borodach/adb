unit Main;
interface
uses ShareMem, windows;
type
Field_View = record
    Num: integer; //Num ����� ����, ���������� � 1, ���� <0, �� �����
    porog: double; //����� ������������� ������
    dt: Variant;
    minVal: Variant;
    cnt: integer;
    //pmin,pmax:Pointer;
end;
PF = ^Field_View;


TProject = class
    file_name: PChar; //���� � ��������� �������
    cur_dir: PChar;
    Saved: Integer; //1 ���� �� ����� ���������
    Save_As: Integer;// 1 ���� ����������� Save as...
    DW: boolean;
    Comment: TObject; //����������
    Query: TObject;
end;
d_array = class
    inf: Pointer;
    dsz, pos, siz, info_size: Integer;
    is_PChar: Boolean;
    Cmp: Pointer;
end;
Pole = class
    name: PChar;
    num: Integer;
    F_Type: Integer;
    tr_num: Integer;
    voc: d_array;
end;



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

TNet = class
    
    _parent: TObject; //��������� �� �������
    In_Fields: PF;
    Out_Fields: PF;// ^Field_View; //������ �������/�������� �����
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
    //��������� �� ������� � dll
    DllCreateNet: Pointer;
    DllSaveNet: Pointer;
    DllLoadNet: Pointer;
    DllDestroyNet: Pointer;
    DllLearnNet: Pointer;
    DllShowNet: Pointer;
    DllProperty: Pointer;
    Dll_Who_Are_You: Pointer;
    DllRunNet: Pointer;
    DllFreeResult: Pointer;
    DllPreCreate: Pointer;
end;

Dict = class
    dt: TDateTime; // ����� �������� �������
    Count, sz: Integer; //����� ����� � ������� � ����� ����� � ������� �� ������ �������� �������
    Rem: PChar; // ����������
    file_name: PChar; // ��� ����� �� ��������
    _fields: ^Pole; // ������ ���������� �� ������� ��������
    Nets: ^TNet; //������ ��������� �� �������� �����
    Nets_Count: Integer;
    is_saved: Integer;
end;

FindProc = function (o: d_array;f: PInt;p: Pointer): Integer;stdcall;
GetPProc = function (o: d_array;ind: Integer): Pointer;stdcall;
GetPoleProc = function (o: Dict;i: Integer): Pole;stdcall;
SetPosProc = procedure (o: TNet;a, b: Integer);stdcall;
GetPosProc = procedure (o: TNet;a, b: Pointer);stdcall;
ReadProc = function (o: TNet;io: Integer): Pointer;stdcall;
FreeResProc = procedure (o: TNet;p: Pointer);stdcall;
Set_svProc = procedure (o: TProject;i: integer);stdcall;
StepProc = function (curr, all, unk: Integer): integer;stdcall;
implementation
end.



