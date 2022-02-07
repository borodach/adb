unit ChartForm;

interface
uses sharemem,
Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
ExtCtrls, TeeProcs, TeEngine, Chart, ExtDlgs, Printers, Menus;

type
TForm3 = class (TForm)
    Chat1: TChart;
    MainMenu1: TMainMenu;
    N2: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    SavePictureDialog1: TSavePictureDialog;
    PrintDialog1: TPrintDialog;
    N3: TMenuItem;
    BitMap1: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    procedure N7Click (Sender: TObject);
    procedure FormDestroy (Sender: TObject);
    procedure N5Click (Sender: TObject);
    procedure N3Click (Sender: TObject);
    procedure BitMap1Click (Sender: TObject);
    procedure N8Click (Sender: TObject);
    procedure N2Click (Sender: TObject);
    procedure N4Click (Sender: TObject);
    procedure Chat1MouseUp (Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
    procedure FormClose (Sender: TObject; var Action: TCloseAction);
    procedure FormCreate (Sender: TObject);
private
    { Private declarations }
public
    { Public declarations }
end;

var
Form3: TForm3;
fl: boolean;
implementation uses ChartPropertiesForm;

{$R *.DFM}

procedure TForm3.N7Click (Sender: TObject);
begin
    Diagr.Show;
end;

procedure TForm3.FormDestroy (Sender: TObject);
begin
    //if Diagr<>nil then Diagr.Close;
    Diagr.Free;
    Diagr := nil;
    //close;
    fl := false;
end;

procedure TForm3.N5Click (Sender: TObject);
begin
    Close;
    //Destroy;
end;

procedure TForm3.N3Click (Sender: TObject);
begin
    Chat1.CopyToClipboardMetafile (False);
end;

procedure TForm3.BitMap1Click (Sender: TObject);
begin
    Chat1.CopyToClipboardBitmap;
end;

procedure TForm3.N8Click (Sender: TObject);
begin
    Chat1.CopyToClipboardMetafile (True);
end;

procedure TForm3.N2Click (Sender: TObject);
begin
    if not SavePictureDialog1.Execute then Exit;
    try
        if SavePictureDialog1.FilterIndex = 1 then Chat1.SaveToBitmapFile (SavePictureDialog1.FileName);
        if SavePictureDialog1.FilterIndex = 2 then Chat1.SaveToMetafileEnh (SavePictureDialog1.FileName);
        if SavePictureDialog1.FilterIndex = 3 then Chat1.SaveToMetafile (SavePictureDialog1.FileName);
        except
        on e: Exception do
        begin
            MessageBox (Handle, PChar (e.Message), 'Ошибка сохранения рисунка.', 0);
        end;
    end;
end;

procedure TForm3.N4Click (Sender: TObject);
var rc: TRect;
begin
    rc.left := 0;
    rc.Right := 0;
    rc.Top := Printer.PageWidth - 1;
    rc.Bottom := Printer.PageHeight - 1;
    if not PrintDialog1.Execute then exit;
    //Chat1.PrintRect(rc);
    Chat1.Print;
end;



procedure TForm3.Chat1MouseUp (Sender: TObject; Button: TMouseButton;
Shift: TShiftState; X, Y: Integer);
var tp: TPoint;
begin
    tp.x := x;
    tp.y := y;
    tp := ClientToScreen (tp);
    if (Button = mbRight) then TrackPopupMenu (MainMenu1.Items [1].Handle, TPM_RIGHTALIGN or TPM_LEFTBUTTON or TPM_RIGHTBUTTON, tp.x, tp.y, 0, Handle, nil);
    if (Button = mbLeft)then TrackPopupMenu (MainMenu1.Items [0].Handle, TPM_RIGHTALIGN or TPM_LEFTBUTTON or TPM_RIGHTBUTTON, tp.x, tp.y, 0, Handle, nil);
end;

procedure TForm3.FormClose (Sender: TObject; var Action: TCloseAction);
begin
    Diagr.Close;
    //Form3.Destroy;
    //Form3:=nil;
end;

procedure TForm3.FormCreate (Sender: TObject);
begin
    fl := true;
end;
initialization
fl := false;
end.



