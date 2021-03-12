unit formSOListExample;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, SOList,
  FMX.Layouts, FMX.Controls.Presentation, FMX.StdCtrls, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, FireDAC.Stan.StorageBin, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, framePeople, FMX.TabControl,
  frameProduct, Data.Bind.GenData, Fmx.Bind.GenData, Data.Bind.Components,
  Data.Bind.ObjectScope, FMX.Edit, frameColor, frameForm, System.Rtti,
  FMX.Grid.Style, Data.Bind.Controls, Data.Bind.EngExt, Fmx.Bind.DBEngExt,
  Fmx.Bind.Grid, System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.Grid,
  Data.Bind.DBScope, Fmx.Bind.Navigator, FMX.ScrollBox, FMX.Grid, FMX.Objects;

type
  TSOListExample = class(TForm)
    mCliente: TFDMemTable;
    mClienteid: TAutoIncField;
    mClientenome: TStringField;
    mClientesobrenome: TStringField;
    TabControl1: TTabControl;
    tbiProduct: TTabItem;
    tbiDragDrop: TTabItem;
    tbiFormList: TTabItem;
    vsbProduct: TVertScrollBox;
    Layout1: TLayout;
    btnProductLoad: TButton;
    btnProductAdd: TButton;
    btnProductDelete: TButton;
    btnProductClear: TButton;
    gbProductAdd: TGroupBox;
    edtProductAmount: TEdit;
    edtProductDescription: TEdit;
    edtProductName: TEdit;
    GroupBox1: TGroupBox;
    edtProductSearch: TEdit;
    btnProductRemove: TButton;
    btnProductChange: TButton;
    btnProductShowItem: TButton;
    btnProductHide: TButton;
    vsbColor: TVertScrollBox;
    Layout2: TLayout;
    btnColorLoad: TButton;
    btnColorClear: TButton;
    btnColorStartDrag: TButton;
    btnColorStopDrag: TButton;
    vsbForm: TVertScrollBox;
    Layout3: TLayout;
    btnFormLoad: TButton;
    btnFormClear: TButton;
    btnFormShowHidden: TButton;
    tbiDataset: TTabItem;
    Layout4: TLayout;
    btnDatasetLoad: TButton;
    btnDatasetClear: TButton;
    vsbDataset: TVertScrollBox;
    mClientefoto: TBlobField;
    BindingsList1: TBindingsList;
    od: TOpenDialog;
    GroupBox2: TGroupBox;
    Grid1: TGrid;
    BindNavigator1: TBindNavigator;
    Image1: TImage;
    BindSourceDB1: TBindSourceDB;
    LinkGridToDataSourceBindSourceDB12: TLinkGridToDataSource;
    LinkPropertyToFieldBitmap2: TLinkPropertyToField;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnProductLoadClick(Sender: TObject);
    procedure btnProductClearClick(Sender: TObject);
    procedure btnProductAddClick(Sender: TObject);
    procedure btnProductDeleteClick(Sender: TObject);
    procedure btnProductRemoveClick(Sender: TObject);
    procedure btnProductChangeClick(Sender: TObject);
    procedure btnProductShowItemClick(Sender: TObject);
    procedure btnProductHideClick(Sender: TObject);
    procedure btnColorLoadClick(Sender: TObject);
    procedure btnColorClearClick(Sender: TObject);
    procedure btnColorStartDragClick(Sender: TObject);
    procedure btnColorStopDragClick(Sender: TObject);
    procedure btnFormLoadClick(Sender: TObject);
    procedure btnFormShowHiddenClick(Sender: TObject);
    procedure btnFormClearClick(Sender: TObject);
    procedure btnDatasetLoadClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnDatasetClearClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    ProductList: TSOList<TVertScrollBox, TFraProduct>;
    ColorList: TSOList<TVertScrollBox, TFraColor>;
    FormList: TSOList<TVertScrollBox, TFraForm>;
    DataList: TSOList<TVertScrollBox, TFraPeople>;
    procedure btSaveDatasetClick(Sender: TObject);
    procedure btDelDatasetClick(Sender: TObject);
  end;

