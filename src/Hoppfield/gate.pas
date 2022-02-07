unit gate;
interface
uses ShareMem,
main,
classes,
MyNet,
windows,
Sysutils,
progn,
IOMaster,
assoc;


function PreCreateNet (hw: HWND;
pPr,
pSNet,
pFind,
pGetPole,
pGetP,
pSetPos,
pGetPos,
pRead,
pFreeRes,
pStep,
Set_sv: Pointer
): Pointer;cdecl;

function Who_Are_You (p: Pointer): Integer;cdecl;

implementation
const title: PChar = 'Сеть Хопфилда';

function PreCreateNet (hw: HWND;pPr, pSNet, pFind, pGetPole, pGetP,
pSetPos, pGetPos, pRead, pFreeRes, pStep,
Set_sv: Pointer): Pointer;cdecl;
var res: TMyNet;
pl: Pole;
begin
    
    case (TNet (pSNet)._type) of
        0: res := TProgn.Do_Init;
        1: ;
        2: ;
        3: res := TAssoc.Do_Init;
    end;
    
    res.hw := hw;
    res.project := pPr;
    res.net := pSNet;
    res.find := pFind;
    res.pGetP := pGetP;
    res.pGetPole := pGetPole;
    res.pSetPos := pSetPos;
    res.pGetPos := pGetPos;
    res.pRead := pRead;
    res.pFreeRes := pFreeRes;
    res.pStep := pStep;
    res.Set_sv := Set_sv;
    // pl:=res.pGetPole(dict(res.net._parent),0);
    //to_log('precreate');
    result := res;
end;
function Who_Are_You (p: Pointer): Integer;cdecl;
begin
    PChar (p^) := title;
    result := 9;
end;
end.


