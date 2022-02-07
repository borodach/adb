unit MainForm;

interface

uses sharemem,
Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
Menus, ComCtrls, StdCtrls, checklst, RxMenus, ExtCtrls, SpeedBar,
AppEvent;

type
TForm1 = class (TForm)
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N14: TMenuItem;
    N19: TMenuItem;
    N20: TMenuItem;
    N16: TMenuItem;
    Tree1: TTreeView;
    CreateDictonary1: TMenuItem;
    N25: TMenuItem;
    N26: TMenuItem;
    N27: TMenuItem;
    N28: TMenuItem;
    N29: TMenuItem;
    RunNet1: TMenuItem;
    NewProject1: TMenuItem;
    ShowInfo1: TMenuItem;
    SaveProject1: TMenuItem;
    LoadProject1: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N2: TMenuItem;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    procedure N20Click (Sender: TObject);
    procedure N19Click (Sender: TObject);
    procedure CreateDictonary1Click (Sender: TObject);
    procedure NewProject1Click (Sender: TObject);
    procedure ShowInfo1Click (Sender: TObject);
    procedure N26Click (Sender: TObject);
    procedure N28Click (Sender: TObject);
    procedure N29Click (Sender: TObject);
    procedure N27Click (Sender: TObject);
    procedure SaveProject1Click (Sender: TObject);
    procedure LoadProject1Click (Sender: TObject);
    procedure N4Click (Sender: TObject);
    procedure N2Click (Sender: TObject);
    procedure N6Click (Sender: TObject);
    procedure RunNet1Click (Sender: TObject);
    procedure Tree1KeyDown (Sender: TObject; var Key: Word;
    Shift: TShiftState);
    procedure Tree1DblClick (Sender: TObject);
    procedure N3Click (Sender: TObject);
    procedure Tree1MouseUp (Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
    procedure N7Click (Sender: TObject);
    procedure FormClose (Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy (Sender: TObject);
    procedure N16Click (Sender: TObject);
    
private
    { Private declarations }
public
    procedure on_menu (var msg: TMessage);message WM_INITMENUPOPUP;
    { Public declarations }
    
end;

var
Form1: TForm1;
implementation

uses
AboutForm,
DB,
DosWin,
StrUtils,
dictonary,
DictonaryInfoForm,
main,
ChartPropertiesForm,
NetInfoForm,
T_Net;

{$R *.DFM}
function Asc_Saving: Boolean;
var res: Integer;
begin
    Result := true;
    if pr.Saved = 0 then
    begin
        res := MessageBox (Form1.handle, 'Проект не сохранен. Сохранить?', 'Предупреждение.', MB_YESNOCANCEL);
        if res = IDNO then Exit;
        if res = IDCANCEL then
        begin
            Result := false;
            Exit;
        end;
        Form1.SaveProject1Click (pr)
    end;
end;

procedure TForm1.on_menu (var msg: TMessage);
var i: Integer;
b: boolean;
begin
    if msg.WParam = MainMenu1.Items [0].Handle then
    begin
        MainMenu1.Items [0].Items [2].Enabled := pr.Saved = 0;
        b := (Tree1.TopItem.Text [8] = 'с')or (Tree1.TopItem.Text [1] = '*');
        MainMenu1.Items [0].Items [3].Enabled := pr.Query.DatabaseName <> '';
        MainMenu1.Items [0].Items [4].Enabled := pr.Query.DatabaseName <> '';
        MainMenu1.Items [0].Items [5].Enabled := pr.Query.DatabaseName <> '';
    end;
    if msg.WParam = MainMenu1.Items [1].Handle then
    begin
        for i := 0 to MainMenu1.Items [1].Count - 1 do
        if Tree1.Selected <> nil then
        MainMenu1.Items [1].Items [i].Enabled := Tree1.Selected.Level = 1
        else MainMenu1.Items [1].Items [i].Enabled := False;
    end;
    if msg.WParam = MainMenu1.Items [2].Handle then
    begin
        for i := 0 to MainMenu1.Items [2].Count - 1 do
        if Tree1.Selected <> nil then
        MainMenu1.Items [2].Items [i].Enabled := Tree1.Selected.Level = 2
        else MainMenu1.Items [2].Items [i].Enabled := False;
    end;
end;

procedure TForm1.N20Click (Sender: TObject);
begin
    try
        Form11 := TForm11.Create (Application);
        Form11.ShowModal;
        Form11.Destroy;
        except
        On e: Exception do
        begin
            Form11.Free;
            MessageBox (Handle, 'Не могу создать окно.', 'Ошибка.', 0);
        end;
    end;
end;

procedure TForm1.N19Click (Sender: TObject);
begin
    Application.HelpCommand (HELP_CONTENTS, 0);
end;



procedure TForm1.CreateDictonary1Click (Sender: TObject);
begin
    Pr.Add_Dict;
end;




procedure TForm1.NewProject1Click (Sender: TObject);
begin
    if Asc_Saving then pr.Create_New;
end;

procedure TForm1.ShowInfo1Click (Sender: TObject);
begin
    pr.Show_Info;
end;

procedure TForm1.N26Click (Sender: TObject);
var t: TTreenode;
begin
    if MessageBox (handle, 'Удалить словарь со всеми нейронными сетями?', 'Предупреждение.', MB_YESNO) = IDNO then Exit;
    t := Tree1.Selected;
    pr.Del_Dict (t);
end;

procedure TForm1.N28Click (Sender: TObject);
var t: TTreenode;
begin
    t := Tree1.Selected;
    Dict (t.Data).Show_Dictonary;
end;

procedure TForm1.N29Click (Sender: TObject);
var t: TTreenode;
begin
    t := Tree1.Selected;
    with Dict (t.Data) do
    begin
        Set_Param;
        t.Text := Rem + ' ( Создан ' + DateTimeToStr (dt) + ' ,файл: ' + file_name + ' ).'
    end;
end;
procedure TForm1.N27Click (Sender: TObject);
var t: TTreenode;
begin
    t := Tree1.Selected;
    Dict (t.Data).AddLibrary;
end;


{procedure TForm1.TestofnewForm1Click(Sender: TObject);
begin
//  FormX.ShowModal;
end;
 }


procedure TForm1.N4Click (Sender: TObject);
begin
    //  Asc_Saving;
    Close;
    //Application.HelpCommand(HELP_QUIT,0);
end;

procedure TForm1.N2Click (Sender: TObject);
var t: TTreeNode;
begin
    if MessageBox (handle, 'Удалить нейронную сеть?', 'Предупреждение.', MB_YESNO) = IDNO then Exit;
    t := Tree1.Selected;
    Dict (t.Parent.Data).KillLibrary (t.Index);
    Tree1.Selected.Delete;
end;

procedure TForm1.N6Click (Sender: TObject);
var t: TTreeNode;
begin
    t := Tree1.Selected;
    try
        Form4 := TForm4.Create (Application);
        Form4.net := Dict (t.Parent.Data).GetLib (t.Index);
        Form4.ShowModal;
        with Form4.net do
        begin
            t.Text := Rem + ' ( Создана ' + DateTimeToStr (dt) + ' ,файл: ' + file_name + ' ).';
        end;
        Form4.Destroy;
        except
        Form4.Free;
        MessageBox (Form1.handle, 'Не могу создать окно.', 'Ошибка.', 0);
    end;
end;
procedure TForm1.RunNet1Click (Sender: TObject);
var t: TTreeNode;
begin
    t := Tree1.Selected;
    Dict (t.Parent.Data).GetLib (t.Index).Run;
    
end;


procedure TForm1.Tree1KeyDown (Sender: TObject; var Key: Word;
Shift: TShiftState);
var Node: TTreeNode;
begin
    Node := Tree1.Selected;
    if (Node = nil) then Exit;
    if Key = 46 then
    begin
        if Node.Level = 1 then N26Click (Sender)
        else if Node.Level = 2 then N2Click (Sender);
    end;
end;

procedure TForm1.Tree1DblClick (Sender: TObject);
var Node: TTreeNode;
begin
    Node := Tree1.Selected;
    if (Node = nil) then Exit;
    if Node.Level = 2 then RunNet1Click (Sender);
end;

procedure TForm1.SaveProject1Click (Sender: TObject);
begin
    if pr.file_name <> nil then pr.Save
    else N3Click (Sender);
end;

procedure TForm1.N3Click (Sender: TObject);
begin
    SaveDialog1.InitialDir := pr.cur_dir;
    if (pr.file_name <> nil) and (pr.file_name [0] <> #0) then SaveDialog1.FileName := pr.file_name;
    if not SaveDialog1.Execute then Exit;
    
    if (ExtractFileName (SaveDialog1.FileName) <> pr.file_name) then
    if not (pr.IsDictNameUnique (ExtractFileName (SaveDialog1.FileName))) then
    begin
        MessageBox (handle, 'Данное имя файла используется одним из объектов проекта.', 'Ошибка', 0);
        Exit;
    end;
    
    myStrDispose (pr.cur_dir);
    myStrDispose (pr.file_name);
    try
        pr.cur_dir := MyStrNew (PChar (ExtractFilePath (SaveDialog1.FileName)));
        pr.file_name := myStrNew (PChar (ExtractFileName (SaveDialog1.FileName)));
        except
        MessageBox (Handle, 'Не могу сохранить проект из - за отсутствия свободной памяти.', 'Ошибка.', 0);
        Exit;
    end;
    pr.Save_As := 1;
    pr.Save;
    pr.Save_As := 0;
    Tree1.TopItem.Text := 'Проект создан. (файл ' + pr.file_name + '.)';
    //SaveProject1Click(Sender);
end;

procedure TForm1.LoadProject1Click (Sender: TObject);
begin
    if not Asc_Saving then Exit;
    myStrDispose (pr.file_name);
    OpenDialog1.InitialDir := pr.cur_dir;
    if not OpenDialog1.Execute then Exit;
    try
        pr.cur_dir := MyStrNew (PChar (ExtractFilePath (OpenDialog1.FileName)));
        pr.file_name := myStrNew (PChar (ExtractFileName (OpenDialog1.FileName)));
        except
        MessageBox (Handle, 'Не могу загрузить проект из - за отсутствия свободной памяти.', 'Ошибка.', 0);
        Exit;
    end;
    pr.Load;
end;
{
procedure TForm1.Test1Click(Sender: TObject);
begin
Diagr.ShowModal;
end;
}
procedure TForm1.Tree1MouseUp (Sender: TObject; Button: TMouseButton;
Shift: TShiftState; X, Y: Integer);
var tn: TTreeNode;
tp: TPoint;
begin
    tp.x := x;
    tp.y := y;
    tn := Tree1.GetNodeAt (X, Y);
    Tree1.Selected := tn;
    if (tn = nil) then Exit;
    tp := Form1.ClientToScreen (tp);
    if ((Button = mbRight)) then TrackPopupMenu (MainMenu1.Items [tn.Level].Handle, TPM_RIGHTALIGN or TPM_LEFTBUTTON or TPM_RIGHTBUTTON, tp.x, tp.y, 0, Form1.Handle, nil);
end;
procedure TForm1.N7Click (Sender: TObject);
var //res:Integer;
t: TTreeNode;
begin
    t := Tree1.Selected;
    //res:=
    Dict (t.Parent.Data).GetLib (t.Index).Learn;
    //if res=0 then Exit;
    {if res<0 then
          begin
            MessageBox(Handle,'При обучении произошла ошибка, вследствие которой сеть была уничтожена.','Ошибка.',0);
            Dict(t.Parent.Data).KillLibrary(t.Index);
            Tree1.Selected.Delete;
          end;}
end;

procedure TForm1.FormClose (Sender: TObject; var Action: TCloseAction);
begin
    if not Asc_Saving then Action := caNone;
end;

procedure TForm1.FormDestroy (Sender: TObject);
begin
    pr.Destroy;
    Application.HelpCommand (HELP_QUIT, 0);
end;

procedure TForm1.N16Click (Sender: TObject);
var sn: ShowProc;
t: TTreeNode;
n: TNet;
begin
    t := Tree1.Selected;
    n := Dict (t.Parent.Data).GetLib (t.Index);
    sn := n.DllShowNet;
    sn (n.pNet);
end;
end.


