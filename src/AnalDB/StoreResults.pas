unit StoreResults;

interface
uses sharemem,
Grids,
DBGrids,
Db,
T_Net,
Dictonary,
sysutils,
windows;

procedure storeStrings (FileName: String;
sGrid: TStringGrid;
p: TNet;
len0: Integer;
len: Integer;
Handle: HWND);

procedure storeData (FileName: String;
data: TDataSet;
p: TNet;
len0: Integer;
len: Integer;
Handle: HWND);

implementation


procedure storeStrings (FileName: String;
sGrid: TStringGrid;
p: TNet;
len0: Integer;
len: Integer;
Handle: HWND);
var
f: TextFile;
i,
j,
ll,
t: Integer;
s_l,
l: ^Integer;
fv: ^Field_View;

begin
    
    
    AssignFile (f, FileName);
    try
        GetMem (s_l, sizeof (integer) * sGrid.ColCount );
        l := s_l;
        for i := 0 to sGrid.ColCount - 1 do
        begin
            l^ := 0;
            for j := 0 to sGrid.RowCount - 1 do
            begin
                ll := Length (sGrid.Cells [i, j]);
                if ll > l^ then l^ := ll;
            end;
            //if i<>0 then inc(l^);
            inc (l);
        end;
        Rewrite (f);
        
        Dict (p._parent).showInfo (f);
        p.showInfo (f, len0, len);
        writeln (f);
        
        
        
        for i := 0 to sGrid.RowCount - 1 do
        begin
            if i <> 0 then writeln (f);
            l := s_l;
            fv := p.Out_Fields;
            for j := 0 to sGrid.ColCount - 1 do
            begin
                if j <> 0 then write (f, ' ');
                if (i = 0) or ((j <> 0) and (Dict (p._parent).GetField (abs (fv.num) - 1).F_Type = 3)) then
                begin
                    write (f, sGrid.Cells [j, i]);
                    if j <> sGrid.ColCount - 1 then
                    for t := l^ - length (sGrid.Cells [j, i]) downto 1 do write (f, ' ');
                end
                else write (f, sGrid.Cells [j, i]: l^);
                Inc (l);
                if j <> 0 then Inc (fv);
            end;
        end;
        
        FreeMem (s_l, sizeof (integer) * sGrid.ColCount);
        s_l := nil;
        CloseFile (f);
        except
        on e: Exception do
        begin
            if s_l <> nil then FreeMem (s_l, sizeof (integer) * sGrid.ColCount);
            
            try
                CloseFile (f);
                except
            end;
            
            try
                Erase (f);
                except
            end;
            
            MessageBox (Handle, PChar (e.Message), PChar ('Ошибка записи.'), 0);
        end;
        
    end;
    
    
end;

procedure storeData (FileName: String;
data: TDataSet;
p: TNet;
len0: Integer;
len: Integer;
Handle: HWND);

var
f: TextFile;
i,
j,
ll,
t: Integer;
s_l,
l: ^Integer;
//fv	: 	^Field_View;


begin
    
    try
        data.DisableControls;
        
        AssignFile (f, FileName);
        try
            GetMem (s_l, sizeof (integer) * data.FieldCount );
            l := s_l;
            for i := 0 to data.FieldCount - 1 do
            begin
                data.First;
                l^ := Length (data.Fields [i].DisplayName);
                for j := 0 to data.RecordCount - 1 do
                begin
                    ll := Length (data.Fields [i].AsString);
                    if ll > l^ then l^ := ll;
                    data.Next;
                end;
                //if i<>0 then inc(l^);
                inc (l);
            end;
            Rewrite (f);
            
            Dict (p._parent).showInfo (f);
            p.showInfo (f, len0, len);
            writeln (f);
            
            
            data.First;
            
            l := s_l;
            for j := 0 to data.FieldCount - 1 do
            begin
                if j <> 0 then write (f, ' ');
                write (f, data.Fields [j].DisplayName );
                if j <> data.FieldCount - 1 then
                for t := l^ - length (data.Fields [j].DisplayName) downto 1
                do write (f, ' ');
                Inc (l);
            end;
            writeln (f);
            
            
            for i := 0 to data.RecordCount - 1 do
            begin
                if i <> 0 then writeln (f);
                l := s_l;
                //fv:=p.Out_Fields;
                
                for j := 0 to data.FieldCount - 1 do
                begin
                    if j <> 0 then write (f, ' ');
                    if// (i=0) or ((j<>0) and
                    //(Dict(p._parent).GetField(abs(fv.num)-1).F_Type=3))
                    (data.Fields [j].DataType = ftString ) //)
                    then
                    begin
                        write (f, data.Fields [j].AsString);
                        if j <> data.FieldCount - 1 then
                        for t := l^ - length (data.Fields [j].AsString) downto 1
                        do write (f, ' ');
                    end
                    else write (f, data.Fields [j].AsString: l^);
                    Inc (l);
                    //if j<>0 then Inc(fv);
                end;
                data.Next;
            end;
            
            FreeMem (s_l, sizeof (integer) * data.FieldCount);
            s_l := nil;
            CloseFile (f);
            except
            on e: Exception do
            begin
                if s_l <> nil then FreeMem (s_l, sizeof (integer) * data.fieldCount);
                
                try
                    CloseFile (f);
                    except
                end;
                
                try
                    Erase (f);
                    except
                end;
                
                MessageBox (Handle, PChar (e.Message), PChar ('Ошибка записи.'), 0);
            end;
            
        end;
        
        
    finally
        data.EnableControls;
    end;
    
end;

end.



