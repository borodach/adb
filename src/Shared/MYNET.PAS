unit MyNet;
interface
uses ShareMem,classes,Main,windows,NeuralBaseComp, NeuralBaseTypes;

type

   TMyNet = class(TObject)
    public
        function Init: Integer; virtual; abstract;
        function Save: Integer; virtual; abstract;
        function Load: Integer; virtual; abstract;
        function Learn (a, b: Integer): Integer; virtual; abstract;
        function Run(p: Pointer): Pointer; virtual; abstract;
        procedure Show; virtual; abstract;
        function Prop: Integer; virtual; abstract;

    public
        base_net: TNeuralNet;
        hw: HWND;
        project: TProject;
        net: TNet;
        find: FindProc;
        pGetP: GetPProc;
        pGetPole: GetPoleProc;
        pSetPos: SetPosProc;
        pGetPos: GetPosProc;
        pRead: ReadProc;
        pFreeRes: FreeResProc;
        pStep: StepProc;
        Set_sv: Set_svProc;

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
end;

implementation
end.
