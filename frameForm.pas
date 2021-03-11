unit frameForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Edit, FMX.Controls.Presentation, FMX.Objects, FMX.Layouts;

type
  TfraForm = class(TFrame)
    Rectangle1: TRectangle;
    lblTitle: TLabel;
    Label2: TLabel;
    edtTitle: TEdit;
    btnTitle: TButton;
    btnHide: TButton;
    procedure btnTitleClick(Sender: TObject);
    procedure btnHideClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses
  SOList;

{$R *.fmx}

procedure TfraForm.btnHideClick(Sender: TObject);
begin
  TSOList<TVertScrollBox, TfraForm>(Owner).HideItem(self);
end;

procedure TfraForm.btnTitleClick(Sender: TObject);
begin
  lblTitle.Text := edtTitle.Text;
end;

end.
