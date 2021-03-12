unit SOList;

interface

uses
  FMX.Layouts, Data.DB, FMX.Forms, System.SysUtils, System.Classes, FMX.Types,
  FMX.Dialogs, FMX.Controls, System.Diagnostics, FMX.Ani, FMX.InertialMovement,
  System.Generics.Collections, System.UITypes, System.Types;

type
  TSOList<L: TFmxObject; I: TFrame> = class(TComponent)
  private
    FObject: L;
    FAniCalculations: TAniCalculations;
    FList: TObjectList<I>;
    function getCount: Integer;

  Strict private
    constructor Create(AOwner: TComponent);

  public
    property Count: Integer read getCount;
    procedure Free;
    function Clear: TSOList<L,I>;
    function Items(Index: Cardinal): I; overload;
    function Items(AName: String): I; overload;
    function IndexOf(AName: String): Integer;
    procedure ShowItem(Item: I; ATime: Single=0.4; ADelay: Single=0);
    procedure ShowHiddenItems(ATime: Single=0.4; ADelay: Single=0);
    procedure HideItem(Item: I; ATime: Single=0.4);
    function Load(ASource: TDataset; OnProcess: TProc<TDataset, I> =nil;
      OnFinish: TProc<TDataset> =nil): TSOList<L,I>;

    function Add(Item: I; ATime: Single=0.4; ADelay: Single=0): TSOList<L,I>;
    function Delete(Index: Integer): TSOList<L,I>;
    function Remove(AName: String): TSOList<L,I>;
    function ChangeOrder(ASource, ADest: I): TSOList<L,I>;
    function BeginDragDrop: TSOList<L,I>;
    function EndDragDrop: TSOList<L,I>;
    procedure DragOver(Sender: TObject; const Data: TDragObject;
      const Point: TPointF; var Operation: TDragOperation);
    procedure DragDrop(Sender: TObject; const Data: TDragObject;
      const Point: TPointF);
    class function New(AOwner: TComponent): TSOList<L,I>;
  end;

implementation

{ TSOList<L, I> }

function TSOList<L, I>.Add(Item: I; ATime, ADelay: Single): TSOList<L, I>;
begin
  Result:= Self;
  Item.parent := FObject;
  Item.Position.Y := (Count+1)*(Item.Height+Item.Margins.Top+Item.Margins.Bottom);
  FList.Add(Item);

  ShowItem(Item, ATime, ADelay);
end;

function TSOList<L, I>.BeginDragDrop: TSOList<L,I>;
var
  I: Integer;
begin
  Result := Self;

  for I := 0 to Count-1 do begin
    FList[I].DragMode := TDragMode.dmAutomatic;
    FList[I].OnDragOver := DragOver;
    FList[I].OnDragDrop := DragDrop;
  end;
end;

function TSOList<L, I>.ChangeOrder(ASource, ADest: I): TSOList<L, I>;
var
  IndexSource, IndexDest: Integer;
  Y: Single;
begin
  IndexSource := FList.IndexOf(ASource);
  IndexDest   := FList.IndexOf(ADest);

  Y := ASource.position.Y;
  TAnimator.AnimateFloat(ASource, 'Position.Y', ADest.Position.Y, 0.8, TAnimationType.Out, TInterpolationType.Quintic);
  TAnimator.AnimateFloat(ADest, 'Position.Y', Y, 0.8, TAnimationType.Out, TInterpolationType.Quintic);

  FList.OwnsObjects := False;
  FList[IndexSource]:=ADest;
  FList[IndexDest]:=ASource;
end;

function TSOList<L, I>.Clear: TSOList<L, I>;
begin
  {$IFDEF ANDROID or IOS}
    for var I := Count-1 downto 0 do begin
       FList[I].DisposeOf;
    end;
  {$ENDIF}

  FList.OwnsObjects := True;
  FList.Clear;
end;

