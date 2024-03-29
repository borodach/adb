unit NN;

interface

Uses Classes;

type
TDB = class (TObject)
    NameF: String;
end;
TVoc = class (TObject)
    CF: shortint; { ���������� ������������ ����� }
    NF: array [1..128] of string; { ����� ������������ ����� }
    MF: array [1..128] of boolean; { ������������� �� ����}
    Step: array [1..128] of Real;{ ��� ��� ������� �������� ���� � ������� }
    Min, Max: array [1..128] of real;
    Num: array [1..128] of Boolean;{ ������� ��������� ���� }
    CVF: array [1..128] of smallint; { ���-�� �������� ����}
    VF: array [1..128, 1..10000] of string; { �������� ����� }
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
    Task: shortint; {��� ������ 1-����������,2-�������}
    Interval: integer;
    Step: integer;
    Comment: string;
    NRec: integer; //���-�� ������� � SQL-�������
    NRecNN: integer; //���-�� �������, �� ������� �������� ���
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


