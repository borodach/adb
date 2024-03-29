unit BPEx;

interface
uses ShareMem,
Windows,
SysUtils,
NeuralBaseComp,
NeuralBaseTypes,
MyNet;


type
TNeuralNetBPEx = class (TNeuralNetBP)

protected
    procedure Shuffle; override;
    procedure Propagate; override;
    procedure NeuronCountError; override;
    procedure TeachOffLine; override;
    procedure CalcLocalError; override;
    procedure AdjustWeights; override;
//   function LimitDoubleValue (fVal, fMin, fMax: double): double;
public
    pNet: TMyNet;
end;

implementation
{
function TNeuralNetBPEx.LimitDoubleValue (fVal, fMin, fMax: double): double;
begin
    Result := fVal;

    if abs (fVal) < fMin
        then Result := 0
    else
    begin
        if fVal > fMax
            then fVal := fMax
        else
        begin
            if fVal < -fMax
                then fVal := -fMax
        end;
    end;
end;
}
procedure TNeuralNetBPEx.Shuffle;
var
i, ind0, ind1, tmp: integer;
begin

    for i := 0 to FPatternCount - 1 do FRandomOrder [i] := i;

    for i := 0 to PatternCount - 1 do
    begin

        ind0 := Round (Random (FPatternCount));
        ind1 := Round (Random (FPatternCount));
        if (ind0 <> ind1 ) then
        begin
            tmp := FRandomOrder [ind0];
            FRandomOrder [ind0] := FRandomOrder [ind1];
            FRandomOrder [ind1] := tmp;
        end;

    end;

end;

procedure TNeuralNetBPEx.NeuronCountError;
begin
    raise ENeuronCountError.Create (SNeuronCount)
end;

procedure TNeuralNetBPEx.Propagate;
var
i, j, xIndex: integer;
xArray: TVectorFloat;
begin
    { ��������������� ������� � ������
            ����������� � ������� ���� }
    for i := 1 to LayerCount - 1 do
    begin
        { ������������ ������� ������ �� ������� ����������� ���� }
        SetLength (xArray, LayersBP [i - 1].NeuronCount); // �����������
        for xIndex := 0 to LayersBP [i - 1].NeuronCount - 1 do
        begin
            xArray [xIndex] := LayersBP [i - 1].NeuronsBP [xIndex].Output;
            // MessageBox(0, PChar('Inp1 = ' + FloatToStr(xArray[xIndex])) ,'Message', MB_OK);
        end;

        { ���������� ������ ������� }
        for j := 0 to LayersBP [i].NeuronCount - 1 do
        with LayersBP [i].NeuronsBP [j] do
        begin
            ComputeOut (xArray);
        end;
        //    for xIndex := 0 to LayersBP[i-1].NeuronCount - 1 do
        //       xArray[xIndex] := 0;
    end;
    SetLength (xArray, 0);
    xArray := nil;
end;