constructor TSOList<L,I>.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FObject := L(AOwner);
  FList := TObjectList<I>.Create(False);

  FAniCalculations := TAniCalculations.Create(self);
  with FAniCalculations do begin
    Animation := True;
    BoundsAnimation := True;
    Averaging := True;
    AutoShowing := False;
    DecelerationRate := 1.5;
    Elasticity := 50;
    TouchTracking := [ttVertical];
  end;

  if FObject is TCustomScrollBox then
     TCustomScrollBox(FObject).AniCalculations.Assign(FAniCalculations);
end;

function TSOList<L, I>.Delete(Index: Integer): TSOList<L, I>;
begin
  Result := Self;
  if (Index < 0) or (Index >= Count) then
    raise Exception.Create('Index out of bounds.');

  HideItem(FList[Index]);
  {$IFDEF ANDROID or IOS}
    FList[Index].DisposeOf;
  {$ENDIF}
  FList.OwnsObjects := True;
  FList.Delete(Index);
end;

procedure TSOList<L, I>.DragDrop(Sender: TObject; const Data: TDragObject;
  const Point: TPointF);
var
  LSource, LDest: I;
  IndexSource, IndexDest: Integer;
  Y: Single;
begin
  LSource := I(Data.Source);
  LDest   := I(Sender);

  ChangeOrder(LSource, LDest);
end;

procedure TSOList<L, I>.DragOver(Sender: TObject; const Data: TDragObject;
  const Point: TPointF; var Operation: TDragOperation);
begin
  if ((Sender is I) and (Data.Source is I)) then
    Operation := TDragOperation.Move
  else
    Operation := TDragOperation.None;

end;

function TSOList<L, I>.EndDragDrop: TSOList<L,I>;
var
  I: Integer;
begin
  Result := Self;

  for I := 0 to Count-1 do begin
    FList[I].DragMode := TDragMode.dmManual;
  end;
end;

procedure TSOList<L,I>.Free;
begin
  if Assigned(FObject) then
    FObject := nil;

  if Assigned(FList) then
    FList.Free;

  inherited Free;
end;

function TSOList<L, I>.getCount: Integer;
begin
  result := FList.Count;
end;

procedure TSOList<L, I>.HideItem(Item: I; ATime: Single);
var
  Index, R: Integer;
  Y: Single;
begin
  Index := FList.IndexOf(Item);
  FList.Items[Index].Tag := 0;

  TAnimator.AnimateFloat(Item, 'Opacity', 0.01, ATime, TAnimationType.Out, TInterpolationType.Linear);
  TAnimator.AnimateFloatWait(Item, 'Position.X', TLayout(FObject).Width+30, ATime, TAnimationType.In, TInterpolationType.Back);

  Y:=0;
  for R := 0 to Count-1 do begin
    if FList[R].Tag=1 then begin
      TAnimator.AnimateFloatDelay(FList[R], 'Position.Y', Y, 0.4, ATime*1.2);
      Y := Y+FList[R].Height+FList[R].Margins.Top+Item.Margins.Bottom;
    end;
  end;
end;

function TSOList<L, I>.IndexOf(AName: String): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count-1 do begin
    if UpperCase(FList[I].Name) = UpperCase(AName) then begin
      Result := I;
      break;
    end;
  end;
end;

function TSOList<L, I>.Items(AName: String): I;
var
  Index: Integer;
begin
  Result := nil;

  Index := IndexOf(AName);
  if Index >= 0 then
    Result := Items(Index);
end;

function TSOList<L, I>.Items(Index: Cardinal): I;
begin
  if Index >= Count then
    raise Exception.Create(Format('(%s)[%s] Index out of bounds.', [ClassName, Name]));
  Result := FList[Index];
end;

function TSOList<L,I>.Load(ASource: TDataset; OnProcess: TProc<TDataset, I> =nil;
  OnFinish: TProc<TDataset> =nil): TSOList<L,I>;