var
  SOListExample: TSOListExample;

implementation

{$R *.fmx}

procedure TSOListExample.btSaveDatasetClick(Sender: TObject);
var
  Item : TfraPeople;
begin
  Item := TfraPeople(TFmxObject(Sender).parent);
  with mCliente do begin
    if Locate('id', Item.ID, []) then begin
      Edit;
        FieldByName('nome').AsString := Item.edtFirstName.Text;
        FieldByName('sobrenome').AsString := Item.edtLastName.Text;
      Post;
    end;
  end;
end;

procedure TSOListExample.btDelDatasetClick(Sender: TObject);
var
  Item : TfraPeople;
begin
  Item := TfraPeople(TFmxObject(Sender).parent);
  with mCliente do begin
    if Locate('id', Item.ID, []) then begin
      Delete;
    end;
  end;
  DataList. Remove(Item.Name);
end;

procedure TSOListExample.btnColorClearClick(Sender: TObject);
begin
  ColorList.Clear;
end;

procedure TSOListExample.btnColorLoadClick(Sender: TObject);
var
  Item: TfraColor;
  I: Integer;
  AnimeDelay: Single;
begin
  AnimeDelay := 0;

  for I := 1 to 50 do begin
    Item := TFraColor.Create(ColorList);
    Item.Name:='ColorItem'+I.ToString;
    Item.Margins.Top := 10;
    Item.Margins.Left := 10;
    Item.Background.Fill.Color := TAlphaColor(Random(99999999999));

    ColorList.Add(Item, 0.4, AnimeDelay);
    AnimeDelay := AnimeDelay+0.2;
  end;

end;

procedure TSOListExample.btnColorStartDragClick(Sender: TObject);
begin
  ColorList.BeginDragDrop;
  Showmessage('Drag and Drop is associate to TFrame, notice the HitTest=false to background TRectangle');
end;

procedure TSOListExample.btnColorStopDragClick(Sender: TObject);
begin
  ColorList.EndDragDrop;
end;

procedure TSOListExample.btnDatasetClearClick(Sender: TObject);
begin
  DataList.Clear;
end;

procedure TSOListExample.btnDatasetLoadClick(Sender: TObject);
begin
  DataList.Load(mCliente,
    procedure (Data: TDataset; Item: TfraPeople)
    var
      stream: TMemoryStream;
    begin
      Item.ID := Data.FieldByName('id').AsInteger;
      Item.edtFirstName.Text := Data.FieldByName('nome').AsString;
      Item.edtLastName.Text := Data.FieldByName('sobrenome').AsString;

      // picture
      Stream := TMemoryStream.Create;
        TBlobField(Data.FieldByName('foto')).SaveToStream(Stream);
        Item.Image1.Bitmap.LoadFromStream(stream);
      Stream.Free;

      Item.btnSave.OnClick := btSaveDatasetClick;
      Item.btnDel.OnClick := btDelDatasetClick;
    end,
    procedure (Data: TDataset) begin
      Showmessage('Record Count: '+Data.RecordCount.ToString);
    end
  );

end;

procedure TSOListExample.btnFormClearClick(Sender: TObject);
begin
  FormList.Clear;
end;

procedure TSOListExample.btnFormLoadClick(Sender: TObject);
var
  Item: TfraForm;
  I: Integer;
  AnimeDelay: Single;
begin
  AnimeDelay := 0;

  for I := 1 to 20 do begin
    Item := TfraForm.Create(FormList);
    Item.Name:='FormItem'+I.ToString;
    Item.Margins.Top := 10;
    Item.Margins.Left := 10;
    Item.lblTitle.Text := 'Form '+I.ToString;

    FormList.Add(Item, 0.5, AnimeDelay);
    AnimeDelay := AnimeDelay+0.05;
  end;

end;

procedure TSOListExample.btnFormShowHiddenClick(Sender: TObject);
begin
  FormList.ShowHiddenItems;
end;

