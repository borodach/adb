unit Main;
interface
uses ShareMem, windows;
type
Field_View = record
    Num: integer; //Num номер поля, нумеруется с 1, если <0, то тренд
    porog: double; //порог качественного тренда
    dt: Variant;
    minVal: Variant;
    cnt: integer;
    //pmin,pmax:Pointer;
end;
PF = ^Field_View;


TProject = class
    file_name: PChar; //файл с описанием проекта
    cur_dir: PChar;
    Saved: Integer; //1 если не нужно сохранять
    Save_As: Integer;// 1 если выполняется Save as...
    DW: boolean;
    Comment: TObject; //примечание
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
    ф-ция создает заготовку сети и связывает ее с оболочкой
    pSNet - указатель на 'оболочку' сети
    pFind - функция поиска  в словаре
    pGetP - доступ к данным словаря
    pGetPole - доступ к полю словаря
    pSetPos - позиционирование в таблице
    pRead - чтение из таблицы
    pFreeRes - очистка буфера обмена с таблицей
    pStep - отображение шага обучения   procedure Step(curr,all,unk:Integer);stdcall;
    }

TNet = class
    
    _parent: TObject; //указатель на словарь
    In_Fields: PF;
    Out_Fields: PF;// ^Field_View; //номера входных/выходных полей
    //если № поля отрицательный, то берем его тренд
    In_Count: Integer;
    Out_Count: Integer; //количество входов/выходов сети
    _type: integer; //прогноз, кластеризация, поиск ассоциаций;
    dt: TDateTime; //время создания сети
    file_name: PChar;
    Rem: PChar;
    is_saved: integer;
    
    pNet: Pointer; //указатель на сеть, расположенную в DLL
    dll_file_name: PChar; //файл с библиотекой
    lib: LongInt ; //дескриптор библиотеки
    //Указатели на функции в dll
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
    dt: TDateTime; // время создания словаря
    Count, sz: Integer; //число полей в словаре и число строк в таблице на момент создания словаря
    Rem: PChar; // примечание
    file_name: PChar; // имя файла со словарем
    _fields: ^Pole; // массив указателей на словари столбцов
    Nets: ^TNet; //Массив связанных со словарем сетей
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



