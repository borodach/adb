unit OpenDir;

interface

uses
Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
Grids, Outline, DirOutln, StdCtrls, FileCtrl, ExtCtrls;

type
TOpen_dir = class (TForm)
    DirectoryOutline1: TDirectoryOutline;
    Panel1: TPanel;
    DriveComboBox1: TDriveComboBox;
    Panel2: TPanel;
    Button1: TButton;
    Button2: TButton;
    procedure DirectoryOutline1DblClick (Sender: TObject);
    procedure FormDestroy (Sender: TObject);
    procedure DriveComboBox1Change (Sender: TObject);
    procedure Panel2Resize (Sender: TObject);
private
    { Private declarations }
public
    { Public declarations }
end;

var
Open_dir: TOpen_dir;

implementation

{$R *.DFM}

procedure TOpen_dir.DirectoryOutline1DblClick (Sender: TObject);
begin
    ModalResult := 1;
end;

procedure TOpen_dir.FormDestroy (Sender: TObject);
begin
    ModalResult := - 1;
end;

procedure TOpen_dir.DriveComboBox1Change (Sender: TObject);
var old: char;
begin
    old := DirectoryOutline1.Drive;
    try
        DirectoryOutline1.Drive := DriveComboBox1.Drive;
        except
        DirectoryOutline1.Drive := old;
        MessageBox (Handle, 'Диск не доступен.', 'Ошибка', 0);
    end;
end;
procedure TOpen_dir.Panel2Resize (Sender: TObject);
var dx, y0: Integer;
begin
    y0 := (Panel2.Height - Button1.Height) shr 1;
    dx := (Panel2.Width - Button1.Width - Button2.Width) div 3;
    Button1.top := y0;
    Button2.top := y0;
    Button1.left := dx;
    Button2.left := (dx shl 1) + Button1.Width;
end;

end.

