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
  SysUtils;

{ TTestInjuryAuxModels }

constructor TTestInjuryAuxModels.Create;
begin
   inherited;
   {Place where initialize de Dataset when we use it.}
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
begin

end;

procedure TTestInjuryAuxModels.TestGetOneBodyPart;
begin

end;

procedure TTestInjuryAuxModels.TestGetAllSurface;
begin

end;

procedure TTestInjuryAuxModels.TestGetOneSurface;
begin
end;

procedure TTestInjuryAuxModels.TestGetAllNature;
begin
end;

procedure TTestInjuryAuxModels.TestGetOneNature;
begin
end;

procedure TTestInjuryAuxModels.TestGetAllTimeOfOnset;
begin
end;

procedure TTestInjuryAuxModels.TestGetOneTimeOfOnset;
begin
end;

procedure TTestInjuryAuxModels.TestGetAllType;
begin

end;

procedure TTestInjuryAuxModels.TestGetOneType;
begin

end;

procedure TTestInjuryAuxModels.TestGetAllMechanism;
begin
end;

procedure TTestInjuryAuxModels.TestGetOneMechanism;
begin
end;

procedure TTestInjuryAuxModels.TestGetAllAffectedOrgan;
begin
end;

procedure TTestInjuryAuxModels.TestGetOneAffectedOrgan;
begin

end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestInjuryAuxModels);
end.
