unit framePeople;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Controls.Presentation, FMX.Objects;

type
  TfraPeople = class(TFrame)
    Rectangle1: TRectangle;
    Image1: TImage;
    edtLastName: TEdit;
    edtFirstName: TEdit;
    lblFirstName: TLabel;
    lblLastName: TLabel;
    btnSave: TButton;
    btnDel: TButton;
  private
    fID: Integer;
    { Private declarations }
  public
    { Public declarations }
    property ID: Integer read fID write fID;
  end;

implementation

{$R *.fmx}


end.
