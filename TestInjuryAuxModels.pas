unit TestInjuryAuxModels;

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
  TTestInjuryAuxModels = class(TObject)
  private
    LocalPath :string;
    function BuildPath(const ATable, AAction :string):string;
    [async] function GetFirstCode(const ATable, ACodeField, ADescField :string; out ACode :string):Boolean;
  public
    constructor Create; reintroduce; virtual;
    function CreateDataSet(Table :string):TWebClientDataSet;
  published
    [Test] [async] procedure TestGetAllBodyPart;
    [Test] [async] procedure TestGetOneBodyPart;

    [Test] [async] procedure TestGetAllSurface;
    [Test] [async] procedure TestGetOneSurface;

    [Test] [async] procedure TestGetAllNature;
    [Test] [async] procedure TestGetOneNature;

    [Test] [async] procedure TestGetAllTimeOfOnset;
    [Test] [async] procedure TestGetOneTimeOfOnset;

    [Test] [async] procedure TestGetAllType;
    [Test] [async] procedure TestGetOneType;

    [Test] [async] procedure TestGetAllMechanism;
    [Test] [async] procedure TestGetOneMechanism;

    [Test] [async] procedure TestGetAllAffectedOrgan;
    [Test] [async] procedure TestGetOneAffectedOrgan;
  end;
{$M-}

implementation

uses
   SysUtils,
   senCille.DataManagement;

{ TTestInjuryAuxModels }

constructor TTestInjuryAuxModels.Create;
begin
   inherited;
   {Place where initialize de Dataset when we use it.}
end;

function TTestInjuryAuxModels.BuildPath(const ATable, AAction :string):string;
begin
   Result := LocalPath + '/' + LowerCase(ATable) + '/' + LowerCase(AAction);
end;

[async] function TTestInjuryAuxModels.GetFirstCode(const ATable, ACodeField, ADescField :string; out ACode :string):Boolean;
var Items     :TStrings;
    ExceptMsg :string;
begin
   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items,
                                BuildPath(ATable, 'getall'),
                                ACodeField,
                                ADescField,
                                []));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetFirstCode -> '+ExceptMsg);
      Result := Items.Count > 0;
      if Result then begin
         ACode := Items.Names[0];
         if ACode = '' then begin
            ACode := Items.ValueFromIndex[0];
         end;
      end;
   finally
      Items.Free;
   end;
end;

