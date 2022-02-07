program AnalDB;

uses
  sharemem,
  sysutils,
  windows,
  Forms,
  MainForm in 'src\AnalDB\MainForm.pas' {Form1},
  AboutForm in 'src\AnalDB\AboutForm.pas' {Form11},
  Doswin in 'src\AnalDB\Doswin.pas',
  dyn_array in 'src\AnalDB\dyn_array.pas',
  Dictonary in 'src\AnalDB\Dictonary.pas',
  DictonaryCreationProgressa in 'src\AnalDB\DictonaryCreationProgressa.pas' {Progr},
  T_Net in 'src\AnalDB\T_Net.pas',
  NetCreationForm in 'src\AnalDB\NetCreationForm.pas' {CreateForm},
  WaitForTraining in 'src\AnalDB\WaitForTraining.pas' {Form20},
  Main in 'src\AnalDB\Main.pas',
  DictonaryParamsForm in 'src\AnalDB\DictonaryParamsForm.pas' {InitD},
  ProjectInfoForm in 'src\AnalDB\ProjectInfoForm.pas' {InfoForm},
  PredictionForm in 'src\AnalDB\PredictionForm.pas' {Prognoz},
  PredictionReport in 'src\AnalDB\PredictionReport.pas' {Report1},
  ClusteringForm in 'src\AnalDB\ClusteringForm.pas' {Cluster},
  RecordSelectionForm in 'src\AnalDB\RecordSelectionForm.pas' {Inter},
  Pack in 'src\AnalDB\Pack.pas',
  ChartForm in 'src\AnalDB\ChartForm.pas' {Form3},
  ChartPropertiesForm in 'src\AnalDB\ChartPropertiesForm.pas' {Diagr},
  NetInfoForm in 'src\AnalDB\NetInfoForm.pas' {Form4},
  MyStream in 'src\AnalDB\MyStream.pas',
  ExternDll in 'src\AnalDB\ExternDll.pas',
  DictonaryInfoForm in 'src\AnalDB\DictonaryInfoForm.pas' {Dict_Param_Form},
  ProjectCreationForm in 'src\AnalDB\ProjectCreationForm.pas' {Form6},
  SQLWizard in 'src\AnalDB\SQLWizard.pas' {SQLWizard},
  StoreResults in 'src\AnalDB\StoreResults.pas',
  AssociativeSearchForm in 'src\AnalDB\AssociativeSearchForm.pas' {Assoc};

{Form4}
{$R *.RES}

begin
  try
  Application.Initialize;
  Application.Title := 'Программа для анализа баз данных';
  Application.HelpFile := 'src\AnalDB\Analdb.hlp';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
  except
  on e:Exception do
    begin
    MessageBox(0,PChar('Произошла непредвиденная ошибка (скорее всего, в одной из библиотек Delphi. Постарайтесь не задерживать курсор мыши над элементами TreeView, так как ошибка связана с появлением пдсказок. Ошибка пропадает только после перезагрузки Windows). '+e.Message),'Ошибка.',0);
    end;
  end;
end.