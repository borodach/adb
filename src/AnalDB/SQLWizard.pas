unit SQLWizard;

interface

uses
sharemem, Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
StdCtrls, ComCtrls, Db, DBTables;

type
TSQLWizard = class (TForm)
    GroupBox1: TGroupBox;
    FieldList: TListBox;
    GroupBox2: TGroupBox;
    SortField: TComboBox;
    Asc: TRadioButton;
    Desc: TRadioButton;
    Button1: TButton;
    Button2: TButton;
    GroupBox3: TGroupBox;
    Query: TRichEdit;
    DB: TDatabase;
    procedure Button2Click (Sender: TObject);
    procedure FormActivate (Sender: TObject);
    procedure FieldListClick (Sender: TObject);
    procedure Button1Click (Sender: TObject);
    
private
    
    m_strQuery: TStringList;
    m_oQuery: TQuery;
    
    
    { Private declarations }
    
public
    { Public declarations }
    
    constructor CreateEx (Owner: TComponent;
    srcQuery: TQuery);
    destructor Destroy; override;
    
    function GetQuery: TStringList;
    
    procedure GnerateQuery;
    
    procedure InitData;
    
end;

var
oSQLWizard: TSQLWizard;

implementation

{$R *.DFM}


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TSQLWizard.CreateEx                             //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

constructor TSQLWizard.CreateEx (Owner: TComponent; srcQuery: TQuery);
begin
    Create (Owner);
    m_oQuery := srcQuery;
    m_strQuery := TStringList.Create;
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TSQLWizard.Destroy                              //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

destructor TSQLWizard.Destroy;
begin
    m_strQuery.Free;
    inherited Destroy;
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TSQLWizard.Button2Click                         //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

procedure TSQLWizard.Button2Click (Sender: TObject);
begin
    ModalResult := - 1;
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TSQLWizard.GetQuery                             //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

function TSQLWizard.GetQuery: TStringList;
begin
    Result := m_strQuery;
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TSQLWizard.FormActivate                         //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

procedure TSQLWizard.FormActivate (Sender: TObject);
begin
    
    Query.Lines.clear;
    FieldList.Clear;
    SortField.Clear;
    Asc.Checked := True;
    Desc.Checked := False;
    
    SortField.Items.Add ('Пусто');
    
    InitData;
    
end;





////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TSQLWizard.InitData                             //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////


procedure TSQLWizard.InitData;
var
dataList: TStringList;
i, j: Integer;
nPos: Integer;
tableName: String;
fieldName: String;
begin
    
    dataList := nil;
    try
        dataList := TStringList.Create;
        
        DB := Session.OpenDatabase (m_oQuery.DatabaseNAme);
        
        Session.GetTableNames (DB.DatabaseName,
        '',
        not db.IsSQLBased,
        False,
        dataList);
        
        Session.CloseDatabase (DB);
        
        for i := 0 to dataList.Count - 1 do
        begin
            
            tableName := dataList.Strings [i];
            
            nPos := Pos ('.', tableName);
            if nPos > 0 then
            Delete (tableName,
            nPos,
            Length (tableName));
            
            m_oQuery.Close;
            m_oQuery.SQL.Clear;
            
            m_oQuery.SQL.Add ('select * from ' +
            tableName + ' where 1 = 0');
            
            m_oQuery.Open;
            
            FieldList.Items.Add (tableName + '.*');
            
            for j := 0 to m_oQuery.FieldDefs.Count - 1 do
            begin
                
                fieldName := tableName + '."' + m_oQuery.FieldDefs.Items [j].Name + '"';
                
                
                FieldList.Items.Add (fieldName);
                SortField.Items.Add (fieldName);
                
                
            end;
            
        end;
        
    finally
        m_oQuery.Close;
        dataList.Free;
    end;
    
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TSQLWizard.GnerateQuery                         //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

procedure TSQLWizard.GnerateQuery;
var
nFieldsCount: Integer;
nIdx: Integer;
nPos: Integer;
strBuffer: String;
strPrevTable: String;
strCurrTable: String;
bFirst: Boolean;
begin
    
    m_strQuery.Clear;
    
    bFirst := True;
    
    nFieldsCount := FieldList.SelCount;
    
    if nFieldsCount < 1 then exit;
    
    strBuffer := 'SELECT' + #9;
    
    for nIdx := 0 to FieldList.Items.Count - 1 do
    begin
        
        if not FieldList.Selected [nIdx] then
        Continue;
        
        if bFirst then
        begin
            bFirst := False;
        end
        
        else
        begin
            strBuffer := strBuffer + ',';
            m_strQuery.Add (strBuffer);
            strBuffer := #9;
        end;
        
        strBuffer := strBuffer + FieldList.Items [nIdx];
        
    end;
    
    m_strQuery.Add (strBuffer);
    
    strPrevTable := '';
    strBuffer := 'FROM' + #9;
    
    bFirst := True;
    
    for nIdx := 0 to FieldList.Items.Count - 1 do
    begin
        
        if not FieldList.Selected [nIdx] then
        Continue;
        
        strCurrTable := FieldList.Items [nIdx];
        
        nPos := Pos ('.', strCurrTable);
        if nPos = 0 then Continue;
        
        Delete (strCurrTable,
        nPos,
        Length (strCurrTable));
        
        if strCurrTable = strPrevTable then
        Continue;
        
        strPrevTable := strCurrTable;
        
        
        if bFirst then
        begin
            bFirst := False;
        end
        
        else
        begin
            strBuffer := strBuffer + ',';
            m_strQuery.Add (strBuffer);
            strBuffer := #9;
        end;
        
        
        strBuffer := strBuffer + strCurrTable;
        
    end;
    
    if strBuffer <> #9 then
    m_strQuery.Add (strBuffer);
    
    nPos := SortField.ItemIndex;
    
    if nPos < 1 then
    Exit;
    
    strBuffer := 'ORDER BY ' + SortField.Items [nPos];
    
    if Asc.Checked then
    strBuffer := strBuffer + ' ASC'
    else
    strBuffer := strBuffer + ' DESC';
    
    m_strQuery.Add (strBuffer);
    
    
    
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TSQLWizard.FieldListClick                       //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

procedure TSQLWizard.FieldListClick (Sender: TObject);
begin
    GnerateQuery;
    Query.Lines.Clear;
    Query.Lines.AddStrings (m_strQuery);
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TSQLWizard.Button1Click                         //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

procedure TSQLWizard.Button1Click (Sender: TObject);
begin
    ModalResult := 1;
end;

end.


