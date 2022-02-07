unit CommonGate;

interface
uses 	ShareMem,
		main,
        classes,
        MyNet,
        windows,
        Sysutils,
        progn,
        IOMaster;


    function CreateNet (p: TMyNet): Integer; cdecl;
    function SaveNet (p: TMyNet): Integer; cdecl;
    function LoadNet (p: TMyNet): Integer; cdecl;
    procedure DestroyNet( p: TMyNet); cdecl;
    function LearnNet (p: TMyNet; a, b: Integer): Integer; cdecl;
    procedure ShowNet (p: TMyNet); cdecl;
    function NetProperty (p: TMyNet): Integer; cdecl;
    function RunNet (p: TMyNet; info: Pointer): Pointer; cdecl;
    procedure FreeResult (p: Pointer);cdecl;

implementation

///////////////////////////////////////////////////////////////////////////////
//
//      function CreateNet (p: TMyNet): Integer; cdecl;
//
///////////////////////////////////////////////////////////////////////////////

function CreateNet (p: TMyNet): Integer; cdecl;
begin
    try
        result := p.Init;
    except
        on e: Exception
            do MessageBox (p.hw, PChar (e.Message), 'Error', 0);
    end;
end;

///////////////////////////////////////////////////////////////////////////////
//
//      function SaveNet (p: TMyNet): Integer; cdecl;
//
///////////////////////////////////////////////////////////////////////////////

function SaveNet (p: TMyNet): Integer; cdecl;
begin
    try
        result := p.Save;
    except
        on e: Exception
            do MessageBox (p.hw, PChar (e.Message), 'Error', 0);
    end;
end;

///////////////////////////////////////////////////////////////////////////////
//
//      function LoadNet (p: TMyNet): Integer; cdecl;
//
///////////////////////////////////////////////////////////////////////////////

function LoadNet (p: TMyNet): Integer; cdecl;
begin
    try
        result := p.Load;
    except
        on e: Exception
            do MessageBox (p.hw, PChar (e.Message), 'Error', 0);
    end;
end;

///////////////////////////////////////////////////////////////////////////////
//
//      procedure DestroyNet(p: TMyNet); cdecl;
//
///////////////////////////////////////////////////////////////////////////////

procedure DestroyNet(p: TMyNet); cdecl;
begin
    try
        p.Free;
    except
        on e: Exception
            do MessageBox (p.hw, PChar (e.Message), 'Error', 0 );
    end;
end;

///////////////////////////////////////////////////////////////////////////////
//
//      function LearnNet (p: TMyNet; a, b: Integer): Integer; cdecl;
//
///////////////////////////////////////////////////////////////////////////////

function LearnNet (p: TMyNet; a, b: Integer): Integer; cdecl;
begin
    try
        result := p.Learn (a, b);
    except
        on e: Exception
            do MessageBox (p.hw, PChar(e.Message),'Error', 0 );
    end;
end;

///////////////////////////////////////////////////////////////////////////////
//
//      procedure ShowNet(p: TMyNet); cdecl;
//
///////////////////////////////////////////////////////////////////////////////

procedure ShowNet(p: TMyNet); cdecl;
begin
    try
        p.Show;
    except
        on e: Exception
            do MessageBox (p.hw, PChar(e.Message),'Error', 0 );
    end;
end;

///////////////////////////////////////////////////////////////////////////////
//
//      function NetProperty(p: TMyNet): Integer; cdecl;
//
///////////////////////////////////////////////////////////////////////////////

function NetProperty(p: TMyNet): Integer; cdecl;
begin
    try
        result := p.Prop;
    except
        on e: Exception
            do MessageBox (p.hw, PChar (e.Message), 'Error', 0 );
    end;
end;

///////////////////////////////////////////////////////////////////////////////
//
//      function RunNet (p: TMyNet; info: Pointer): Pointer; cdecl;
//
///////////////////////////////////////////////////////////////////////////////

function RunNet (p: TMyNet; info: Pointer): Pointer; cdecl;
begin
    try
        result := p.run (info);
    except
        on e: Exception
            do MessageBox (p.hw, PChar (e.Message), 'Error', 0 );
    end;
end;

///////////////////////////////////////////////////////////////////////////////
//
//      procedure FreeResult (p: Pointer); cdecl;
//
///////////////////////////////////////////////////////////////////////////////

procedure FreeResult (p: Pointer); cdecl;
begin
  FreeMem(p);
end;

end.