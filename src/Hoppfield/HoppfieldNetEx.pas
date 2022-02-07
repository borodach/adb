unit HoppfieldNetEx;

interface
uses ShareMem, NeuralBaseComp, NeuralBaseTypes;

type
TNeuralNetHopfEx = class (TNeuralNetHopf)
    
public
    procedure InitWeights; virtual;
    procedure CalcEx (freez: array of boolean );
end;

implementation

procedure TNeuralNetHopfEx.InitWeights;
var
i, j, k: integer;
begin
    { Инициализирует весовую матрицу }
    for i := 0 to InputNeuronCount - 1 do
    for j := 0 to InputNeuronCount - 1 do
    with Layers [1].Neurons [i] do
    begin
        if i <> j then
        for k := 0 to PatternCount - 1 do
        Weights [j] := Weights [j] + Patterns [k, i] * Patterns [k, j]
    end;
end;


procedure TNeuralNetHopfEx.CalcEx (freez: array of boolean );
var
i: integer;
xCurrentIter: integer;
xArray: TVectorFloat;
begin
    SetLength (xArray, InputNeuronCount);
    { Цикл работает пока не стабилизируются выходы }
    xCurrentIter := 0;
    repeat
    for i := 0 to InputNeuronCount - 1 do
    begin
        { Запоминает предыдущий шаг итерации, для
                                        этого используется нулевой слой }
        Layers [SensorLayer].Neurons [i].Output := Layers [1].Neurons [i].Output;
        xArray [i] := Layers [1].Neurons [i].Output;
    end;
    for i := 0 to InputNeuronCount - 1 do
    if not freez [i] then
    with Layers [1].Neurons [i] do
    { Рассчитывается новое состояние нейронов и аксонов }
    ComputeOut (xArray);
    
    Inc (xCurrentIter);
    until Stabled or (MaxIterCount = xCurrentIter);
    if Assigned (FOnAfterInit) then
    FOnAfterInit (Self);
    SetLength (xArray, 0);
    xArray := nil;
end;



end.