begin
  result := self;

  TThread.CreateAnonymousThread(
    procedure
    var
      Lbm : TBookmark;
      Item: I;
      Counter: Integer;
    begin
      TThread.Synchronize(TThread.CurrentThread,
      procedure begin
        TControl(FObject).Visible := False;
        TControl(FObject).BeginUpdate;
        Lbm := ASource.Bookmark;
        Clear;

        ASource.First;
      end);
      Counter:=0;

      while not ASource.Eof do begin
        Item := I.Create(FObject);
        Item.parent := FObject;

        Item.name := format('fra%d',[Counter]);
        Item.Position.Y := Counter*(Item.Height+Item.Margins.Top+Item.Margins.Bottom);
        FList.Add(Item);

        TThread.Synchronize(TThread.CurrentThread,
        procedure begin
          if Assigned(OnProcess) then
            OnProcess(ASource, Item);

          ShowItem(Item, 0.5, 0.3+(Counter*0.1));
        end);

        ASource.Next;
        Inc(Counter);
      end;

      TThread.Synchronize(TThread.CurrentThread,
      procedure begin
        ASource.Bookmark := Lbm;
        TControl(FObject).EndUpdate;
        TControl(FObject).Visible := True;
        ShowItem(Item, 0.5, 0.3+(Counter*0.2));

        if Assigned(OnFinish) then
          OnFinish(ASource);
      end);
   end)
  .Start;
end;

class function TSOList<L,I>.New(AOwner: TComponent): TSOList<L,I>;
begin
  result := Create(AOwner);
  result.Name := Format('SOList_%s', [AOwner.Name]);
end;

function TSOList<L, I>.Remove(AName: String): TSOList<L, I>;
var
  Item: I;
begin
  Result := Self;
  Item := Items(AName);

  if Item = nil then
    raise Exception.Create('Item not found.');

  HideItem(Item);
  {$IFDEF ANDROID or IOS}
    Item.DisposeOf;
  {$ENDIF}
  FList.OwnsObjects := True;
  FList.Delete(indexOf(AName));

end;

procedure TSOList<L, I>.ShowHiddenItems(ATime, ADelay: Single);
var
  I, R: Integer;
  Y: Single;
begin
  for I := Count-1 downto 0 do begin
    if FList[I].Tag = 0 then
      ShowItem(FList[I], ATime, ADelay);
  end;
  Y:=0;

  for R := 0 to Count-1 do begin
    if FList[R].Tag=1 then begin
      TAnimator.AnimateFloatDelay(FList[R], 'Position.Y', Y, 0.4, ATime*1.2);
      Y := Y+FList[R].Height+FList[R].Margins.Top+FList[R].Margins.Bottom;
    end;
  end;

end;

procedure TSOList<L, I>.ShowItem(Item: I; ATime: Single; ADelay: Single);
var
  Index, R: Integer;
  Y, Y2, DelayInc, Bottom: Single;
begin
  Index := FList.IndexOf(Item);

  DelayInc := 0.4;

  Item.Position.Y := Index*(FList[Index].Height+FList[Index].Margins.Top+FList[Index].Margins.Bottom);
  Item.Position.X := TLayout(FObject).Width+30;
  Item.Opacity    := 0.01;
  Item.Tag        := 1;
  TAnimator.AnimateFloatDelay(Item, 'Opacity', 1, ATime+0.1, ADelay+DelayInc, TAnimationType.Out, TInterpolationType.Linear);
  TAnimator.AnimateFloatDelay(Item, 'Position.X', 0, ATime, ADelay+DelayInc, TAnimationType.Out, TInterpolationType.Bounce);

  Y := 0;
  for R := 0 to Count-1 do begin
    if FList[R].Visible and (FList[R].Tag=1) then begin
      TAnimator.AnimateFloatDelay(FList[R], 'Position.Y', Y, 0.4, ADelay);
      Y := Y+(FList[R].Height+FList[R].Margins.Top+FList[R].Margins.Bottom);
    end;
  end;

end;

end.
