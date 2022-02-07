unit ClusteringForm;

interface

uses sharemem,
Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
StdCtrls, Grids, DBGrids, Db, DBTables, Menus, doswin, T_Net, ExtCtrls,
RXSplit, StoreResults;

type
TCluster = class (TForm)
    DataSource1: TDataSource;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    DataSource2: TDataSource;
    Table1: TTable;
    SaveDialog1: TSaveDialog;
    DBGrid2: TDBGrid;
    DBGrid1: TDBGrid;
    RxSplitter1: TRxSplitter;
    RxSplitter2: TRxSplitter;
    Panel1: TPanel;
    Button1: TButton;
    Button3: TButton;
    Button2: TButton;
    procedure FormActivate (Sender: TObject);
    procedure Button2Click (Sender: TObject);
    procedure FormDestroy (Sender: TObject);
    procedure Button1Click (Sender: TObject);
    function thread_func: Integer;
    procedure Button3Click (Sender: TObject);
    procedure Panel1Resize (Sender: TObject);
private
    { Private declarations }
public
    { Public declarations }
    p: TNet;
    fst, lst: Integer;
end;

var
Cluster: TCluster;

implementation uses MainForm, main, dictonary, RecordSelectionForm, WaitForTraining;

{$R *.DFM}

procedure TCluster.FormActivate (Sender: TObject);
var ff: File;
i, j: Integer;
//t:^Field_View;
begin
    DataSource1.DataSet := pr.Query;
    AssignFile (ff, '~report.tmp');
    Table1.TableName := '~report.tmp';
    Table1.DatabaseName := '';
    Table1.TableType := ttDBase;
    Table1.FieldDefs.Add ('RecNo', ftInteger, 0, false);
    //    t:=p.In_Fields;
    {for i:=0 to p.In_Count-1 do
              begin
               j:=Dict(p._parent).GetField(t.Num-1).num;
               if pr.Query.Fields[j].DataType=ftString then
               Table1.FieldDefs.Add(pr.Query.Fields[j].FieldName,pr.Query.Fields[j].DataType,pr.Query.Fields[j].DataSize,false)
               else Table1.FieldDefs.Add(pr.Query.Fields[j].FieldName,pr.Query.Fields[j].DataType,0,false);
               Inc(t);
              end;  }
    for i := 0 to pr.Query.FieldCount - 1 do
    begin
        with pr.Query.Fields [i] do
        begin
            if DataType = ftString then
            Table1.FieldDefs.Add (FieldName, DataType, DataSize, false)
            else
            Table1.FieldDefs.Add (FieldName, DataType, 0, false);
        end;
    end;
    
    if p.Out_Count = 0 then Table1.FieldDefs.Add ('Cluster_', ftInteger, 0, false)
    else
    begin
        i := Dict (p._parent).GetField (p.Out_Fields.Num - 1).num;
        j := Integer (pr.Query.Fields [i].DataType);
        if j = Integer (ftString) then i := pr.Query.Fields [i].DataSize else i := 0;
        Table1.FieldDefs.Add ('Type_', TFieldType (j), i, false);
    end;
    try
        Table1.CreateTable;
        Table1.Open;
        if pr.DW then
        for i := 0 to Table1.FieldCount - 1 do
        Table1.Fields [i].OnGetText := pr.OnGetTextEvent;
        except
        on e: Exception do
        begin
            MessageBox (Handle, PChar (e.Message), 'Ошибка.', 0);
            ModalResult := - 2;
            Destroy;
            Exit;
        end;
    end;
end;

procedure TCluster.Button2Click (Sender: TObject);
begin
    ModalResult := 1;
end;

procedure TCluster.FormDestroy (Sender: TObject);
var ff: File;
begin
    Table1.Close;
    AssignFile (ff, '~report.tmp');
    erase (ff);
end;

procedure TCluster.Button1Click (Sender: TObject);
var d: Integer;
c, id: Cardinal;