procedure TNeuralNetBPEx.TeachOffLine;
var
j, nEpoch: integer;
xQuadError: double;
fMidError:  double;
//  de:        double;
xNewEpoch: boolean;
begin
try
    FEpochCurrent := 1;
    if not ContinueTeach then
    begin
        { ���� ����������������, ���� ���� ��������� � "����" }
        InitWeights;
        FEpochCurrent := 1;
    end;
    Randomize;
    SetLength (FRandomOrder, FPatternCount);
    //TeachStopped := False;
    // TeachRate := 10;

    for nEpoch := 1 to EpochCount do
    begin
        {FTeachError := 0;
        FMaxTeachResidual := 0;
        FRecognizedTeachCount := 0;
        xNewEpoch := True;
        }
        //if (nEpoch > 150) {and  (nEpoch mod 10 = 0)} then   MessageBox (0, PChar (IntToStr (nEpoch)), '', 0);
        fMidError := 0;
        Shuffle;
        //MessageBox(0, PChar('PatternCount = ' + IntToStr(PatternCount)) ,'Message', MB_OK);
        for j := 0 to PatternCount - 1 do
        begin
            If pNet.pStep (- 2, 0, 0) = 1 Then
            begin
                exit;
            end;
            LoadPatternsInput (FRandomOrder [j]);
            LoadPatternsOutput (FRandomOrder [j]);
            Propagate;
            //xQuadError := QuadError;
            { �������� - ��������� �� ������ �� ���������� ��������� }

            //MessageBox(0, PChar('Error = ' + FloatToStr(xQuadError)) ,'Message', MB_OK);

            fMidError := fMidError + QuadError;
            {
            if xQuadError < IdentError then
            Inc (FRecognizedTeachCount);
            FTeachError := FTeachError + xQuadError;
            { ������������ ������ �� ��������� ��������� }
            {
            if xNewEpoch then
            begin
                //FMaxTeachResidual := xQuadError;
                xNewEpoch := False;
            end
            else
            if FMaxTeachResidual < xQuadError then
            FMaxTeachResidual := xQuadError;
            }
            CalcLocalError;
            AdjustWeights;
        end;
        { ������� ������ �� ��������� ��������� }

        //   de := FMidTeachResidual;
        //FMidTeachResidual := TeachError / PatternCount;
        fMidError := fMidError / PatternCount;
        if fMidError < IdentError then
            exit;

        // de := de - FMidTeachResidual;
        //  MessageBeep(0);

        // MessageBox(0, PChar('Mid Error = ' + FloatToStr(FMidTeachResidual)) ,'Message', MB_OK);
        //     form5.AddY( FMidTeachResidual );

        { �������� ���� �� ��������� }
        {
        if TestSetPatternCount > 0 then
        CheckTestSet;

        DoOnEpochPassed;
        if StopTeach then
        begin
            // MessageBox(0, 'Here i am ','Message', MB_OK);
            //      MessageBox(0, PChar('Mid Error = ' + FloatToStr(FMidTeachResidual)) ,'Message', MB_OK);
            TeachStopped := True;
            Exit;
        end;
        }
        //Sleep(0);
    end;
    //MessageBox(0, PChar('Mid Error = ' + FloatToStr(FMidTeachResidual)) ,'Message', MB_OK);
    //DoOnAfterTeach;
except
    on e: Exception do
    begin
        MessageBox (0, PChar (e.Message), 'Runtime exception.', 0);
    end;
end;
end;

procedure TNeuralNetBPEx.CalcLocalError;
var
  i, j, k: integer;
  fActivbationD: Double;
begin
  { ������-������� � ���������� ���� �� ������� }
  for i := LayerCount - 1 downto 1 do
    { ��� ���������� ���� }
    if i = LayerCount - 1 then
      for j := 0 to LayersBP[i].NeuronCount - 1 do
      begin
        LayersBP[i].NeuronsBP[j].Delta := (DesiredOut[j] - LayersBP[i].NeuronsBP[j].Output);
        fActivbationD := ActivationD(LayersBP[i].NeuronsBP[j].Output);
        if (LayersBP[i].NeuronsBP[j].Delta <> 0) and (abs (fActivbationD) < 0.001) then
        begin
            fActivbationD := Random;
        end;

        LayersBP[i].NeuronsBP[j].Delta := LayersBP[i].NeuronsBP[j].Delta * fActivbationD;

      end
    else
      for j := 0 to LayersBP[i].NeuronCount - 1 do
        with LayersBP[i].NeuronsBP[j] do
        begin
          Delta := 0;
          { ��������� ������������ ��������� ������ k-������� ���� i+1
            �� ��� ����������� k-������ ���� i+1 � j-�������� ���� i }
          for k := 0 to LayersBP[i+1].NeuronCount - 1 do
            Delta := Delta + LayersBP[i+1].NeuronsBP[k].Delta *
                             LayersBP[i+1].NeuronsBP[k].Weights[j];

          fActivbationD := ActivationD(LayersBP[i].NeuronsBP[j].Output);
          if (Delta <> 0) and (abs (fActivbationD) < 0.001) then
          begin
              fActivbationD := Random;
          end;

          Delta := Delta * fActivbationD;

        end;
end;

procedure TNeuralNetBPEx.AdjustWeights;
var
  i, j, k: integer;
  xCurrentUpdate: double;
begin
  { ���������� ����� ������� � ������� ���� }
  for i := 1 to LayerCount - 1 do
    for j := 0 to LayersBP[i].NeuronCount - 1 do
    begin
      for k := 0 to LayersBP[i-1].NeuronCount - 1  do
      with LayersBP[i].NeuronsBP[j] do
      begin
        { ������������ ��� ����������� j-������ ���� i
          � k-�������� ���� i-1:  ������������� ������ j-�������
          �� ����� k-������� ���� i-1 }
        if k = LayersBP[i-1].NeuronCount then
           { ���� ��� ������ �������� �������� }
           xCurrentUpdate := TeachRate * Delta * LayersBP[i-1].NeuronsBP[k].Output + Momentum * PrevUpdate[k]
        else
           xCurrentUpdate := TeachRate * Delta *
           LayersBP[i-1].NeuronsBP[k].Output + Momentum * PrevUpdate[k];

        Weights[k] := Weights[k] + xCurrentUpdate;

        PrevUpdate[k] := xCurrentUpdate;

      end;
    end
end;

end.


