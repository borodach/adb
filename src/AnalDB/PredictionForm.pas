unit PredictionForm;

interface

uses sharemem,
Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
Grids, DBGrids, Db, StdCtrls, dyn_array, dbTables, T_Net, RXSplit,
ExtCtrls, StoreResults;

type
TPrognoz = class (TForm)
    DataSource1: TDataSource;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    SaveDialog1: TSaveDialog;
    Panel1: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    StringGrid1: TStringGrid;
    DBGrid1: TDBGrid;
    RxSplitter1: TRxSplitter;
    RxSplitter2: TRxSplitter;
    procedure Button3Click (Sender: TObject);
    procedure FormActivate (Sender: TObject);
    procedure Button1Click (Sender: TObject);
    procedure Button2Click (Sender: TObject);
    function thread_func: Integer;
    procedure Button4Click (Sender: TObject);
    procedure Panel1Resize (Sender: TObject);
private
    { Private declarations }
public
    tp: Pointer;
    p: TNet;
    len, fst, lst, len0: Integer;
    { Public declarations }
end;

var
Prognoz: TPrognoz;

implementation
uses main, dictonary, WaitForTraining,
PredictionReport, MainForm, RecordSelectionForm, Pack, doswin;

{$R *.DFM}

procedure TPrognoz.Button3Click (Sender: TObject);
begin
    ModalResult := 1;
end;

procedure TPrognoz.FormActivate (Sender: TObject);
var// t:^Field_View;
i: Integer;
tp: TPack;
tf: TField;
f: RunProc;
oo: Boolean;
begin
    tp := nil;
    f := p.DllRunNet;
    Button2.Enabled := pr.Query.RecordCount > 1;
    Button1.Enabled := pr.Query.RecordCount > 0;
    try
        tp := TPack.Create;
        len := 0;
        f (p.pNet, @len);
        len0 := - 1;
        f (p.pNet, @len0);
        except
        
        tp.Free;
        MessageBox (Handle, 'Мало памяти.', 'Ошибка.', 0);
        Exit;
    end;
    tp.Init (p, nil);
    DataSource1.DataSet := pr.Query;
    //t:=p.Out_Fields;
    StringGrid1.RowCount := 2;
    StringGrid1.ColCount := p.Out_Count + 1;
    StringGrid1.Rows [0].Add ('№');
    for i := 0 to p.Out_Count - 1 do
    begin
        oo := true;
        StringGrid1.Rows [0].Add (tp.Get_Name (i, tf, oo));
    end;
    tp.Destroy;
    StringGrid1.FixedRows := 1;
    StringGrid1.FixedCols := 1;
end;

procedure TPrognoz.Button1Click (Sender: TObject);
var f: RunProc;
ff: FreeResProc;
i, j, l: Integer;
ps: longint;
tp: TPack;
bf: Pointer;
st, st0: String;
fv: ^Field_View;
//sy: array[0..128] of char;
begin
    tp := nil;
    try
        tp := TPack.Create;
        f := p.DllRunNet;
        ff := p.DllFreeResult;
        ps := pr.Query.RecNo;
        DataSource1.Enabled := False;
        l := 1;
        bf := f (p.pNet, @l);
        pr.Query.MoveBy (ps - pr.Query.RecNo);
        if l < 0 then
        begin
            MessageBox (handle, bf, 'Ошибка', 0);
            tp.Destroy;
            //ff(bf);
            DataSource1.Enabled := True;
            Exit;
        end;
        if l > 0 then MessageBox (handle, PChar ('Сеть встретила незнакомые значения полей (' + IntToStr (l) + '). Прогноз может быть неточным.'), 'Предупреждение', 0);
        //
        //
        //s
        tp.Init (p, bf);
        //  t:=p.Out_Fields;
        StringGrid1.RowCount := len + 1;
        
        fv := p.Out_Fields;
        
        for i := 1 to len do
        begin
            StringGrid1.Rows [i].Clear;
            StringGrid1.Rows [i].Add (IntToStr (i));
            for j := 0 to p.Out_Count - 1 do
            begin
                if (i = 1) then
                begin
                    if fv.Num < 0 then
                    st0 := pr.Query.Fields [Dict (p._parent).GetField (abs (fv.Num) - 1).Num].AsString;
                end
                else
                st0 := StringGrid1.Rows [i - 1].Strings [j + 1];
                tp.Read_To_String (st, st, st0, 0);
                if pr.dw then
                if length (st) > 0 then OemToChar (PChar (st), PChar (st));
                if Length (st) <> 0 then StringGrid1.Rows [i].Add (st)
                else StringGrid1.Rows [i].Add (' ');
                Inc (fv);
            end;
        end;
        ff (bf);
        tp.Destroy;
        pr.Query.MoveBy (ps - pr.Query.RecNo);
        DataSource1.Enabled := True;
        except
        on e: Exception do
        begin
            tp.Free;
            DataSource1.Enabled := True;
            DataSource1.Enabled := True;
            MessageBox (Handle, PChar (e.Message), 'Ошибка.', 0);
        end;
    end;