begin
    try
        Inter := TInter.Create (Application);
        fst := 1;
        lst := pr.Query.RecordCount;
        Inter.Init (@fst, @lst);
        if Inter.ShowModal < 0 then
        begin
            Inter.Destroy;
            Exit;
        end;
        Inter.Destroy;
        Form20 := TForm20.Create (Application);
        
        SetProgress (0, 0, 0);
        DataSource1.Enabled := False;
        DataSource2.Enabled := False;
        
        d := BeginThread (nil, 0, Addr (TCluster.thread_func), self, 0, id);
        Form20.ShowModal;
        Form20.Destroy;
        
        //repeat
        //  GetExitCodeThread(d,c);
        //until(c<>Still_Active);
        
        WaitForSingleObject (d, INFINITE);
        GetExitCodeThread (d, c);
        CloseHandle (d);
        
        DataSource1.Enabled := True;
        DataSource2.Enabled := True;
        Table1.FlushBuffers;
        Button3.Enabled := true;
        except
        on e: Exception do
        begin
            Form20.Free;
            Inter.Free;
            MessageBox (Handle, PChar (e.Message), 'Ошибка.', 0);
        end;
    end;
end;
function tcluster.thread_func: Integer;
type
TScan = record
    case byte of
        0: (pp: ^Char);
        1: (pi: ^Integer);
        2: (pr: ^Double);
        3: (pc: ^Currency);
        4: (pv: Pointer)
    end;
    
    var i, ii, wr, cl, v0: integer;
    f: RunProc;
    ff: FreeResProc;
    t: ^Field_View;
    bf: TScan;
    begin
        thread_func := 1;
        try
            wr := 0;
            f := p.DllRunNet;
            ff := p.DllFreeResult;
            for ii := 0 to lst - fst do
            begin
            Table1.Append;
            Table1.Fields [0].AsInteger := ii + fst;
        end;
        Table1.Post;
        
        for ii := fst to lst do
        begin
            pr.Query.MoveBy (ii - pr.Query.RecNo);
            bf.pv := f (p.pNet, @cl);
            
            if cl < 0 then
            begin
                MessageBox (handle, bf.pp, 'Ошибка', 0);
                SetProgress (- 1, - 1, - 1);
                Exit;
            end;
            
            Table1.MoveBy (ii - fst + 1 - Table1.RecNo);
            Table1.Edit;
            for i := 1 to pr.Query.FieldCount do
            begin
                Table1.Fields [i].Assign (pr.Query.Fields [i - 1]);
            end;
            
            t := p.Out_Fields;
            if p.Out_Count = 1 then
            begin
                case pr.Query.Fields [Dict (p._parent).GetField (t.Num - 1).num].DataType of
                    ftSmallInt, ftInteger, ftWord:
                    Table1.Fields [pr.Query.FieldCount + 1].AsInteger := bf.pi^;
                    ftFloat:
                    Table1.Fields [pr.Query.FieldCount + 1].AsFloat := bf.pr^;
                    ftDateTime, ftTime, ftDate: Table1.Fields [pr.Query.FieldCount + 1].AsDateTime := bf.pr^;
                    ftCurrency: Table1.Fields [pr.Query.FieldCount + 1].AsCurrency := bf.pc^;
                    ftString, ftBoolean:
                    //if pr.DW then
                    // Table1.Fields[pr.Query.FieldCount+1].AsString:=WinToDosStr(PChar(bf.pp),65535)
                    //else
                    Table1.Fields [pr.Query.FieldCount + 1].AsString := PChar (bf.pp);
                end;
                ff (bf.pp);
            end
            else
            Table1.Fields [pr.Query.FieldCount + 1].AsInteger := cl;
            Table1.Post;
            if SetProgress (ii - fst + 1, lst - fst + 1, wr) <> 0 then
            begin
                Exit;
            end;
            pr.Query.Next;
        end;
        
        thread_func := 0;
        except
        on e: Exception do
        begin
            SetProgress (- 1, - 1, - 1);
            MessageBox (0, PChar (e.Message), 'Не могу создать отчет.', 0);
        end;
    end;
end;
procedure TCluster.Button3Click (Sender: TObject);
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
        p,
        0,
        0,
        Handle
        );
        
        
        
    end;
    
    
    
    
    
    
    
    
    // if not CopyFile('~report.tmp',PChar(SaveDialog1.FileName),False) then
    //  MessageBox(Handle,PChar('Не могу скопировать ~report.tmp в '+SaveDialog1.FileName+'.'),PChar('Ошибка сохранения.'),0);
end;

procedure TCluster.Panel1Resize (Sender: TObject);
var dx, y0: Integer;
begin
    y0 := (Panel1.Height - Button1.Height) shr 1;
    dx := (Panel1.Width - Button1.Width - Button2.Width - Button3.Width) div 4;
    Button1.top := y0;
    Button2.top := y0;
    Button3.top := y0;
    Button1.left := dx;
    Button3.left := 2 * dx + Button1.Width;
    Button2.left := Button3.left + dx + Button3.Width;
    
end;
end.


