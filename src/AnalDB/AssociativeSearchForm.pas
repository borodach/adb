unit AssociativeSearchForm;

interface

uses sharemem,
Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
StdCtrls, ComCtrls, Grids, DBGrids, Db, DBTables, checklst, Pack, T_Net,
RXSplit, ExtCtrls, Mask, ToolEdit, RxQuery, ExternDll, StoreResults;

type
TAssoc = class (TForm)
    Panel1: TPanel;
    Panel3: TPanel;
    RxSplitter1: TRxSplitter;
    RxSplitter2: TRxSplitter;
    Panel2: TPanel;
    DataSource1: TDataSource;
    GroupBox1: TGroupBox;
    RxSplitter3: TRxSplitter;
    StringGrid1: TStringGrid;
    GroupBox2: TGroupBox;
    RichEdit1: TRichEdit;
    GroupBox3: TGroupBox;
    DBGrid1: TDBGrid;
    //Query1: TQuery;
    Panel4: TPanel;
    StaticText2: TStaticText;
    DateEdit1: TDateEdit;
    Button5: TButton;
    ComboBox1: TComboBox;
    StaticText1: TStaticText;
    Query1: TQuery;
    Button3: TButton;
    Button2: TButton;
    Button4: TButton;
    Button1: TButton;
    Button6: TButton;
    table: TTable;
    Button7: TButton;
    SaveDialog1: TSaveDialog;
    Button8: TButton;
    procedure Button1Click (Sender: TObject);
    procedure Button4Click (Sender: TObject);
    //    procedure FormActivate(Sender: TObject);
    procedure FormCreate (Sender: TObject);
    procedure FormDestroy (Sender: TObject);
    procedure StringGrid1SelectCell (Sender: TObject; Col, Row: Integer;
    var CanSelect: Boolean);
    procedure Button3Click (Sender: TObject);
    procedure Button2Click (Sender: TObject);
    procedure ComboBox1Change (Sender: TObject);
    procedure StringGrid1SetEditText (Sender: TObject; ACol, ARow: Integer;
    const Value: String);
    procedure Button5Click (Sender: TObject);
    procedure Panel3Resize (Sender: TObject);
    procedure StringGrid1DrawCell (Sender: TObject; Col, Row: Integer;
    Rect: TRect; State: TGridDrawState);
    procedure reset;
    procedure Button6Click (Sender: TObject);
    procedure FormShow (Sender: TObject);
    procedure Button7Click (Sender: TObject);
    procedure Button8Click (Sender: TObject);
    
private
    { Private declarations }
    
public
    { Public declarations }
    p: TNet;
    tp: TPack;
    function FillBuffer: Pointer;
    procedure createTempTable;
    procedure createSQL (condition: String);
end;

var
Assoc: TAssoc;

implementation uses main, dyn_array, Dictonary, DosWin;

{$R *.DFM}

procedure TAssoc.createTempTable;
var i: Integer;
begin
    if Table.Exists then
    begin
        Table.Active := False;
        Table.DeleteTable;
    end;
    
    with Table do begin
        { The Table component must not be active }
        Active := False;
        { First, describe the type of table and give }
        { it a name }
        DatabaseName := '';
        TableType := ttDBase ;
        TableName := 'temporary';
        { Next, describe the fields in the table }
        with FieldDefs do begin
            Clear;
            
            for i := 0 to pr.Query.FieldDefs.Count - 1 do
            begin
                
                AddFieldDef.Assign (pr.Query.FieldDefs [i]);
                
            end;
        end;
        
        { Call the CreateTable method to create the table }
        CreateTable;
        Active := True;
    end;
Table.Append;

end;

procedure TAssoc.Button1Click (Sender: TObject);
begin
    ModalResult := 1;
end;
function TAssoc.FillBuffer: Pointer;
type pint = ^Integer;
preal = ^double;
pcurr = ^currency;
var i, j, siz: Integer;
tmp: ^Field_View;
pp: Pole;
tt, t: ^byte;
i0: Integer;
d0: Double;
c0: Currency;
st: PChar;
pMin, pMax: Pointer;