function TTestInjuryAuxModels.CreateDataSet(Table :string):TWebClientDataSet;
var NewField :TField;
begin
   inherited;

   LocalPath := '/injuries';

   Result := TWebClientDataSet.Create(nil);
   if Table = 'BODY_PART' then begin
      NewField := TStringField.Create(Result);
      NewField.FieldName   := 'CD_INJURY_BODY_PART';
      NewField.Size        := 5;
      NewField.DataSet     := Result;
      Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

      NewField := TStringField.Create(Result);
      NewField.FieldName   := 'DS_INJURY_BODY_PART';
      NewField.Size        := 30;
      NewField.DataSet     := Result;
   end else
   if Table = 'SURFACE' then begin
      NewField := TStringField.Create(Result);
      NewField.FieldName   := 'CD_INJURY_SURFACE';
      NewField.Size        := 5;
      NewField.DataSet     := Result;
      Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

      NewField := TStringField.Create(Result);
      NewField.FieldName   := 'DS_INJURY_SURFACE';
      NewField.Size        := 30;
      NewField.DataSet     := Result;
   end else
   if Table = 'NATURE' then begin
      NewField := TStringField.Create(Result);
      NewField.FieldName   := 'CD_INJURY_NATURE';
      NewField.Size        := 5;
      NewField.DataSet     := Result;
      Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

      NewField := TStringField.Create(Result);
      NewField.FieldName   := 'DS_INJURY_NATURE';
      NewField.Size        := 30;
      NewField.DataSet     := Result;
   end else
   if Table = 'TIME_OF_ONSET' then begin
      NewField := TStringField.Create(Result);
      NewField.FieldName   := 'CD_INJURY_TIME_OF_ONSET';
      NewField.Size        := 5;
      NewField.DataSet     := Result;
      Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

      NewField := TStringField.Create(Result);
      NewField.FieldName   := 'DS_INJURY_TIME_OF_ONSET';
      NewField.Size        := 30;
      NewField.DataSet     := Result;
   end else
   if Table = 'TYPE' then begin
      NewField := TStringField.Create(Result);
      NewField.FieldName   := 'CD_INJURY_TYPE';
      NewField.Size        := 5;
      NewField.DataSet     := Result;
      Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

      NewField := TStringField.Create(Result);
      NewField.FieldName   := 'DS_INJURY_TYPE';
      NewField.Size        := 30;
      NewField.DataSet     := Result;
   end else
   if Table = 'MECHANISM' then begin
      NewField := TStringField.Create(Result);
      NewField.FieldName   := 'CD_INJURY_MECHANISM';
      NewField.Size        := 5;
      NewField.DataSet     := Result;
      Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

      NewField := TStringField.Create(Result);
      NewField.FieldName   := 'DS_INJURY_MECHANISM';
      NewField.Size        := 30;
      NewField.DataSet     := Result;
   end else
   if Table = 'AFFECTED_ORGAN' then begin
      NewField := TStringField.Create(Result);
      NewField.FieldName   := 'CD_INJURY_AFFECTED_ORGAN';
      NewField.Size        := 5;
      NewField.DataSet     := Result;
      Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

      NewField := TStringField.Create(Result);
      NewField.FieldName   := 'DS_INJURY_AFFECTED_ORGAN';
      NewField.Size        := 30;
      NewField.DataSet     := Result;
   end;

   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   Result.Active := True;
end;

procedure TTestInjuryAuxModels.TestGetAllBodyPart;
var Items     :TStrings;
    ExceptMsg :string;
begin
   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items,
                                BuildPath('BODY_PART', 'getall'),
                                'CD_INJURY_BODY_PART',
                                'DS_INJURY_BODY_PART',
                                []));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetAllBodyPart -> '+ExceptMsg);
      Assert.IsTrue(Items.Count > 0, 'Recovered more than 0 rows');
   finally
      Items.Free;
   end;
end;

procedure TTestInjuryAuxModels.TestGetOneBodyPart;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Code      :string;
begin
   if not await(Boolean, GetFirstCode('BODY_PART', 'CD_INJURY_BODY_PART', 'DS_INJURY_BODY_PART', Code)) then begin
      Assert.Fail('No injury body part data available');
      Exit;
   end;

   DataSet := CreateDataSet('BODY_PART');
   try
      try
         await(TDB.GetRow(BuildPath('BODY_PART', 'getone'),
                          [[DataSet.Fields[0].FieldName, Code]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOneBodyPart -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 1, 'Exactly one record retrieved');
      Assert.IsTrue(DataSet.FieldByName(DataSet.Fields[0].FieldName).AsString = Code, 'Requested code returned');
   finally
      DataSet.Free;
   end;
end;

procedure TTestInjuryAuxModels.TestGetAllSurface;
var Items     :TStrings;
    ExceptMsg :string;
begin
   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items,
                                BuildPath('SURFACE', 'getall'),
                                'CD_INJURY_SURFACE',
                                'DS_INJURY_SURFACE',
                                []));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetAllSurface -> '+ExceptMsg);
      Assert.IsTrue(Items.Count > 0, 'Recovered more than 0 rows');
   finally
      Items.Free;
   end;
end;

