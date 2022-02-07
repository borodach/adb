unit PredictionReport;

interface

uses sharemem,
Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
Menus, Grids, DBGrids, Db, DBTables, StoreResults;

type
TReport1 = class (TForm)
    DataSource1: TDataSource;
    Table1: TTable;
    DBGrid1: TDBGrid;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    SaveDialog1: TSaveDialog;
    N4: TMenuItem;
    procedure N2Click (Sender: TObject);
    procedure N3Click (Sender: TObject);
    procedure FormActivate (Sender: TObject);
    procedure N4Click (Sender: TObject);
    procedure FormDestroy (Sender: TObject);
    
private
    { Private declarations }
public
    p: Pointer;
    procedure Make_Stat;
    { Public declarations }
end;

var
Report1: TReport1;

implementation uses main, PredictionForm, T_Net, ChartPropertiesForm, ChartForm;

{$R *.DFM}

procedure TReport1.N2Click (Sender: TObject);
begin
    SaveDialog1.InitialDir := pr.cur_dir;
    if not SaveDialog1.Execute then Exit;
    
    if SaveDialog1.FilterIndex = 2 then
    begin
        if not CopyFile ('~report.tmp', PChar (SaveDialog1.FileName), False) then
        MessageBox (Handle, PChar ('Не могу скопировать ~report.tmp в ' + SaveDialog1.FileName + '.'), PChar ('Ошибка сохранения.'), 0);
    end
    else
    begin
        
        storeData (SaveDialog1.FileName,
        Table1,
        TPrognoz (p).p,
        TPrognoz (p).len0,
        TPrognoz (p).len,
        Handle
        );
        
        
        
    end;
end;

procedure TReport1.N3Click (Sender: TObject);
begin
    ModalResult := 1;
end;
procedure TReport1.Make_Stat;
var i, j, k, ind, sz, siz, hits: Integer;
t, m: Double;
begin
    ind := 3;
    sz := TPrognoz (p).lst - TPrognoz (p).fst + 1;
    for i := 0 to TNet (TPrognoz (p).p).Out_Count - 1 do
    begin
        for k := 0 to TPrognoz (p).len - 1 do
        begin
            t := 0;
            Table1.First;
            siz := sz;
            hits := 0;
            for j := 0 to sz - 1 do
            begin
                if not Table1.Fields [ind].IsNull then
                begin
                    t := t + Table1.Fields [ind].AsFloat;
                    if Table1.Fields [ind].AsFloat = 0 then Inc (hits)
                end
                else Dec (siz);
                Table1.Next;
            end;
            Table1.Edit;
            Table1.Fields [ind].AsFloat := t / siz;
            Table1.Post;
            
            Table1.Next;
            Table1.Next;
            Table1.Edit;
            Table1.Fields [ind].AsFloat := hits;
            Table1.Post;
            
            Inc (ind, 2);
        end;
        Inc (ind);
    end;
    
    ind := 3;
    for i := 0 to TNet (TPrognoz (p).p).Out_Count - 1 do
    begin
        for k := 0 to TPrognoz (p).len - 1 do
        begin
            t := 0;
            Table1.MoveBy (sz - Table1.RecNo + 1);
            m := Table1.Fields [ind].AsFloat;
            Table1.First;
            siz := sz;
            for j := 0 to sz - 1 do
            begin
                if not Table1.Fields [ind].IsNull
                then t := t + Sqr (Table1.Fields [ind].AsFloat - m)else dec (siz);
                Table1.Next;
            end;
            Table1.Next;
            Table1.Edit;
            Table1.Fields [ind].AsFloat := Sqrt (t / siz);
            Table1.Post;
            Inc (ind, 2);
        end;
        Inc (ind);
    end;
end;
procedure TReport1.FormActivate (Sender: TObject);
begin
    DataSource1.Enabled := False;
    Make_Stat;
    DataSource1.Enabled := True;
    Table1.FlushBuffers;
end;

procedure TReport1.N4Click (Sender: TObject);
begin
    try
        if Form3 = nil then //exit;
        begin
            Form3 := TForm3.Create (Application);
            Diagr := TDiagr.Create (Application);
        end;
        Form3.Show;
        except
        on e: Exception do
        begin
            //Diagr.Free;
            Form3.Free;
            Form3 := nil;
            MessageBox (Handle, PChar (e.Message), 'Ошибка.', 0);
            Exit;
        end;
    end;
end;

procedure TReport1.FormDestroy (Sender: TObject);
begin
    //Form3.Close;
    if fl then Form3.Free;
    Form3 := nil;
end;

end.


