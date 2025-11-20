unit TestPositions;

interface

uses
  WEBLib.UnitTesting.Classes,
  System.SysUtils, System.Classes, JS, Web,
  Vcl.Controls, Vcl.StdCtrls,
  Data.DB,
  WEBLib.Graphics, WEBLib.Controls, WEBLib.Forms, WEBLib.Dialogs, WEBLib.ExtCtrls,
  WEBLib.DBCtrls, WEBLib.StdCtrls, WEBLib.ComCtrls, WEBLib.REST,
  WEBLib.DB, WEBLib.CDS, WebLib.JSON,
  WEBLib.WebCtrls, WEBLib.Menus, WEBLib.Grids, DB,
  senCille.Miscellaneous,
  senCille.MVCRequests;

type
{$M+}
  [TestFixture]
  TTestPositions = class(TObject)
  private
    const LOCAL_PATH         = '/positions';
    const TEST_POSITION_CODE = 'CB';
    const TEST_POSITION_NAME = 'Center Back';
  public
    constructor Create; reintroduce; virtual;
    function CreateDataSet:TWebClientDataSet;
  published
    [Test] [async] procedure TestGetAll;
    [Test] [async] procedure TestGetOne;
  end;
{$M-}

implementation

uses
  SysUtils, senCille.DataManagement;

{ TTestPositions }

constructor TTestPositions.Create;
begin
   inherited;
   {Place where initialize de Dataset when we use it.}
end;

function TTestPositions.CreateDataSet:TWebClientDataSet;
var NewField :TField;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'CD_POSITION';
   NewField.Size        := 3;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'DS_POSITION';
   NewField.Size        := 30;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TMemoField.Create(Result);
   NewField.FieldName   := 'IMG_ICON';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   Result.Active := True;
end;

procedure TTestPositions.TestGetAll;
var Items     :TStrings;
    ExceptMsg :string;
begin
   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/getall', 'CD_POSITION', 'DS_POSITION', []));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetAll -> '+ExceptMsg);
      Assert.IsTrue(Items.Count > 0, 'Recovered more than 0 rows');
   finally
      Items.Free;
   end;
end;

procedure TTestPositions.TestGetOne;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_POSITION', TEST_POSITION_CODE]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOne -> '+ExceptMsg);
      //Assert.IsTrue(DataSet.RecordCount = 1, 'Exactly one record retrieved');
      //Assert.IsTrue(DataSet.FieldByName('DS_POSITION').AsString = TEST_POSITION_NAME, 'Position name matches expected value');
   finally
      DataSet.Free;
   end;
end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestPositions);
end.
