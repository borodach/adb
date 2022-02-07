unit DictonaryParamsForm;

interface

uses sharemem,
Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
StdCtrls;

type
TInitD = class (TForm)
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    procedure Button1Click (Sender: TObject);
    procedure Button2Click (Sender: TObject);
    procedure FormActivate (Sender: TObject);
    procedure FormClose (Sender: TObject; var Action: TCloseAction);
private
    { Private declarations }
public
    d: Pointer;
    { Public declarations }
end;

var
InitD: TInitD;

implementation
Uses Dictonary, Main;
{$R *.DFM}

procedure TInitD.Button1Click (Sender: TObject);
//type PDict=^Dict;
var flag, flag1: Integer;
begin
    flag := 1;
    flag1 := 1;
    
    if (Dict (d).file_name <> nil) and (Dict (d).Rem <> nil)then
    begin
        flag := stricomp (Dict (d).file_name, PChar (Edit1.Text));
        flag1 := strcomp (Dict (d).Rem, PChar (Edit2.Text));
        
        if (flag = 0)and (flag1 = 0) then
        begin
            ModalResult := 2;
            Exit;
        end;
        
    end;
    
    if (flag <> 0 ) then
    begin
        if not (pr.IsDictNameUnique (Edit1.Text)) then
        begin
            MessageBox (handle, 'Имя файла введено некорректно. Оно либо отсутствует, либо совпадает с уже существующим.', 'Предупреждение.', 0);
            Edit1.Text := pr.GetUniqueDictName (Edit1.Text);
            Edit1.SetFocus;
            ModalResult := 0;
            Exit;
        end;
        myStrDispose (Dict (d).file_name);
    end;
    
    if (flag1 <> 0 ) then myStrDispose (Dict (d).Rem);
    
    try
        if (flag <> 0 ) then Dict (d).file_name := myStrNew (PChar (Edit1.Text));
        if (flag1 <> 0 ) then Dict (d).Rem := myStrNew (PChar (Edit2.Text));
        
        except
        on e: Exception do
        MessageBox (Handle, PChar ('При выделении памяти возникло исключение с сообщением: ' + e.Message + #13'Данные программы испорчены поэтому производить сохранение не рекомендуется.'), 'Ошибка', 0);
    end;
    ModalResult := 1;
end;

procedure TInitD.Button2Click (Sender: TObject);
begin
    ModalResult := - 1;
end;

procedure TInitD.FormActivate (Sender: TObject);
var baseName: String;
begin
    
    if (Pr.file_name <> nil)
    then baseName := Copy (Pr.file_name,
    0,
    length (Pr.file_name ) -
    length (
    ExtractFileExt (Pr.file_name )
    )
    )
    else
    baseName := 'Project';
    
    baseName := baseName + '_dct.dct';
    
    
    if Dict (d).file_name <> nil then
    Edit1.Text := Dict (d).file_name
    else Edit1.Text := pr.GetUniqueDictName (baseName );
    
    if Dict (d).Rem <> nil then Edit2.Text := Dict (d).Rem
    else Edit2.Text := 'Словарь №' + IntToStr (pr.getDictCount);
end;

procedure TInitD.FormClose (Sender: TObject; var Action: TCloseAction);
begin
    ModalResult := - 1;
end;

end.