begin
    result := nil;
    try
        
        createTempTable;
        
        with StringGrid1 do
        
        begin
            tmp := p.In_Fields;
            for i := 0 to p.In_Count - 1 do
            begin
                try
                    Table.Fields [i].AsString := cells [i, 1];
                    tmp.initialized := 1;
                    except
                    tmp.initialized := 0;
                end;
                
                if cells [i, 1] = '' then tmp.initialized := 0;
                
                Inc (tmp);
            end;
            
            
            j := 0;
            // подсчет размера памяти
            
            with pr.Query do
            begin
                siz := getSize (p.id, Table, 1) + sizeof (Integer);
                //tmp:=In_Fields;
                
                if (siz > 512) then tt := Pointer (GlobalAlloc (GMEM_FIXED, siz))
                else tt := Pointer (GlobalAlloc (GMEM_FIXED, 512));
                //GetMem(tt,siz);
                if tt = nil then
                begin
                    result := nil;
                    exit;
                end;
                ////////////////////
                //заполнение буфера
                t := tt;
                pint (t)^ := siz;
                Inc (t, sizeof (Integer));
                //общий размер
                
                writeBuffer (p.id, @t, table, 3);
                
                result := tt;
                ////////////////////
            end;
            
            
            
        end;
    finally
        Table.Active := False;
        Table.DeleteTable;
    end;
    
    
end;
procedure TAssoc.Button4Click (Sender: TObject);
var f: RunProc;
ff: FreeResProc;
i, j, sz: Integer;
bf, buf: Pointer;
st: String;
st0: string [1];
tmp: ^Field_View;
c: Integer;
fr: double;

condition: String;
str: String;
pp: Pole;

begin
    //заполнить буфер
    buf := nil;
    try
        buf := FillBuffer;
        f := TNet (p).DllRunNet;
        ff := TNet (p).DllFreeResult;

        // bf:=buf;
        //Inc(Integer(bf),sizeof(Integer));
        bf := f (p.pNet, buf);
        if bf = nil then raise Exception.Create ('Ошибка при работе сети.');

        tp.Init (p, bf);
        //вывод результата
        //  StringGrid1.Rows[1].Clear;
        tmp := p.In_Fields;

        condition := '';


        for i := 0 to p.In_Count - 1 do
        begin
            c := abs (tmp.Num) - 1;
            tp.Read_To_String (st, st, st0, 0);

            //    MessageBox( 0, PChar(StringGrid1.Cells[i,1]), '', 0 );
            if (tmp.initialized <> 0 ) and
            (st <> StringGrid1.Cells [i, 1]) then tmp.initialized := 2;
            if (tmp.initialized <> 0 ) and
            (tmp.frozen = 0) then
            begin
                if condition <> '' then
                condition := condition + ' and ';
                pp := Dict (p._parent).GetField (c);
                if pp.F_Type = 3 then
                    str := '''' + StringGrid1.Cells [i, 1] + ''''
                else
                    str := StringGrid1.Cells [i, 1];

                condition := condition +
                '(' + pp.name +
                '=' + str + ')';
            end;
            //      if c then tmp.Num:=-tmp.Num;
            //      tmp.porog := fr;

            if pr.dw then
            if length (st) > 0 then OemToChar (PChar (st), PChar (st));
            StringGrid1.Cells [i, 1] := st;
            Inc (tmp);
        end;

        if condition <> '' then createSQL (condition);

        ff (bf);
        //freemem(buf,integer(buf^));
        except
        on e: Exception do
        begin
            //if buf<>nil then freemem(buf,integer(buf^));
            MessageBox (Handle, PChar (e.Message), 'Ошибка.', 0);
        end;
    end;
end;
{
procedure TAssoc.FormActivate(Sender: TObject);
var tf:TField;
i:Integer;
b:Boolean;
begin
//reset;
tp.Init(p,nil,false);
StringGrid1.RowCount:=2;
StringGrid1.ColCount:=p.In_Count;
for i :=0  to p.In_Count-1 do
begin
  StringGrid1.Rows[0].Add(tp.Get_Name(i,tf,b));
  StringGrid1.Row:=1;
  StringGrid1.Col:=0;
  StringGrid1SelectCell(Sender,0,1,b);
end;
RichEdit1.Lines.Clear;
RichEdit1.Lines.AddStrings(pr.Query.Sql);
Query1.DatabaseName:=pr.Query.DatabaseName;
//Query1.Ta:=pr.Query.DatabaseName;
Button2Click(Sender);
end;
    }
procedure TAssoc.FormCreate (Sender: TObject);
begin
    tp := TPack.Create;
end;

procedure TAssoc.FormDestroy (Sender: TObject);
begin
    tp.Free;
end;

