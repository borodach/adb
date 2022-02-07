unit Doswin;

interface
uses sharemem;
function DosToWinStr (Dos: PChar; MaxChars: Word ): String;
procedure DosToWinArray (Dos: PChar; NumChars: Word );
function WinToDosStr (Win: PChar; MaxChars: Word ): String;

implementation

const
DosToWinTab: array [Chr (128)..Chr (255)] of Char = (
'À', 'Á', 'Â', 'Ã', 'Ä', 'Å', 'Æ', 'Ç', 'È', 'É', 'Ê', 'Ë', 'Ì', 'Í', 'Î', 'Ï',
'Ð', 'Ñ', 'Ò', 'Ó', 'Ô', 'Õ', 'Ö', '×', 'Ø', 'Ù', 'Ú', 'Û', 'Ü', 'Ý', 'Þ', 'ß',
'à', 'á', 'â', 'ã', 'ä', 'å', 'æ', 'ç', 'è', 'é', 'ê', 'ë', 'ì', 'í', 'î', 'ï',
' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',
'ð', 'ñ', 'ò', 'ó', 'ô', 'õ', 'ö', '÷', 'ø', 'ù', 'ú', 'û', 'ü', 'ý', 'þ', 'ÿ',
' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ');

DosUpperA: Byte = 128;
DosLowerR: Byte = 224;

function DosToWinStr (Dos: PChar; MaxChars: Word ): String;
var
I: Word;
begin
    SetLength (Result, MaxChars);
    for I := 0 to MaxChars - 1 do
    if Dos [I] = #0 then
    begin
        SetLength (Result, I);
        Exit;
    end
    else if Dos [I] < #128 then
    Result [I + 1] := Dos [I]
    else
    Result [I + 1] := DosToWinTab [Dos [I]];
end;

function WinToDosStr (Win: PChar; MaxChars: Word ): String;
var
I: Word;
begin
    SetLength (Result, MaxChars);
    for I := 0 to MaxChars - 1 do
    if Win [I] = #0 then
    begin
        SetLength (Result, I);
        Exit;
    end
    else if (Win [I] < #128) or not (Win [I] in ['À'..'ÿ']) then
    Result [I + 1] := Win [I]
    else
    if Win [I] in ['À'..'ï']
    then Result [I + 1] := Chr (DosUpperA + Ord (Win [I]) - Ord ('À'))
    else Result [I + 1] := Chr (DosLowerR + Ord (Win [I]) - Ord ('ð'));
end;

procedure DosToWinArray (Dos: PChar; NumChars: Word );
var
I: Word;
begin
    for I := 0 to NumChars - 1 do
    if Byte (Dos [I]) >= 128 then
    Dos [I] := DosToWinTab [Dos [I]];
end;

end.


