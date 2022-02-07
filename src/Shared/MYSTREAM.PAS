unit MyStream;
interface
uses ShareMem,classes,windows,sysutils;
type TMyStream = class (TFileStream)
    function Read (var Buffer; Count: Longint): Longint; override;
    function Write (const Buffer; Count: Longint): Longint; override;
end;

implementation

///////////////////////////////////////////////////////////////////////////////
//
//      function TMyStream.Read (var Buffer; Count: Longint): Longint;
//
///////////////////////////////////////////////////////////////////////////////

function TMyStream.Read (var Buffer; Count: Longint): Longint;
begin
    result := 1;
    if inherited Read (Buffer,Count) < count then
    begin
        raise Exception.Create ('Ошибка чтения');
    end;
end;

///////////////////////////////////////////////////////////////////////////////
//
//      function TMyStream.Write (const Buffer; Count: Longint): Longint;
//
///////////////////////////////////////////////////////////////////////////////

function TMyStream.Write (const Buffer; Count: Longint): Longint;
begin
    result := 1;
    if inherited Write (Buffer,Count) < count then
    begin
        raise Exception.Create ('Ошибка записи.');
    end;
end;

end.