end;


function tprognoz.thread_func: Integer;
var i, j, ii, wr, l, v0, nm, ds: integer;
f: RunProc;
ff: FreeResProc;
t: ^Field_View;
bf: Pointer;
//SecondSession: TSession;
begin
    Application.ProcessMessages;
{    try
        SecondSession := TSession.Create (nil);
        SecondSession.SessionName := 'SecondSession';
        SecondSession.KeepConnections := False;
        SecondSession.Open;
        Pr.Query.Close;
        Pr.Query.SessionName := 'SecondSession';
        Pr.Query.Open;
        Report1.Table1.Close;
        Report1.Table1.SessionName := 'SecondSession';
        Report1.Table1.Open;
}
        thread_func := 1;
        ds := (len shl 1) + 1;
        try
            wr := 0;
            f := p.DllRunNet;
            ff := p.DllFreeResult;
            for ii := 0 to lst - fst do
            begin
                Report1.Table1.Append;
                Report1.Table1.Fields [0].AsInteger := ii + fst;
            end;
        Application.ProcessMessages;
        Report1.Table1.Append;
        Report1.Table1.Fields [0].AsString := 'M';
        Report1.Table1.Append;
        Report1.Table1.Fields [0].AsString := 'Sqrt(D)';
        Report1.Table1.Append;
        Report1.Table1.Fields [0].AsString := 'Hits';
        Report1.Table1.Post;
        for ii := fst to lst do
        begin
            Application.ProcessMessages;
            pr.Query.MoveBy (ii - pr.Query.RecNo - 1);
            l := 1;
            bf := f (p.pNet, @l);
            Application.ProcessMessages;
            if l < 0 then
            begin
                MessageBox (handle, bf, 'Ошибка', 0);
                SetProgress (- 1, - 1, - 1);
                Exit;
            end;
            Inc (wr, l);
            Application.ProcessMessages;
            TPack (tp).Init (p, bf);
            //добавить к таблице
            for i := 0 to len - 1 do
            begin
                Application.ProcessMessages;
                v0 := 1;
                t := p.Out_Fields;
                for j := 0 to p.Out_Count - 1 do
                begin
                    Application.ProcessMessages;
                    pr.Query.MoveBy (ii - pr.Query.RecNo + i);
                    Report1.Table1.MoveBy (ii - fst - Report1.Table1.RecNo + 1 + i);
                    Report1.Table1.Edit;
                    Application.ProcessMessages;
                    nm := Dict (p._parent).GetField (abs (t.Num) - 1).num;
                    if i = 0 then
                    begin
                        Report1.Table1.Fields [v0].Assign (pr.Query.Fields [nm]);
                    end;
                    Application.ProcessMessages;
                    pr.Query.MoveBy (ii - pr.Query.RecNo - 1);
                    //	 pf:=pr.Query.Fields[nm];

                    //pr.Query.MoveBy(ii-pr.Query.RecNo+i);

                    //	       else
                    //	       pf:=Report1.Table1.Fields[v0+(i shl 1)+1-ds];
                    Application.ProcessMessages;
                    TPack (tp).Read_To_Field (
                    Report1.Table1.Fields [v0 + (i shl 1) + 1],
                    Report1.Table1.Fields [v0 + (i shl 1) + 2],
                    pr.Query.Fields [nm], 1);
                    Application.ProcessMessages;
                    Report1.Table1.Post;
                    Inc (t);
                    Inc (v0, ds);
                end;
                if Report1.Table1.RecNo = lst - fst + 1 then break;
            end;
            ff (bf);
            Application.ProcessMessages;
            if SetProgress (ii - fst + 1, lst - fst + 1, wr) <> 0 then
            begin
                Exit;
            end;
        end;
        thread_func := 0;
        except
        on e: Exception do
        begin
            SetProgress (- 1, - 1, - 1);
            MessageBox (0, PChar (e.Message), 'Не могу создать отчет.', 0);
        end;
        end;
{
    finally
        Pr.Query.Close;
        Pr.Query.SessionName := '';
        Pr.Query.Open;

        Report1.Table1.Close;
        Report1.Table1.SessionName := '';
        Report1.Table1.Open;

        SecondSession.Free;
    end;
}
end;