procedure TSOListExample.btnProductAddClick(Sender: TObject);
var
  item: TFraProduct;
begin
  Item := TfraProduct.Create(ProductList);
  Item.Name := 'ProductItem_'+StringReplace(edtProductName.Text, ' ', '',[rfReplaceAll]);
  Item.Margins.Top := 10;
  Item.Margins.Left := 10;
  Item.lblTitle.Text := edtProductName.Text;
  Item.lblDescription.Text := edtProductDescription.Text;
  Item.lblAmount.Text := edtProductAmount.Text;

  ProductList.Add(Item);

  edtProductSearch.Text := Item.Name;
  vsbProduct.ScrollBy(0, -item.Position.Y);
end;

procedure TSOListExample.btnProductClearClick(Sender: TObject);
begin
  ProductList.Clear;
end;

procedure TSOListExample.btnProductLoadClick(Sender: TObject);
var
  Item: TfraProduct;
  I: Integer;
  AnimeDelay: Single;
begin
  AnimeDelay := 0;

  for I := 1 to 50 do begin
    Item := TFraProduct.Create(ProductList);
    Item.Name:='ProductItem'+I.ToString;
    Item.Margins.Top := 10;
    Item.Margins.Left := 10;

    Item.lblTitle.Text := 'Product Name '+I.ToString;
    Item.lblDescription.Text := 'Description of product '+I.ToString;
    Item.lblAmount.Text := Random(100).ToString;

    ProductList.Add(Item, 0.4, AnimeDelay);
    AnimeDelay := AnimeDelay+0.2;

  end;
end;

procedure TSOListExample.btnProductRemoveClick(Sender: TObject);
begin
  ProductList.Remove(edtProductSearch.Text);
end;

procedure TSOListExample.btnProductShowItemClick(Sender: TObject);
var
  Product: TfraProduct;
begin
  Product := ProductList.Items(edtProductSearch.Text);
  if Product = nil then showmessage('Product not found.');

  ProductList.ShowItem(Product);

end;

procedure TSOListExample.Button1Click(Sender: TObject);
begin
  if Od.execute then begin
    mCliente.Edit;
    mClientefoto.LoadFromFile(od.filename);
    mCliente.Post;
  end;
end;

procedure TSOListExample.btnProductDeleteClick(Sender: TObject);
begin
  ProductList.Delete(1);
end;

procedure TSOListExample.btnProductHideClick(Sender: TObject);
var
  Product: TfraProduct;
begin
  // just hide, don´t free ;)
  Product := ProductList.Items(edtProductSearch.Text);
  if Product = nil then showmessage('Product not found.');

  ProductList.HideItem(Product);

end;

procedure TSOListExample.btnProductChangeClick(Sender: TObject);
var
  Product : TfraProduct;
begin
  Product := ProductList.Items(edtProductSearch.Text);
  if Product = nil then
    showmessage('Product not found.');

  Product.Content.Fill.Color := TAlphaColors.Blanchedalmond;

end;

procedure TSOListExample.FormCreate(Sender: TObject);
begin
  ProductList := TSOList<TVertScrollBox, TfraProduct>.New(vsbProduct);
  ColorList   := TSOList<TVertScrollBox, TFraColor>.New(vsbColor);
  FormList    := TSOList<TVertScrollBox, TFraForm>.New(vsbForm);
  DataList := TSOList<TVertScrollBox, TfraPeople>.New(vsbDataset);

  if FileExists('../../Data/peossoas.dat') then
    mCliente.LoadFromFile('../../Data/peossoas.dat')
  else begin
    ShowMessage('File PESSOAS.DAT not found, please find the file in DATA path.');
    if od.Execute then
      mCliente.LoadFromFile(od.FileName);
  end;
  mCliente.Open;
end;

procedure TSOListExample.FormDestroy(Sender: TObject);
begin
  if Assigned(DataList) then
    DataList.Free;

  if Assigned(ProductList) then
    ProductList.Free;

  if Assigned(ColorList) then
    ColorList.Free;

  if Assigned(FormList) then
    FormList.Free;

end;

end.
