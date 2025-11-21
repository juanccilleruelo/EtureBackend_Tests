unit TestScholarshipTypes;

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
   TTestScholarshipTypes = class(TObject)
   private
      const LOCAL_PATH = '/scholarshiptypes';
   private
      function CreateDataSet:TWebClientDataSet;
      function ExtractCodeFromItems(AItems :TStrings):string;
   published
      [Test] [async] procedure TestGetOne;
      [Test] [async] procedure TestGetAll;
   end;
{$M-}

implementation

uses
   SysUtils,
   senCille.DataManagement;

{ TTestScholarshipTypes }

function TTestScholarshipTypes.CreateDataSet:TWebClientDataSet;
var NewField :TField;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'CD_SCHOLARSHIP_TYPE';
   NewField.Size        := 2;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'DS_SCHOLARSHIP_TYPE';
   NewField.Size        := 12;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   Result.Active := True;
end;

function TTestScholarshipTypes.ExtractCodeFromItems(AItems :TStrings):string;
begin
   Result := '';
   if AItems.Count = 0 then Exit;

   if AItems.Names[0] <> '' then Result := AItems.Names[0]
   else Result := AItems[0];
end;

[Test] [async] procedure TTestScholarshipTypes.TestGetOne;
var DataSet    :TWebClientDataSet;
    Items      :TStrings;
    ExceptMsg  :string;
    CodeToLoad :string;
begin
   Items := TStringList.Create;
   try
      Items.NameValueSeparator := '=';
      ExceptMsg := 'ok';
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/getall', 'CD_SCHOLARSHIP_TYPE', 'DS_SCHOLARSHIP_TYPE', []));
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception filling combo -> '+ExceptMsg);
      Assert.IsTrue(Items.Count > 0, 'Recovered more than 0 scholarship types');

      CodeToLoad := ExtractCodeFromItems(Items);
      Assert.IsTrue(CodeToLoad <> '', 'A valid scholarship type code was retrieved');
   finally
      Items.Free;
   end;

   DataSet := CreateDataSet;
   try
      ExceptMsg := 'ok';
      try
         await(TDB.GetRow(LOCAL_PATH,
                          [['CD_SCHOLARSHIP_TYPE', CodeToLoad]],
                          DataSet));
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOne -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 1, 'Exactly one record retrieved');
      Assert.IsTrue(DataSet.FieldByName('CD_SCHOLARSHIP_TYPE').AsString = CodeToLoad,
                    'Scholarship type code matches the requested value');
   finally
      DataSet.Free;
   end;
end;

[Test] [async] procedure TTestScholarshipTypes.TestGetAll;
var Items     :TStrings;
    ExceptMsg :string;
begin
   Items := TStringList.Create;
   try
      ExceptMsg := 'ok';
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/getall', 'CD_SCHOLARSHIP_TYPE', 'DS_SCHOLARSHIP_TYPE', []));
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
   TTMSWEBUnitTestingRunner.RegisterClass(TTestScholarshipTypes);

end.
