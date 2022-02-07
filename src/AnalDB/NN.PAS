unit NN;

interface

Uses Classes;

type
TDB = class (TObject)
    NameF: String;
end;
TVoc = class (TObject)
    CF: shortint; { количество используемых полей }
    NF: array [1..128] of string; { имена используемых полей }
    MF: array [1..128] of boolean; { замаскировано ли поле}
    Step: array [1..128] of Real;{ шаг при задании значений поля в словаре }
    Min, Max: array [1..128] of real;
    Num: array [1..128] of Boolean;{ признак числового поля }
    CVF: array [1..128] of smallint; { кол-во значений поля}
    VF: array [1..128, 1..10000] of string; { значения полей }
end;
TPR = class (TObject)
    Name: string;
    DBName: string;
    SQLOK: boolean;
    VOCOK: boolean;
    CRNET: boolean;
    STUDY: boolean;
    NameSQL: String;
    NameVoc: String;
    NameNN: string;
    Task: shortint; {Тип задачи 1-ассоциации,2-прогноз}
    Interval: integer;
    Step: integer;
    Comment: string;
    NRec: integer; //кол-во записей в SQL-запросе
    NRecNN: integer; //кол-во записей, на которых обучкена ИНС
end;

var
{  W:TDB; }
Project: TPR;
Voc: TVOC;
FV: file of TVOC;
implementation

//var i:integer;


initialization
{  Net:=TNN.Create;  }
{  W:=TDB.Create;  }
Project := TPR.Create;
Voc := TVoc.Create;
Voc.CF := 0;
Project.Name := 'Project1.prj';
Project.DBName := '';
Project.NameNN := 'Project1.net';
Project.NameSQL := 'Project1.sql';
Project.NameVOC := 'Project1.voc';
Project.SQLOK := False;
Project.VOCOK := False;
Project.CRNET := False;
Project.STUDY := False;
Project.Task := 1;
Project.Interval := 5;
Project.Step := 1;
Project.Comment := '';
Project.NRecNN := 0;
{  for i:=1 to 128 do
     Voc.Intervals[i]:=False; }
finalization
Project.Free;
Project := nil;
Voc.Free;
Voc := nil;
end.


