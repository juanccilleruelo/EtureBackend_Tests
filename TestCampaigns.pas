unit TestCampaigns;

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
  TTestCampaigns = class(TObject)
  private
    const LOCAL_PATH = '/campaigns';
    const PathAux1   = '/campaigns';
    const TEST_CODE  = 'TEST_CAMPAIGN';
  public
    constructor Create; reintroduce; virtual;
    function CreateDataSet:TWebClientDataSet;
    [async] procedure GetTestRow(DataSet :TWebClientDataSet);
    {--- CAMPAIGN_PLAYERS ---}
    [async] function CreateDataSetCampaigns :TWebClientDataSet;
  published
    [Test] [async] procedure TestInsert;
    [Test] [async] procedure TestLoad;
    [Test] [async] procedure TestGetRow;
    [Test] [async] procedure TestGetAll;
    [Test] [async] procedure TestUpdate;
    [Test] [async] procedure TestIsReferenced;
    [Test] [async] procedure TestDelete;
    [Test] [async] procedure TestGetOrderByFields;
    {--- CAMPAIGN_PLAYERS ---}
    [Test] [async] procedure TestInsertPlayer;
  end;
{$M-}

implementation

uses
  SysUtils,
  senCille.DataManagement;

{ TTestCampaigns }

constructor TTestCampaigns.Create;
begin
   inherited;
   {Place where initialize de Dataset when we use it.}
end;

function TTestCampaigns.CreateDataSet:TWebClientDataSet;
var NewField :TField;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'CD_CAMPAIGN';
   NewField.Size        := 14;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'DS_CAMPAIGN';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'LAUNCH_YEAR';
   NewField.Size        := 4;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TIntegerField.Create(Result);
   NewField.FieldName   := 'COLOR';
   NewField.Size        := 14;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'SECTION';
   NewField.Size        := 12;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TMemoField.Create(Result);
   NewField.FieldName   := 'NOTES';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TMemoField.Create(Result);
   NewField.FieldName   := 'IMG_LOGO';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   Result.Active := True;
end;

procedure TTestCampaigns.GetTestRow(DataSet :TWebClientDataSet);
begin
   await(TDB.GetRow(LOCAL_PATH,
                    [['CD_CAMPAIGN', TEST_CODE]
                    ], DataSet));
end;

function TTestCampaigns.CreateDataSetCampaigns :TWebClientDataSet;
begin

end;

procedure TTestCampaigns.TestInsert;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   DataSet := CreateDataSet;
   try
      DataSet.Append;
      DataSet.FieldByName('CD_CAMPAIGN').AsString  := TEST_CODE;
      DataSet.FieldByName('DS_CAMPAIGN').AsString  := 'TEST DATA, CAN BE DELETED';
      DataSet.FieldByName('LAUNCH_YEAR').AsString  := '2025';
      DataSet.FieldByName('COLOR'      ).AsInteger := 9999;
      DataSet.FieldByName('SECTION'    ).AsString  := 'GAP_YEAR';
      DataSet.FieldByName('NOTES'      ).AsString  := 'Notes of test';
      DataSet.FieldByName('IMG_LOGO'   ).AsString  := 'Image loaded';
      DataSet.Post;

      try
         await(TDB.Insert(LOCAL_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Insert-> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

procedure TTestCampaigns.TestLoad;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Count     :Integer;
begin
   DataSet := CreateDataSet;
   try
      try
         Count := await(TDB.Select(LOCAL_PATH,
                        [['PageNumber', IntToStr(1) ],
                         ['SearchText', 'TEST_DATA' ],
                         ['OrderField', ''          ]],
                         DataSet)
                        );
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Load -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount > 0, 'DataSet.RecourdCount Is more than 0');
      Assert.IsTrue(DataSet.FieldByName('CD_CAMPAIGN').AsString = TEST_CODE, 'Load OK');
   finally
      DataSet.Free;
   end;
end;

procedure TTestCampaigns.TestGetRow;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_CAMPAIGN', TEST_CODE]
                          ], DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetRow  -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 1, 'DataSet.RecourdCount is equal to 1');
      Assert.IsTrue(DataSet.FieldByName('CD_CAMPAIGN').AsString = TEST_CODE, 'TEST_CODE line loaded');
   finally
      DataSet.Free;
   end;
end;

procedure TTestCampaigns.TestGetAll;
var Items     :TStrings;
    ExceptMsg :string;
begin
   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/getall', 'CD_CAMPAIGN', 'DS_CAMPAIGN', []));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetAll  -> '+ExceptMsg);
      Assert.IsTrue(Items.Count > 0, 'Recovered more than 0 rows');
   finally
      Items.Free;
   end;
end;

procedure TTestCampaigns.TestUpdate;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   DataSet := CreateDataSet;
   try
      await(GetTestRow(DataSet));

      DataSet.Edit;
      DataSet.FieldByName('DS_CAMPAIGN').AsString := 'Modified Row. Can be deleted';
      DataSet.Post;

      try
         await(TDB.Update(LOCAL_PATH, [['OLD_CD_CAMPAIGN', TEST_CODE]], DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception Updating  -> '+ExceptMsg);
      await(GetTestRow(DataSet));
      Assert.IsTrue(DataSet.FieldByName('DS_CAMPAIGN').AsString = 'Modified Row. Can be deleted', 'Recovered data is the same that the modified one');
   finally
      DataSet.Free;
   end;
end;

procedure TTestCampaigns.TestIsReferenced;
var DataSet      :TWebClientDataSet;
    IsReferenced :Boolean;
    ExceptMsg    :string;
    TextMessage  :string;
begin
   DataSet := CreateDataSet;
   try
      await(GetTestRow(DataSet));
      try
         IsReferenced := await(Boolean, TDB.IsReferenced(LOCAL_PATH, DataSet, TextMessage));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Delete  -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

procedure TTestCampaigns.TestDelete;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   try
      await(TDB.Delete(LOCAL_PATH, [['CD_CAMPAIGN', TEST_CODE]]));
      ExceptMsg := 'ok';
   except
      on E:Exception do ExceptMsg := E.Message;
   end;

   Assert.IsTrue(ExceptMsg = 'ok', 'Exception in Delete  -> '+ExceptMsg);

   DataSet := CreateDataSet;
   try
      GetTestRow(DataSet);
      Assert.IsTrue(DataSet.IsEmpty, 'Deleted row does not appear on DB');
   finally
      DataSet.Free;
   end;
end;

procedure TTestCampaigns.TestGetOrderByFields;
var Items     :TStrings;
    ExceptMsg :string;
begin
   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/getorderbyfields', 'FIELD_NAME', 'SHOW_NAME', []));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOrderByFields  -> '+ExceptMsg);
   finally
      Items.Free;
   end;
end;

{--- CAMPAIGN_PLAYERS ---}
procedure TTestCampaigns.TestInsertPlayer;
begin
end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestCampaigns);
end.
