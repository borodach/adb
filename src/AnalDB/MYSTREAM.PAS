unit MyStream;
interface
uses sharemem, classes, windows, sysutils;
type TMyStream = class (TFileStream)
    function Read (var Buffer; Count: Longint): Longint; override;
    function Write (const Buffer; Count: Longint): Longint;override;
end;

implementation
function TMyStream.Read (var Buffer; Count: Longint): Longint;
//var lpMsgBuf:PChar;
//st:string;
begin
    result := 1;
    if inherited Read (Buffer, Count) < count then
    begin
        {FormatMessage(
                    (FORMAT_MESSAGE_ALLOCATE_BUFFER or FORMAT_MESSAGE_FROM_SYSTEM),
                    nil,
                    IOResult,//GetLastError(),
                    (((WORD ( SUBLANG_DEFAULT)) shl 10) or WORD (LANG_NEUTRAL)),
                    Pointer(@lpMsgBuf),
                    0,
                    nil);
                    st:=lpMsgBuf;
                    LocalFree( integer(lpMsgBuf) );}
        raise Exception.Create ('Ошибка чтения');
    end;
end;
function TMyStream.Write (const Buffer; Count: Longint): Longint;
//var lpMsgBuf:PChar;
// st:string;
begin
    result := 1;
    if inherited Write (Buffer, Count) < count then
    begin
        {  FormatMessage(
                    (FORMAT_MESSAGE_ALLOCATE_BUFFER or FORMAT_MESSAGE_FROM_SYSTEM),
                    nil,
                    GetLastError(),
                    (((WORD ( SUBLANG_DEFAULT)) shl 10) or WORD (LANG_NEUTRAL)),
                    Pointer(@lpMsgBuf),
                    0,
                    nil);
                    st:=PChar(lpMsgBuf);
                    LocalFree( integer(lpMsgBuf) );}
        raise Exception.Create ('Ошибка записи.');
    end;
end;
end.


