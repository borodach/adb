unit ProjectInfoForm;

interface

uses sharemem,
Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
StdCtrls, Buttons, ComCtrls;

type
TInfoForm = class (TForm)
    StaticText1: TStaticText;
    StaticText3: TStaticText;
    StaticText5: TStaticText;
    BitBtn1: TBitBtn;
    StaticText7: TStaticText;
    Edit1: TEdit;
    Edit2: TEdit;
    RichEdit1: TRichEdit;
    Edit3: TEdit;
    RichEdit2: TRichEdit;
    BitBtn2: TBitBtn;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    procedure BitBtn2Click (Sender: TObject);
    procedure FormActivate (Sender: TObject);
    procedure BitBtn1Click (Sender: TObject);
private
    { Private declarations }
public
    { Public declarations }
end;

var
InfoForm: TInfoForm;

implementation
uses main, dictonary;
{$R *.DFM}

procedure TInfoForm.BitBtn2Click (Sender: TObject);
begin
    ModalResult := - 1;
end;

procedure TInfoForm.FormActivate (Sender: TObject);
begin
    Edit1.Text := pr.Query.DatabaseName;
    if pr.Query.Database <> nil then Edit2.Text := pr.Query.Database.Directory
    else Edit2.Text := '';
    RichEdit1.Lines := pr.Query.SQL;
    RichEdit2.Lines := pr.Comment;
    RichEdit2.Modified := False;
    if pr.file_name <> nil then
    Edit3.Text := pr.file_name
    else Edit3.Text := '';
end;

procedure TInfoForm.BitBtn1Click (Sender: TObject);
begin
    pr.Comment.Clear;
    pr.Comment.AddStrings (RichEdit2.Lines);
    if RichEdit2.Modified then ModalResult := 2 else ModalResult := 1;
end;

end.


