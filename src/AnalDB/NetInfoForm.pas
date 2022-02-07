unit NetInfoForm;

interface

uses sharemem,
Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
StdCtrls, T_Net;

type
TForm4 = class (TForm)
    ListBox1: TListBox;
    ListBox2: TListBox;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    StaticText7: TStaticText;
    StaticText8: TStaticText;
    StaticText9: TStaticText;
    StaticText10: TStaticText;
    StaticText11: TStaticText;
    StaticText14: TStaticText;
    Edit1: TEdit;
    Edit2: TEdit;
    StaticText17: TStaticText;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    GroupBox1: TGroupBox;
    StaticText12: TStaticText;
    Edit3: TEdit;
    Edit4: TEdit;
    StaticText1: TStaticText;
    StaticText13: TStaticText;
    StaticText5: TStaticText;
    StaticText6: TStaticText;
    TrainingInterval: TStaticText;
    procedure FormActivate (Sender: TObject);
    procedure Button2Click (Sender: TObject);
    procedure Button1Click (Sender: TObject);
    procedure Button3Click (Sender: TObject);
private
    { Private declarations }
public
    { Public declarations }
    net: TNet;
end;

var
Form4: TForm4;

implementation
uses dictonary, main;
{$R *.DFM}

procedure TForm4.FormActivate (Sender: TObject);
var s: PChar;
proc: InfoProc;
i: Integer;
st: String;
t: ^Field_View;
begin
    with (net) do
    begin
        
        TrainingInterval.Caption := IntToStr (m_nFirstRec) + ' - ' + IntToStr (m_nLastRec);
        
        StaticText7.Caption := IntToStr (In_Count);
        StaticText8.Caption := IntToStr (Out_Count);
        StaticText14.Caption := DateTimeToStr (dt);
        Edit1.Text := file_name;
        Edit2.Text := rem;
        case _type of
            0: StaticText9.Caption := 'Прогноз.';
            1: StaticText9.Caption := 'Распознавание.';
            2: StaticText9.Caption := 'Кластеризация.';
            3: StaticText9.Caption := 'Поиск ассоциаций.';
        end;
        Edit3.text := dll_file_name;
        proc := Dll_Who_Are_You;
        proc (@s);
        edit4.text := s;
        t := In_Fields;
        for i := 0 to In_Count - 1 do
        begin
            if t.Num < 0 then st := 'Тренд ' else st := '';
            st := st + Dict (_parent).GetField (Abs (t.Num) - 1).name;
            if t.cnt <> 0 then st := st + '(' + IntToStr (t.cnt) + ')';
            ListBox1.Items.Add (st);
            Inc (t);
        end;
        t := Out_Fields;
        for i := 0 to Out_Count - 1 do
        begin
            if t.Num < 0 then st := 'Тренд ' else st := '';
            st := st + Dict (_parent).GetField (Abs (t.Num) - 1).name;
            if t.cnt <> 0 then st := st + '(' + IntToStr (t.cnt) + ')';
            ListBox2.Items.Add (st);
            Inc (t);
        end;
    end;
end;

procedure TForm4.Button2Click (Sender: TObject);
begin
    modalresult := - 1;
end;

procedure TForm4.Button1Click (Sender: TObject);
var fl: Boolean;
ch: char;
begin
    fl := false;
    
    try
        if stricomp (net.file_name, PChar (Edit1.Text)) <> 0 then
        begin
            ch := net.file_name [0 ];
            net.file_name [0 ] := chr (0);
            if not (pr.IsDictNameUnique (Edit1.Text)) then
            begin
                MessageBox (handle, 'Имя файла введено некорректно. Оно либо отсутствует, либо совпадает с уже существующим.', 'Предупреждение.', 0);
                Edit1.Text := pr.GetUniqueDictName (Edit1.Text);
                Edit1.SetFocus;
                ModalResult := 0;
                net.file_name [0 ] := ch;
                Exit;
            end;
            net.file_name [0 ] := ch;
            myStrDispose (net.file_name);
            net.file_name := myStrNew (PChar (Edit1.Text));
            fl := true;
        end;
        
        if strcomp (net.rem, PChar (Edit2.Text)) <> 0 then
        begin
            myStrDispose (net.rem);
            net.rem := myStrNew (PChar (Edit2.Text));
            fl := true;
        end;
        
        if fl then
        begin
            net.is_saved := 0;
            dict (net._parent).is_saved := 0;
            pr.Set_Saved (0);
        end;
        
        except
        on e: Exception do
        MessageBox (Handle, PChar ('При выделении памяти возникло исключение с сообщением: ' + e.Message + #13'Данные программы испорчены поэтому производить сохранение не рекомендуется.'), 'Ошибка', 0);
    end;
    modalresult := 1;
end;

procedure TForm4.Button3Click (Sender: TObject);
var proc: PropertyProc;
begin
    proc := net.DllProperty;
    if proc (net.pnet) = 1 then
    begin
        net.is_saved := 0;
        dict (net._parent).is_saved := 0;
        pr.Set_Saved (0);
    end;
end;

end.


