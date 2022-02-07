unit mem;
interface
uses windows;

var localHeap: Cardinal;

function heapGetMem (size: Integer): Pointer;
procedure heapFreeMem (p: Pointer);

implementation

function heapGetMem (size: Integer): Pointer;
begin
    result := HeapAlloc (localHeap, 0, size);
end;
procedure heapFreeMem (p: Pointer);
begin
    if p <> nil then HeapFree (localHeap, 0, p);
end;


initialization
localHeap := HeapCreate (0, 4096, 0);

finalization
if localHeap <> 0 then
begin
    HeapDestroy (localHeap);
    CloseHandle (localHeap);
end;
end.


