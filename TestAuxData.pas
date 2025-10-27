unit TestAuxData;

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
   TTestAuxDataController = class(TObject)
   private
      const LOCAL_PATH = '/auxdata';
      function BuildURL(const AResource :string): string;
   published
      [Test] [async] procedure TestSatActExam;
      [Test] [async] procedure TestSections;
      [Test] [async] procedure TestDivisions;
      [Test] [async] procedure TestEnglishLevels;
      [Test] [async] procedure TestCurrentlyStudying;
      [Test] [async] procedure TestSpanishLevels;
      [Test] [async] procedure TestMetrics;
      [Test] [async] procedure TestGrades;
   end;
{$M-}

implementation

uses senCille.WebSetup, senCille.DataManagement;

{ TTestAuxDataController }

function TTestAuxDataController.BuildURL(const AResource :string): string;
begin
   Result := TMVCReq.Host + LOCAL_PATH + AResource;
end;

procedure TTestAuxDataController.TestSatActExam;
var Items     :TStrings;
    ExceptMsg :string;
begin
   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/satactexam', 'FIELD_NAME', 'SHOW_NAME', []));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in TestSatActExam -> '+ExceptMsg);
      Assert.IsTrue(Items.Count > 0, 'satactexam by fields available');
   finally
      Items.Free;
   end;
end;

procedure TTestAuxDataController.TestSections;
var Items     :TStrings;
    ExceptMsg :string;
begin
   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/sections', 'FIELD_NAME', 'SHOW_NAME', []));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in sections -> '+ExceptMsg);
      Assert.IsTrue(Items.Count > 0, 'sections by fields available');
   finally
      Items.Free;
   end;
end;

procedure TTestAuxDataController.TestDivisions;
var Items     :TStrings;
    ExceptMsg :string;
begin
   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/divisions', 'FIELD_NAME', 'SHOW_NAME', []));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in divisions -> '+ExceptMsg);
      Assert.IsTrue(Items.Count > 0, 'divisions by fields available');
   finally
      Items.Free;
   end;
end;

procedure TTestAuxDataController.TestEnglishLevels;
var Items     :TStrings;
    ExceptMsg :string;
begin
   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/englishlevels', 'FIELD_NAME', 'SHOW_NAME', []));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in englishlevels -> '+ExceptMsg);
      Assert.IsTrue(Items.Count > 0, 'englishlevels by fields available');
   finally
      Items.Free;
   end;
end;

procedure TTestAuxDataController.TestCurrentlyStudying;
var Items     :TStrings;
    ExceptMsg :string;
begin
   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/currentlystudying', 'FIELD_NAME', 'SHOW_NAME', []));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in currentlystudying -> '+ExceptMsg);
      Assert.IsTrue(Items.Count > 0, 'currentlystudying by fields available');
   finally
      Items.Free;
   end;
end;

procedure TTestAuxDataController.TestSpanishLevels;
var Items     :TStrings;
    ExceptMsg :string;
begin
   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/spanishlevels', 'FIELD_NAME', 'SHOW_NAME', []));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in spanishlevels -> '+ExceptMsg);
      Assert.IsTrue(Items.Count > 0, 'spanishlevels by fields available');
   finally
      Items.Free;
   end;
end;

procedure TTestAuxDataController.TestMetrics;
var Items     :TStrings;
    ExceptMsg :string;
begin
   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/metrics', 'FIELD_NAME', 'SHOW_NAME', []));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in metrics -> '+ExceptMsg);
      Assert.IsTrue(Items.Count > 0, 'metrics by fields available');
   finally
      Items.Free;
   end;
end;

procedure TTestAuxDataController.TestGrades;
var Items     :TStrings;
    ExceptMsg :string;
begin
   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items, LOCAL_PATH+'/grades', 'FIELD_NAME', 'SHOW_NAME', []));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in grades -> '+ExceptMsg);
      Assert.IsTrue(Items.Count > 0, 'grades by fields available');
   finally
      Items.Free;
   end;
end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestAuxDataController);
end.