procedure TTestInjuryAuxModels.TestGetOneSurface;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Code      :string;
begin
   if not await(Boolean, GetFirstCode('SURFACE', 'CD_INJURY_SURFACE', 'DS_INJURY_SURFACE', Code)) then begin
      Assert.Fail('No injury surface data available');
      Exit;
   end;

   DataSet := CreateDataSet('SURFACE');
   try
      try
         await(TDB.GetRow(BuildPath('SURFACE', 'getone'),
                          [[DataSet.Fields[0].FieldName, Code]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOneSurface -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 1, 'Exactly one record retrieved');
      Assert.IsTrue(DataSet.FieldByName(DataSet.Fields[0].FieldName).AsString = Code, 'Requested code returned');
   finally
      DataSet.Free;
   end;
end;

procedure TTestInjuryAuxModels.TestGetAllNature;
var Items     :TStrings;
    ExceptMsg :string;
begin
   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items,
                                BuildPath('NATURE', 'getall'),
                                'CD_INJURY_NATURE',
                                'DS_INJURY_NATURE',
                                []));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetAllNature -> '+ExceptMsg);
      Assert.IsTrue(Items.Count > 0, 'Recovered more than 0 rows');
   finally
      Items.Free;
   end;
end;

procedure TTestInjuryAuxModels.TestGetOneNature;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Code      :string;
begin
   if not await(Boolean, GetFirstCode('NATURE', 'CD_INJURY_NATURE', 'DS_INJURY_NATURE', Code)) then begin
      Assert.Fail('No injury nature data available');
      Exit;
   end;

   DataSet := CreateDataSet('NATURE');
   try
      try
         await(TDB.GetRow(BuildPath('NATURE', 'getone'),
                          [[DataSet.Fields[0].FieldName, Code]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOneNature -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 1, 'Exactly one record retrieved');
      Assert.IsTrue(DataSet.FieldByName(DataSet.Fields[0].FieldName).AsString = Code, 'Requested code returned');
   finally
      DataSet.Free;
   end;
end;

procedure TTestInjuryAuxModels.TestGetAllTimeOfOnset;
var Items     :TStrings;
    ExceptMsg :string;
begin
   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items,
                                BuildPath('TIME_OF_ONSET', 'getall'),
                                'CD_INJURY_TIME_OF_ONSET',
                                'DS_INJURY_TIME_OF_ONSET',
                                []));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetAllTimeOfOnset -> '+ExceptMsg);
      Assert.IsTrue(Items.Count > 0, 'Recovered more than 0 rows');
   finally
      Items.Free;
   end;
end;

procedure TTestInjuryAuxModels.TestGetOneTimeOfOnset;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Code      :string;
begin
   if not await(Boolean, GetFirstCode('TIME_OF_ONSET', 'CD_INJURY_TIME_OF_ONSET', 'DS_INJURY_TIME_OF_ONSET', Code)) then begin
      Assert.Fail('No injury time of onset data available');
      Exit;
   end;

   DataSet := CreateDataSet('TIME_OF_ONSET');
   try
      try
         await(TDB.GetRow(BuildPath('TIME_OF_ONSET', 'getone'),
                          [[DataSet.Fields[0].FieldName, Code]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOneTimeOfOnset -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 1, 'Exactly one record retrieved');
      Assert.IsTrue(DataSet.FieldByName(DataSet.Fields[0].FieldName).AsString = Code, 'Requested code returned');
   finally
      DataSet.Free;
   end;
end;

procedure TTestInjuryAuxModels.TestGetAllType;
var Items     :TStrings;
    ExceptMsg :string;
begin
   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items,
                                BuildPath('TYPE', 'getall'),
                                'CD_INJURY_TYPE',
                                'DS_INJURY_TYPE',
                                []));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetAllType -> '+ExceptMsg);
      Assert.IsTrue(Items.Count > 0, 'Recovered more than 0 rows');
   finally
      Items.Free;
   end;
end;