procedure TAssoc.StringGrid1SelectCell (Sender: TObject; Col, Row: Integer;
var CanSelect: Boolean);
var i, i0: Integer;
pl: Pole;
tt: ^Field_View;
//d,d0:double;
c, c0: Currency;
is_d: boolean;
begin
    ComboBox1.Text := StringGrid1.Cells [col, row];
    tt := p.In_Fields;
    Inc (tt, Col);
    pl := Dict (p._parent).GetField (abs (tt.Num) - 1);
    ComboBox1.Items.Clear;
    is_d := false;
    case pr.Query.Fields [abs (tt.Num) - 1].DataType of
        ftSmallInt, ftInteger, ftWord:
        for i := 0 to pl.voc.pos do
        begin
            ComboBox1.Items.Add (IntToStr (Integer (pl.voc.GetP (i)^)));
        end;
        ftFloat:
        for i := 0 to pl.voc.pos do
        begin
            ComboBox1.Items.Add (FloatToStr (Double (pl.voc.GetP (i)^)));
        end;
        ftDateTime:
        for i := 0 to pl.voc.pos do
        begin
            ComboBox1.Items.Add (DateTimeToStr (Double (pl.voc.GetP (i)^)));
        end;
        ftTime:
        for i := 0 to pl.voc.pos do
        begin
            ComboBox1.Items.Add (TimeToStr (Double (pl.voc.GetP (i)^)));
        end;
        ftDate:
        begin
            for i := 0 to pl.voc.pos do
            begin
                ComboBox1.Items.Add (DateToStr (Double (pl.voc.GetP (i)^)));
            end;
            is_d := true;
        end;
        ftCurrency:
        for i := 0 to pl.voc.pos do
        begin
            ComboBox1.Items.Add (CurrToStr (Currency (pl.voc.GetP (i)^)));
        end;
        ftString, ftBoolean:
        for i := 0 to pl.voc.pos do
        begin
            if pr.DW then
            ComboBox1.Items.Add (DosToWinStr (PChar (pl.voc.GetP (i)^), 65535))
            else
            ComboBox1.Items.Add (PChar (pl.voc.GetP (i)^));
        end;
    end;
    Button5.enabled := is_d;
end;

procedure TAssoc.Button3Click (Sender: TObject);
begin
    RichEdit1.Lines.Clear;
    RichEdit1.Lines.AddStrings (pr.Query.Sql);
end;

procedure TAssoc.Button2Click (Sender: TObject);
var i: Integer;
begin
    try
        Query1.Close;
        Query1.SQL.Clear;
        Query1.SQL.AddStrings (RichEdit1.Lines);
        Query1.Open;
        if pr.DW then
        for i := 0 to Query1.FieldCount - 1 do
        Query1.Fields [i].OnGetText := pr.OnGetTextEvent
        else
        for i := 0 to Query1.FieldCount - 1 do
        Query1.Fields [i].OnGetText := Nil;
        except
        on e: Exception do MessageBox (Handle, PChar (e.Message), 'Ошибка.', 0);
    end;
end;

procedure TAssoc.ComboBox1Change (Sender: TObject);
begin
    StringGrid1.Cells [StringGrid1.Col, StringGrid1.Row] := ComboBox1.Text;
end;

procedure TAssoc.StringGrid1SetEditText (Sender: TObject; ACol,
ARow: Integer; const Value: String);
begin
    ComboBox1.Text := Value;
end;

procedure TAssoc.Button5Click (Sender: TObject);
begin
    StringGrid1.Cells [StringGrid1.Col, StringGrid1.Row] := DateEdit1.Text;
end;

procedure TAssoc.Panel3Resize (Sender: TObject);
var dx, y0: Integer;
begin
    y0 := (Panel3.Height - Button1.Height) shr 1;
    dx := (Panel3.Width - Button1.Width - Button2.Width - Button3.Width - Button4.Width - Button6.Width - Button7.Width) div 7;
    Button1.top := y0;
    Button2.top := y0;
    Button3.top := y0;
    Button4.top := y0;
    Button6.top := y0;
    Button7.top := y0;
    
    Button1.left := dx;
    Button2.left := 2 * dx + Button1.Width;
    Button3.left := Button2.left + dx + Button2.Width;
    Button4.left := Button3.left + dx + Button3.Width;
    Button6.left := Button4.left + dx + Button4.Width;
    Button7.left := Button6.left + dx + Button6.Width;
    
end;
procedure TAssoc.reset;
var tmp: ^Field_View;
r, c: integer;
begin
    tmp := p.In_Fields;
    for r := 1 to p.In_Count do
    begin
        tmp.Num := abs (tmp.Num);
        Inc (tmp);
        StringGrid1.Cells [r - 1, 1] := '';
    end;
    StringGrid1.Repaint;
end;