procedure TPrognoz.Button2Click (Sender: TObject);
var d: Cardinal;
i: Integer;
id, c: Cardinal;
tf: TField;
ss, st: String;
it: Boolean;
//ff: File;
begin
  //  AssignFile (ff, '~report.tmp');
    try
        try
            Report1 := nil;
            Form20 := nil;
            Inter:= nil;
            TPack (tp) := TPack.Create;
            TPack (tp).Init (p, nil);
            Inter := TInter.Create (Application);
            fst := 2;
            lst := pr.Query.RecordCount;
            Inter.Init (@fst, @lst);
            if Inter.ShowModal < 0 then
            begin
                Inter.Destroy;
                Inter := nil;
                Exit;
            end;
            Inter.Destroy;
            Inter:=nil;

            Form20 := TForm20.Create (Application);
            Report1 := TReport1.Create (Application);
            Report1.p := self;
            Form20.Caption := 'Прогресс прогнозирования.';
            Report1.Table1.TableName := '~report.tmp';
            Report1.Table1.DatabaseName := '';
            Report1.Table1.TableType := ttDBase;
            //    dct:=Dict(p._parent);
            //    tt:=p.Out_Fields;
            //  Report1.Table1.FieldDefs.Add('N',ftInteger,0,false);
            Report1.Table1.FieldDefs.Add ('N', ftString, 11, false);

            for c := 0 to p.Out_Count - 1 do
            begin
                it := true;
                st := TPack (tp).Get_Name (c, tf, it);
                for i := 0 to len do
                begin
                    if i <> 0 then ss := '_' + IntToStr (i) else ss := '';
                    if (tf.DataType = ftString) then Report1.Table1.FieldDefs.Add (st + ss, ftString, tf.DataSize, false)
                    else
                    begin
                        if it and (i <> 0) then
                        Report1.Table1.FieldDefs.Add (st + ss, ftString, 35, false)
                        else
                        Report1.Table1.FieldDefs.Add (st + ss, tf.DataType, 0, false);
                    end;
                    if i <> 0 then Report1.Table1.FieldDefs.Add ('e_' + st + ss, ftFloat, 0, false);
                end;
            end;
            Report1.Table1.CreateTable;
            Report1.Table1.Open;
            if pr.DW then
            for i := 0 to Report1.Table1.FieldCount - 1 do
            Report1.Table1.Fields [i].OnGetText := pr.OnGetTextEvent;

//            raise EMathError.Create ('Error');

            except
            on e: Exception do
            begin
                MessageBox (Handle, PChar (e.Message), 'Ошибка.', 0);
                Exit;
            end;
        end;

        SetProgress (0, 0, 0);
        DataSource1.Enabled := False;

        //d := BeginThread (nil, 0, Addr (TPrognoz.thread_func), self, 0, id);

        Form20.Show;
        c := thread_func;


        //repeat
        //GetExitCodeThread(d,c);
        //until(c<>Still_Active);
        //WaitForSingleObject (d, INFINITE);
        //GetExitCodeThread (d, c);
        //CloseHandle (d);
        //c:=0;

        Form20.Destroy;
        Form20 := nil;

        DataSource1.Enabled := True;
        for i := 0 to Report1.Table1.Fields.Count - 1 do
        Report1.Table1.Fields [i].DisplayWidth := 20;
        if c = 0 then Report1.ShowModal;

    finally
        TPack (tp).Free;
        if Report1 <> nil then Report1.Table1.Close;
        Report1.Free;
        Form20.Free;
        Inter.Free;
        DeleteFile ('~report.tmp');
    //    CloseFile (ff);
    //    erase (ff);
    end;
end;

procedure TPrognoz.Button4Click (Sender: TObject);
var f: TextFile;
i, j, ll, t: Integer;
s_l, l: ^Integer;
fv: ^Field_View;
begin
    s_l := nil;
    SaveDialog1.InitialDir := pr.cur_dir;
    if not SaveDialog1.Execute then Exit;

    
    storeStrings (SaveDialog1.FileName,
    StringGrid1,
    p,
    len0,
    len,
    Handle
    );
    
    

end;

procedure TPrognoz.Panel1Resize (Sender: TObject);
var dx, y0: Integer;
begin
    y0 := (Panel1.Height - Button1.Height) shr 1;
    dx := (Panel1.Width - Button1.Width - Button2.Width - Button3.Width - Button4.Width) div 5;
    Button1.top := y0;
    Button2.top := y0;
    Button3.top := y0;
    Button4.top := y0;
    Button1.left := dx;
    Button2.left := 2 * dx + Button1.Width;
    Button4.left := Button2.left + dx + Button2.Width;
    Button3.left := Button4.left + dx + Button4.Width;
end;

end.


