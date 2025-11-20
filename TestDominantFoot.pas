unit TestDominantFoot;

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
   TTestDominantFoot = class(TObject)
   private
      const LOCAL_PATH                = '/dominantfoot';
      const TEST_DOMINANT_FOOT_CODE   = 'R';
      const TEST_DOMINANT_FOOT_NAME   = 'Right';
   private
      function CreateDataSet:TWebClientDataSet;
      procedure FillDominantFootData(ADataSet :TWebClientDataSet; const ACode, AName :string);
      [async] function HasTestDominantFoot:Boolean;
      [async] procedure EnsureTestDominantFootExists;
      [async] procedure DeleteTestDominantFootIfExists;
   published
      [Test] [async] procedure TestGetOne;
      [Test] [async] procedure TestGetAll;
   end;
{$M-}

implementation

uses
   SysUtils,
   senCille.DataManagement;

{ TTestDominantFoot }

function TTestDominantFoot.CreateDataSet:TWebClientDataSet;
var NewField :TField;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'CD_DOMINANT_FOOT';
   NewField.Size        := 1;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'DS_DOMINANT_FOOT';
   NewField.Size        := 10;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   Result.Active := True;
end;

procedure TTestDominantFoot.FillDominantFootData(ADataSet :TWebClientDataSet; const ACode, AName :string);
begin
   ADataSet.Append;
   ADataSet.FieldByName('CD_DOMINANT_FOOT').AsString := ACode;
   ADataSet.FieldByName('DS_DOMINANT_FOOT').AsString := AName;
   ADataSet.Post;
end;

[async] function TTestDominantFoot.HasTestDominantFoot:Boolean;
var DataSet :TWebClientDataSet;
begin
   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_DOMINANT_FOOT', TEST_DOMINANT_FOOT_CODE]],
                          DataSet));
      except
         on E:Exception do if DataSet.Active then DataSet.EmptyDataSet;
      end;
      Result := not DataSet.IsEmpty;
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestDominantFoot.EnsureTestDominantFootExists;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   if await(Boolean, HasTestDominantFoot()) then begin
      Exit;
   end;

   DataSet := CreateDataSet;
   try
      FillDominantFootData(DataSet,
                           TEST_DOMINANT_FOOT_CODE,
                           TEST_DOMINANT_FOOT_NAME);
      try
         await(TDB.Insert(LOCAL_PATH, DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;
      Assert.IsTrue(ExceptMsg = 'ok', 'EnsureTestDominantFootExists -> '+ExceptMsg);
   finally
      DataSet.Free;
   end;
end;

[async] procedure TTestDominantFoot.DeleteTestDominantFootIfExists;
begin
   try
      await(TDB.Delete(LOCAL_PATH, [['CD_DOMINANT_FOOT', TEST_DOMINANT_FOOT_CODE]]));
   except
      on E:Exception do ;
   end;
end;

[Test] [async] procedure TTestDominantFoot.TestGetOne;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
begin
   await(EnsureTestDominantFootExists());

   DataSet := CreateDataSet;
   try
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_DOMINANT_FOOT', TEST_DOMINANT_FOOT_CODE]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOne -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 1, 'Exactly one record retrieved');
      Assert.IsTrue(DataSet.FieldByName('DS_DOMINANT_FOOT').AsString = TEST_DOMINANT_FOOT_NAME, 'Dominant foot description matches expected value');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestDominantFoot.TestGetAll;
var Items     :TStrings;
    ExceptMsg :string;
begin
   await(EnsureTestDominantFootExists());

   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/getall', 'CD_DOMINANT_FOOT', 'DS_DOMINANT_FOOT', []));
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

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestDominantFoot);

end.