procedure TAssoc.StringGrid1DrawCell (Sender: TObject; Col, Row: Integer;
Rect: TRect; State: TGridDrawState);
var tmp: ^Field_View;
r, c: integer;
begin
    tmp := p.In_Fields;
    Inc (tmp, col);
    if (row = 0) or ((tmp.initialized = 0) )
    and (tmp.frozen = 0 ) then
    begin
        inherited;
        exit;
    end;
    StringGrid1.MouseToCell (rect.Left, rect.Top, c, r);
    with Sender as TDrawGrid do
    begin
        Canvas.Brush.Color := clYellow;
        if tmp.frozen <> 0 then Canvas.Brush.Color := clAqua;
        Canvas.Font.Color := clWindowText;
        if tmp.initialized = 2 then Canvas.Font.Color := clRed
        else Canvas.Font.Color := clWindowText;
        
        Canvas.FillRect (Rect);
        Canvas.TextRect (Rect,
        rect.Left + 2,
        rect.top + 2,
        StringGrid1.Cells [c, 1]);
    end;
    
end;

procedure TAssoc.Button6Click (Sender: TObject);
begin
    reset;
    
end;

procedure TAssoc.FormShow (Sender: TObject);
var tf: TField;
i: Integer;
b: Boolean;
begin
    reset;
    tp.Init (p, nil);
    StringGrid1.RowCount := 2;
    StringGrid1.ColCount := p.In_Count;
    for i := 0 to p.In_Count - 1 do
    begin
        StringGrid1.Rows [0].Add (tp.Get_Name (i, tf, b));
        StringGrid1.Row := 1;
        StringGrid1.Col := 0;
        StringGrid1SelectCell (Sender, 0, 1, b);
    end;
    RichEdit1.Lines.Clear;
    RichEdit1.Lines.AddStrings (pr.Query.Sql);
    Query1.DatabaseName := pr.Query.DatabaseName;
    //Query1.Ta:=pr.Query.DatabaseName;
    Button2Click (Sender);
end;

procedure TAssoc.Button7Click (Sender: TObject);

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
    0,
    0,
    Handle
    );
    
    
    {AssignFile(f,SaveDialog1.FileName);
            try
            GetMem(s_l,sizeof(integer)*StringGrid1.ColCount);
            l:=s_l;
            for i := 0 to StringGrid1.ColCount-1 do
            begin
              l^:=0;
              for j:=0 to StringGrid1.RowCount-1 do
        	begin
        	  ll:=Length(StringGrid1.Cells[i,j]);
        	  if ll> l^ then l^:=ll;
        	end;
              //if i<>0 then inc(l^);
              inc(l);
            end;
            Rewrite(f);

            Dict(p._parent).showInfo(f);
            p.showInfo(f,0,0);
            writeln(f);



            for i := 0 to StringGrid1.RowCount do
            begin
              if i<>0 then writeln(f);
              l:=s_l;
              fv:=p.In_Fields;
              for j:=0 to StringGrid1.ColCount-1 do
        	begin
        	  if j<>0 then  write(f,' ');
        	  if (i=0) or ((j<>0) and (Dict(p._parent).GetField(abs(fv.num)-1).F_Type=3)) then
        	  begin
        	    write(f,StringGrid1.Cells[j,i]);
        	    if j<>StringGrid1.ColCount-1 then
        	    for t:=l^-length(StringGrid1.Cells[j,i]) downto 1 do write(f,' ');
        	  end
        	  else write(f,StringGrid1.Cells[j,i]:l^);
        	  Inc(l);
        	  if j<>0 then Inc(fv);
        	end;
            end;
            FreeMem(s_l,sizeof(integer)*StringGrid1.ColCount);
            s_l:=nil;
            CloseFile(f);
            except
            on e:Exception do
              begin
        	 if s_l<>nil then FreeMem(s_l,sizeof(integer)*StringGrid1.ColCount);
        	 try
        	 CloseFile(f);
        	 except
                 end;
                 try
        	 Erase(f);
                 except
                 end;
        	 MessageBox(Handle,PChar(e.Message),PChar('Ошибка записи.'),0);
              end;
            end;}
end;

procedure TAssoc.Button8Click (Sender: TObject);
var tmp: ^Field_View;
r, c: integer;
begin

    tmp := p.In_Fields;
    Inc (tmp, StringGrid1.Col);

    if tmp.frozen <> 0 then tmp.frozen := 0
    else tmp.frozen := 1;

    StringGrid1.Repaint;

end;

procedure TAssoc.createSQL (condition: String);
var temp: string;
ps: integer;
begin

    RichEdit1.Lines.Clear;
    RichEdit1.Lines.AddStrings (pr.Query.Sql);

    temp := uppercase (pr.Query.SQL.Text );
        ps := Pos (' WHERE ', temp);
        if ps = 0 then
        begin
            RichEdit1.Lines.Add ('where ' + condition );
            exit;
        end;

        temp := pr.Query.SQL.Text;

        insert ('(' + condition + ') and ', temp, ps + 7 );

        RichEdit1.Lines.Text := temp;

    end;
    
end.


