unit WaitForTraining;

interface

uses sharemem,
Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
StdCtrls, ComCtrls, ExtCtrls, Gauges;

type
TForm20 = class (TForm)
    StaticText1: TStaticText;
    Button1: TButton;
    Splitter1: TSplitter;
    StaticText4: TStaticText;
    StaticText5: TStaticText;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    StaticText3: TStaticText;
    StaticText7: TStaticText;
    StaticText6: TStaticText;
    Gauge1: TGauge;
    Timer1: TTimer;
    procedure Button1Click (Sender: TObject);
    procedure Timer1Timer (Sender: TObject);
    
private
    { Private declarations }
public
    { Public declarations }
end;

var
Form20: TForm20;
f: integer;
e: Boolean;
hThread: Cardinal;
function SetProgress (curr, all, unk: Integer): integer;stdcall;
implementation

{$R *.DFM}
function SetProgress (curr, all, unk: Integer): Integer;stdcall;
var i: Integer;
begin
    Result := f;
    if Form20 = nil then exit;

    if curr = - 2 then exit;

    if curr = - 1 then
    begin
        Form20.ModalResult := 1;
        Exit;
    end;
    
    with Form20 do
    begin
        StaticText3.Caption := IntToStr (curr);
        StaticText6.Caption := IntToStr (all);
        StaticText7.Caption := IntToStr (unk);
        if all <> 0 then
        begin
            i := (100 * curr)div all;
            if curr >= all then
            begin
                Button1.Caption := 'Готово';
                e := false;
            end;
        end
        else
        begin
            f := 0;
            i := 0;
            e := true;
            Button1.Caption := 'Отмена';
        end;
        Gauge1.Progress := i;
        if e and (f <> 0) then Form20.ModalResult := 1;
    end;
end;

procedure TForm20.Button1Click (Sender: TObject);
begin
    if not e then ModalResult := 1 else f := 1;
end;

procedure TForm20.Timer1Timer (Sender: TObject);
var exitCode: Cardinal;
begin
    if hThread = 0 then exit;
    if WaitForSingleObject (hThread, 10) = WAIT_OBJECT_0
    then ModalResult := 1;
end;
initialization
hThread := 0;
end.


