unit DictonaryCreationProgressa;

interface

uses
sharemem, Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
StdCtrls, ComCtrls, Gauges;

type
TProgr = class (TForm)
    Button1: TButton;
    Gauge1: TGauge;
    procedure Button1Click (Sender: TObject);
    
public
    procedure Init;
    function StepTo (i: Integer): Integer;
    procedure Hide_Progress;
public
    br: Integer;
end;

var
Progr: TProgr;

implementation

uses MainForm;
{$R *.DFM}
procedure TProgr.Init;
begin
    br := 0;
    //Progr.Show;
    Gauge1.Progress := 0;
    //инициализировали ProgressBar
    //инициализировали %
end;

function TProgr.StepTo (i: Integer): Integer;
begin
    Result := br;
    Gauge1.Progress := i;
    //ProgressBar1.Show;
    //StaticText1.Show;
end;
procedure TProgr.Hide_Progress;
begin
    ModalResult := 1;
end;
procedure TProgr.Button1Click (Sender: TObject);
begin
    br := 1;
end;
end.


