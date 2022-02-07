unit Prop;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
Buttons, ExtCtrls, RXSpin;

type
TOKRightDlg = class (TForm)
    OKBtn: TButton;
    CancelBtn: TButton;
    Bevel1: TBevel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    RxSpinEdit1: TRxSpinEdit;
    RxSpinEdit2: TRxSpinEdit;
    RxSpinEdit3: TRxSpinEdit;
    procedure OKBtnClick (Sender: TObject);
    procedure CancelBtnClick (Sender: TObject);
private
    { Private declarations }
public
    { Public declarations }
end;

var
OKRightDlg: TOKRightDlg;

implementation

{$R *.DFM}

procedure TOKRightDlg.OKBtnClick (Sender: TObject);
begin
    modalresult := 1;
end;

procedure TOKRightDlg.CancelBtnClick (Sender: TObject);
begin
    modalresult := - 1;
end;

end.


