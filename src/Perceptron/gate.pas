unit gate;
interface
uses 	ShareMem,
		main,
        classes,
        MyNet,
        windows,
        Sysutils,
        progn,
        IOMaster;

function PreCreateNet (hw:HWND;
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
                       Set_sv:Pointer): Pointer; cdecl;

function Who_Are_You (p: Pointer): Integer; cdecl;


implementation
uses recognize;
const title: PChar = 'Многослойный персептрон.';

///////////////////////////////////////////////////////////////////////////////
//
//      function PreCreateNet
//
///////////////////////////////////////////////////////////////////////////////

function PreCreateNet (hw:HWND;
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
                       Set_sv:Pointer): Pointer; cdecl;
var res: TMyNet;
    pl: Pole;
begin
    result := nil;
    case (TNet (pSNet)._type) of
        0: res := TProgn.Do_Init;
        1:  res := TRec.Do_Init;
        else exit;
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
    result := res;
end;

///////////////////////////////////////////////////////////////////////////////
//
//      function Who_Are_You (p: Pointer): Integer; cdecl;
//
///////////////////////////////////////////////////////////////////////////////

function Who_Are_You (p: Pointer): Integer; cdecl;
begin
    PChar (p^) := title;
    result := 3;
end;

end.