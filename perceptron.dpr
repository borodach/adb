library perceptron;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  ShareMem,
  SysUtils,
  Classes,
  gate in 'src\Perceptron\gate.pas',
  progn in 'src\Perceptron\progn.pas',
  IOMaster in 'src\Perceptron\IOMaster.pas',
  Prop in 'src\Perceptron\Prop.pas' {OKRightDlg},
  recognize in 'src\Perceptron\recognize.pas',
  MyStream in 'src\Shared\MYSTREAM.PAS',
  CommonGate in 'src\Shared\CommonGate.pas',
  Main in 'src\Shared\Main.pas',
  MyNet in 'src\Shared\MYNET.PAS',
  BPEx in 'src\Perceptron\BPEx.pas';

exports
  CreateNet,
  LoadNet,
  SaveNet,
  DestroyNet,
  LearnNet,
  ShowNet,
  NetProperty,
  Who_Are_You,
  RunNet,
  FreeResult,
  PreCreateNet;

{$R *.RES}

begin

end.