procedure TTestInjuryAuxModels.TestGetOneType;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Code      :string;
begin
   if not await(Boolean, GetFirstCode('TYPE', 'CD_INJURY_TYPE', 'DS_INJURY_TYPE', Code)) then begin
      Assert.Fail('No injury type data available');
      Exit;
   end;

   DataSet := CreateDataSet('TYPE');
   try
      try
         await(TDB.GetRow(BuildPath('TYPE', 'getone'),
                          [[DataSet.Fields[0].FieldName, Code]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOneType -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 1, 'Exactly one record retrieved');
      Assert.IsTrue(DataSet.FieldByName(DataSet.Fields[0].FieldName).AsString = Code, 'Requested code returned');
   finally
      DataSet.Free;
   end;
end;

procedure TTestInjuryAuxModels.TestGetAllMechanism;
var Items     :TStrings;
    ExceptMsg :string;
begin
   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items,
                                BuildPath('MECHANISM', 'getall'),
                                'CD_INJURY_MECHANISM',
                                'DS_INJURY_MECHANISM',
                                []));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetAllMechanism -> '+ExceptMsg);
      Assert.IsTrue(Items.Count > 0, 'Recovered more than 0 rows');
   finally
      Items.Free;
   end;
end;

procedure TTestInjuryAuxModels.TestGetOneMechanism;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Code      :string;
begin
   if not await(Boolean, GetFirstCode('MECHANISM', 'CD_INJURY_MECHANISM', 'DS_INJURY_MECHANISM', Code)) then begin
      Assert.Fail('No injury mechanism data available');
      Exit;
   end;

   DataSet := CreateDataSet('MECHANISM');
   try
      try
         await(TDB.GetRow(BuildPath('MECHANISM', 'getone'),
                          [[DataSet.Fields[0].FieldName, Code]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOneMechanism -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 1, 'Exactly one record retrieved');
      Assert.IsTrue(DataSet.FieldByName(DataSet.Fields[0].FieldName).AsString = Code, 'Requested code returned');
   finally
      DataSet.Free;
   end;
end;

procedure TTestInjuryAuxModels.TestGetAllAffectedOrgan;
var Items     :TStrings;
    ExceptMsg :string;
begin
   Items := TStringList.Create;
   try
      try
         await(TDB.FillComboBox(Items,
                                BuildPath('AFFECTED_ORGAN', 'getall'),
                                'CD_INJURY_AFFECTED_ORGAN',
                                'DS_INJURY_AFFECTED_ORGAN',
                                []));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetAllAffectedOrgan -> '+ExceptMsg);
      Assert.IsTrue(Items.Count > 0, 'Recovered more than 0 rows');
   finally
      Items.Free;
   end;
end;

procedure TTestInjuryAuxModels.TestGetOneAffectedOrgan;
var DataSet   :TWebClientDataSet;
    ExceptMsg :string;
    Code      :string;
begin
   if not await(Boolean, GetFirstCode('AFFECTED_ORGAN', 'CD_INJURY_AFFECTED_ORGAN', 'DS_INJURY_AFFECTED_ORGAN', Code)) then begin
      Assert.Fail('No injury affected organ data available');
      Exit;
   end;

   DataSet := CreateDataSet('AFFECTED_ORGAN');
   try
      try
         await(TDB.GetRow(BuildPath('AFFECTED_ORGAN', 'getone'),
                          [[DataSet.Fields[0].FieldName, Code]],
                          DataSet));
         ExceptMsg := 'ok';
      except
         on E:Exception do ExceptMsg := E.Message;
      end;

      Assert.IsTrue(ExceptMsg = 'ok', 'Exception in GetOneAffectedOrgan -> '+ExceptMsg);
      Assert.IsTrue(DataSet.RecordCount = 1, 'Exactly one record retrieved');
      Assert.IsTrue(DataSet.FieldByName(DataSet.Fields[0].FieldName).AsString = Code, 'Requested code returned');
   finally
      DataSet.Free;
   end;
end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestInjuryAuxModels);
end.
