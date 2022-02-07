unit ProjectCreationForm;

interface

uses
sharemem,
Windows,
Messages,
SysUtils,
Classes,
Graphics,
Controls,
Forms,
Dialogs,
Mask,
ToolEdit,
StdCtrls,
Grids,
DBGrids,
ComCtrls,
ExtCtrls,
main,
Db,
DBTables,
doswin,
SQLWizard;

type
TProjectCreationForm = class (TForm)
    BottomPanel: TPanel;
    DosWinButton: TButton;
    OKButton: TButton;
    CancelButton: TButton;
    Top: TGroupBox;
    ProjectDescription: TRichEdit;
    CenterPanel: TPanel;
    CenterRight: TGroupBox;
    SQLResultGrid: TDBGrid;
    CenterLeftPanel: TPanel;
    GroupBox2: TGroupBox;
    AliasName: TComboBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    DirName: TDirectoryEdit;
    Panel3: TPanel;
    CheckQuery: TButton;
    SQLWizard: TButton;
    DataSource1: TDataSource;
    GroupBox3: TGroupBox;
    SQLQueryText: TRichEdit;
    procedure BottomPanelResize (Sender: TObject);
    procedure DosWinButtonClick (Sender: TObject);
    procedure FormActivate (Sender: TObject);
    procedure CheckQueryClick (Sender: TObject);
    procedure SQLWizardClick (Sender: TObject);
    procedure OKButtonClick (Sender: TObject);
    procedure AliasNameChange (Sender: TObject);
    procedure DirNameChange (Sender: TObject);
    procedure CancelButtonClick (Sender: TObject);
    procedure RadioButton1Click (Sender: TObject);
    procedure RadioButton2Click (Sender: TObject);
private
    { Private declarations }
public
    procedure OnGetTextEvent (Sender: TField;var Text: string; DisplayText: boolean);
    { Public declarations }
end;

var
oProjectCreationForm: TProjectCreationForm;

implementation

uses MainForm;

{$R *.DFM}

////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TProjectCreationForm.OnGetTextEvent             //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

procedure TProjectCreationForm.OnGetTextEvent (Sender: TField;var Text: string; DisplayText: boolean);
begin
    Text := DosToWinStr (Pchar (Sender.AsString), 65535);
end;

////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TProjectCreationForm.BottomPanelResize          //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

procedure TProjectCreationForm.BottomPanelResize (Sender: TObject);
var dx, y0: Integer;

begin
    y0 := (BottomPanel.Height - DosWinButton.Height) shr 1;
    dx := (BottomPanel.Width - DosWinButton.Width -
    OKButton.Width - CancelButton.Width) div 4;
    
    DosWinButton.top := y0;
    OKButton.top := y0;
    CancelButton.top := y0;
    
    DosWinButton.left := dx;
    OKButton.left := dx + DosWinButton.Width +
    DosWinButton.left;
    
    CancelButton.left := OKButton.left + dx +
    OKButton.Width;
    
end;

////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TProjectCreationForm.DosWinButtonClick          //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

procedure TProjectCreationForm.DosWinButtonClick (Sender: TObject);
var
i: integer;
begin
    
    if not pr.DW then
    begin
        pr.DW := True;
        for i := 0 to pr.Query.FieldCount - 1 do
        pr.Query.Fields [i].OnGetText := OnGetTextEvent;
    end
    
    else
    begin
        pr.DW := False;
        for i := 0 to pr.Query.FieldCount - 1 do
        pr.Query.Fields [i].OnGetText := Nil;
    end;
    
    SQLResultGrid.Repaint;
    
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TProjectCreationForm.FormActivate               //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

procedure TProjectCreationForm.FormActivate (Sender: TObject);
begin
    
    pr.Query.Close;
    
    DataSource1.DataSet := pr.Query;
    
    ProjectDescription.Clear;
    ProjectDescription.Lines.Add ('Описание.');
    
    AliasName.Enabled := True;
    AliasName.Clear;
    Session.GetDatabaseNames (AliasName.Items);
    AliasName.ItemIndex := - 1;
    
    DirName.Enabled := False;
    DirName.Text := '';
    
    RadioButton1.Checked := True;
    RadioButton2.Checked := False;
    
    SQLQueryText.Clear;
    
    OKButton.Enabled := False;
    
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TProjectCreationForm.CheckQueryClick            //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

procedure TProjectCreationForm.CheckQueryClick (Sender: TObject);
begin
    
    pr.Query.Close;
    pr.dw := false;
    pr.Query.SQL.Clear;
    pr.Query.SQL.AddStrings (SQLQueryText.Lines);
    
    try
        pr.Query.Open;
        OKButton.Enabled := True;
        
        except
        on e: Exception do
        
        begin
            OKButton.Enabled := False;
            MessageBox (Handle, PChar (e.Message), 'Ошибка.', 0);
        end;
        
    end;
    
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TProjectCreationForm.SQLWizardClick             //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

procedure TProjectCreationForm.SQLWizardClick (Sender: TObject);
begin
    oSQLWizard := nil;
    try
        
        oSQLWizard := TSQLWizard.CreateEx (Application, pr.Query);
        
        if oSQLWizard.ShowModal = - 1 then exit;
        
        SQLQueryText.Lines.Clear;
        SQLQueryText.Lines.AddStrings (oSQLWizard.GetQuery ());
        
        
        except
        
        oSQLWizard.Free;
        MessageBox (Form1.Handle,
        'Ошибка выделения памяти.', 'Ошибка.',
        0);
    end;
    
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TProjectCreationForm.OKButtonClick              //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

procedure TProjectCreationForm.OKButtonClick (Sender: TObject);
begin
    
    pr.Comment.Clear;
    pr.Comment.AddStrings (ProjectDescription.Lines);
    
    ModalResult := 1;
    
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TProjectCreationForm.AliasNameChange            //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

procedure TProjectCreationForm.AliasNameChange (Sender: TObject);
begin
    pr.Query.Close;
    pr.Query.DatabaseName := AliasName.Items [AliasName.ItemIndex];
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TProjectCreationForm.DirNameChange              //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

procedure TProjectCreationForm.DirNameChange (Sender: TObject);
begin
    pr.Query.Close;
    pr.Query.DatabaseName := DirName.Text;
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TProjectCreationForm.CancelButtonClick          //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

procedure TProjectCreationForm.CancelButtonClick (Sender: TObject);
begin
    ModalResult := - 1;
end;


////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TProjectCreationForm.RadioButton1Click          //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

procedure TProjectCreationForm.RadioButton1Click (Sender: TObject);
begin
    DirName.Enabled := False;
    AliasName.Enabled := True;
    pr.Query.Close;
    pr.Query.DatabaseName := AliasName.Items [AliasName.ItemIndex];
end;

////////////////////////////////////////////////////////////////
//                                                            //
//  Procedure TProjectCreationForm.RadioButton2Click          //
//                                                            //
//  Description                                               //
//                                                            //
//                                                            //
////////////////////////////////////////////////////////////////

procedure TProjectCreationForm.RadioButton2Click (Sender: TObject);
begin
    DirName.Enabled := True;
    AliasName.Enabled := False;
    pr.Query.Close;
    pr.Query.DatabaseName := DirName.Text;
end;

end.


