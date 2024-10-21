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
end;

procedure TTestInjuryAuxModels.TestGetAllBodyPart;
var Request    :TWebHttpRequest;
    Data       :TJSXMLHttpRequest;
    JSON       :TJSON;
    JSONObject :TJSONObject;
    DataToSend :TJSONObject;
    JSONArray  :TJSONArray;
    jo         :TJSONObject;
    i          :integer;

var DataSet :TWebClientDataSet;
    US      :TFormatSettings;
begin
   US := TFormatSettings.Create('en-US');
   US.ShortDateFormat := 'MM/DD/YYYY';

   DataSet := CreateDataSet('BODY_PART');

   DataSet.Active := True;

   {Create the data to be send to the server}
   {that includes the PageNumber requested  }
   Request := TMVCReq.CreateJSON_JSONRequest(TMVCReq.Host+LocalPath+'/getallbodypart');
   DataToSend := TJSONObject.Create;
   DataToSend.AddPair('Language', 'EN');
   Request.PostData := DataToSend.ToString;

   Data := await(TJSXMLHttpRequest, Request.Perform);
   Assert.IsTrue(Data.Status = 200, 'Data.Status -> '+IntToStr(Data.Status));

   JSON       := TJSON.Create;
   JSONObject := TJSONObject(JSON.Parse(Data.ResponseText));
   JSONArray  := TJSONArray(JSONObject.GetValue('ROW'));

   for i := 0 to JSONArray.Count - 1 do begin
      jo := TJSONObject(JSONArray.Items[i]);
      DataSet.Append;
      DataSet.FieldByName('CD_INJURY_BODY_PART').AsString := jo.GetJSONValue('CD_INJURY_BODY_PART');
      DataSet.FieldByName('DS_INJURY_BODY_PART').AsString := jo.GetJSONValue('DS_INJURY_BODY_PART');
      DataSet.Post;
   end;

   Assert.IsTrue(JSONArray.Count > 3, 'Recovered plus than 3');
end;

procedure TTestInjuryAuxModels.TestGetOneBodyPart;
var Request    :TWebHttpRequest;
    Data       :TJSXMLHttpRequest;
    JSON       :TJSON;
    JSONObject :TJSONObject;
    DataToSend :TJSONObject;
    JSONArray  :TJSONArray;
    jo         :TJSONObject;

var DataSet :TWebClientDataSet;
begin
   DataSet := CreateDataSet('BODY_PART');
   DataSet.Active := True;

   Request := TMVCReq.CreateJSON_JSONRequest(TMVCReq.Host+LocalPath+'/getonebodypart');
   DataToSend := TJSONObject.Create;
   DataToSend.AddPair('Language', 'EN');
   DataToSend.AddPair('CD_INJURY_BODY_PART', '003');
   Request.PostData := DataToSend.ToString;

   Data := await(TJSXMLHttpRequest, Request.Perform);
   Assert.IsTrue(Data.Status = 200, 'Data.Status is different of 200');

   JSON       := TJSON.Create;
   JSONObject := TJSONObject(JSON.Parse(Data.ResponseText));
   JSONArray  := TJSONArray(JSONObject.GetValue('ROW'));
   jo := TJSONObject(JSONArray.Items[0]);

   if JSONArray.Count > 0 then begin
      DataSet.EmptyDataset;
      DataSet.Append;
      DataSet.FieldByName('CD_INJURY_BODY_PART').AsString := jo.GetJSONValue('CD_INJURY_BODY_PART');
      DataSet.FieldByName('DS_INJURY_BODY_PART').AsString := jo.GetJSONValue('DS_INJURY_BODY_PART');
      DataSet.Post;
   end;

   Assert.IsTrue(JSONArray.Count = 1, 'Recovered Only one');
end;

procedure TTestInjuryAuxModels.TestGetAllSurface;
var Request    :TWebHttpRequest;
    Data       :TJSXMLHttpRequest;
    JSON       :TJSON;
    JSONObject :TJSONObject;
    DataToSend :TJSONObject;
    JSONArray  :TJSONArray;
    jo         :TJSONObject;
    i          :integer;

var DataSet :TWebClientDataSet;
    US      :TFormatSettings;
begin
   US := TFormatSettings.Create('en-US');
   US.ShortDateFormat := 'MM/DD/YYYY';

   DataSet := CreateDataSet('SURFACE');

   DataSet.Active := True;

   {Create the data to be send to the server}
   {that includes the PageNumber requested  }
   Request := TMVCReq.CreateJSON_JSONRequest(TMVCReq.Host+LocalPath+'/getallsurface');
   DataToSend := TJSONObject.Create;
   DataToSend.AddPair('Language', 'EN');
   Request.PostData := DataToSend.ToString;

   Data := await(TJSXMLHttpRequest, Request.Perform);
   Assert.IsTrue(Data.Status = 200, 'Data.Status -> '+IntToStr(Data.Status));

   JSON       := TJSON.Create;
   JSONObject := TJSONObject(JSON.Parse(Data.ResponseText));
   JSONArray  := TJSONArray(JSONObject.GetValue('ROW'));

   for i := 0 to JSONArray.Count - 1 do begin
      jo := TJSONObject(JSONArray.Items[i]);
      DataSet.Append;
      DataSet.FieldByName('CD_INJURY_SURFACE').AsString := jo.GetJSONValue('CD_INJURY_SURFACE');
      DataSet.FieldByName('DS_INJURY_SURFACE').AsString := jo.GetJSONValue('DS_INJURY_SURFACE');
      DataSet.Post;
   end;

   Assert.IsTrue(JSONArray.Count > 3, 'Recovered plus than 3');
end;

procedure TTestInjuryAuxModels.TestGetOneSurface;
var Request    :TWebHttpRequest;
    Data       :TJSXMLHttpRequest;
    JSON       :TJSON;
    JSONObject :TJSONObject;
    DataToSend :TJSONObject;
    JSONArray  :TJSONArray;
    jo         :TJSONObject;

var DataSet :TWebClientDataSet;
begin
   DataSet := CreateDataSet('SURFACE');
   DataSet.Active := True;

   Request := TMVCReq.CreateJSON_JSONRequest(TMVCReq.Host+LocalPath+'/getonesurface');
   DataToSend := TJSONObject.Create;
   DataToSend.AddPair('Language', 'EN');
   DataToSend.AddPair('CD_INJURY_SURFACE', '003');
   Request.PostData := DataToSend.ToString;

   Data := await(TJSXMLHttpRequest, Request.Perform);
   Assert.IsTrue(Data.Status = 200, 'Data.Status is different of 200');

   JSON       := TJSON.Create;
   JSONObject := TJSONObject(JSON.Parse(Data.ResponseText));
   JSONArray  := TJSONArray(JSONObject.GetValue('ROW'));
   jo := TJSONObject(JSONArray.Items[0]);

   if JSONArray.Count > 0 then begin
      DataSet.EmptyDataset;
      DataSet.Append;
      DataSet.FieldByName('CD_INJURY_SURFACE').AsString := jo.GetJSONValue('CD_INJURY_SURFACE');
      DataSet.FieldByName('DS_INJURY_SURFACE').AsString := jo.GetJSONValue('DS_INJURY_SURFACE');
      DataSet.Post;
   end;

   Assert.IsTrue(JSONArray.Count = 1, 'Recovered Only one');
end;

procedure TTestInjuryAuxModels.TestGetAllNature;
var Request    :TWebHttpRequest;
    Data       :TJSXMLHttpRequest;
    JSON       :TJSON;
    JSONObject :TJSONObject;
    DataToSend :TJSONObject;
    JSONArray  :TJSONArray;
    jo         :TJSONObject;
    i          :integer;

var DataSet :TWebClientDataSet;
    US      :TFormatSettings;
begin
   US := TFormatSettings.Create('en-US');
   US.ShortDateFormat := 'MM/DD/YYYY';

   DataSet := CreateDataSet('NATURE');

   DataSet.Active := True;

   {Create the data to be send to the server}
   {that includes the PageNumber requested  }
   Request := TMVCReq.CreateJSON_JSONRequest(TMVCReq.Host+LocalPath+'/getallnature');
   DataToSend := TJSONObject.Create;
   DataToSend.AddPair('Language', 'EN');
   Request.PostData := DataToSend.ToString;

   Data := await(TJSXMLHttpRequest, Request.Perform);
   Assert.IsTrue(Data.Status = 200, 'Data.Status -> '+IntToStr(Data.Status));

   JSON       := TJSON.Create;
   JSONObject := TJSONObject(JSON.Parse(Data.ResponseText));
   JSONArray  := TJSONArray(JSONObject.GetValue('ROW'));

   for i := 0 to JSONArray.Count - 1 do begin
      jo := TJSONObject(JSONArray.Items[i]);
      DataSet.Append;
      DataSet.FieldByName('CD_INJURY_NATURE').AsString := jo.GetJSONValue('CD_INJURY_NATURE');
      DataSet.FieldByName('DS_INJURY_NATURE').AsString := jo.GetJSONValue('DS_INJURY_NATURE');
      DataSet.Post;
   end;

   Assert.IsTrue(JSONArray.Count > 3, 'Recovered plus than 3');
end;

procedure TTestInjuryAuxModels.TestGetOneNature;
var Request    :TWebHttpRequest;
    Data       :TJSXMLHttpRequest;
    JSON       :TJSON;
    JSONObject :TJSONObject;
    DataToSend :TJSONObject;
    JSONArray  :TJSONArray;
    jo         :TJSONObject;

var DataSet :TWebClientDataSet;
begin
   DataSet := CreateDataSet('NATURE');
   DataSet.Active := True;

   Request := TMVCReq.CreateJSON_JSONRequest(TMVCReq.Host+LocalPath+'/getonenature');
   DataToSend := TJSONObject.Create;
   DataToSend.AddPair('Language', 'EN');
   DataToSend.AddPair('CD_INJURY_NATURE', '003');
   Request.PostData := DataToSend.ToString;

   Data := await(TJSXMLHttpRequest, Request.Perform);
   Assert.IsTrue(Data.Status = 200, 'Data.Status is different of 200');

   JSON       := TJSON.Create;
   JSONObject := TJSONObject(JSON.Parse(Data.ResponseText));
   JSONArray  := TJSONArray(JSONObject.GetValue('ROW'));
   jo := TJSONObject(JSONArray.Items[0]);

   if JSONArray.Count > 0 then begin
      DataSet.EmptyDataset;
      DataSet.Append;
      DataSet.FieldByName('CD_INJURY_NATURE').AsString := jo.GetJSONValue('CD_INJURY_NATURE');
      DataSet.FieldByName('DS_INJURY_NATURE').AsString := jo.GetJSONValue('DS_INJURY_NATURE');
      DataSet.Post;
   end;

   Assert.IsTrue(JSONArray.Count = 1, 'Recovered Only one');
end;

procedure TTestInjuryAuxModels.TestGetAllTimeOfOnset;
var Request    :TWebHttpRequest;
    Data       :TJSXMLHttpRequest;
    JSON       :TJSON;
    JSONObject :TJSONObject;
    DataToSend :TJSONObject;
    JSONArray  :TJSONArray;
    jo         :TJSONObject;
    i          :integer;

var DataSet :TWebClientDataSet;
    US      :TFormatSettings;
begin
   US := TFormatSettings.Create('en-US');
   US.ShortDateFormat := 'MM/DD/YYYY';

   DataSet := CreateDataSet('TIME_OF_ONSET');

   DataSet.Active := True;

   {Create the data to be send to the server}
   {that includes the PageNumber requested  }
   Request := TMVCReq.CreateJSON_JSONRequest(TMVCReq.Host+LocalPath+'/getalltimeofonset');
   DataToSend := TJSONObject.Create;
   DataToSend.AddPair('Language', 'EN');
   Request.PostData := DataToSend.ToString;

   Data := await(TJSXMLHttpRequest, Request.Perform);
   Assert.IsTrue(Data.Status = 200, 'Data.Status -> '+IntToStr(Data.Status));

   JSON       := TJSON.Create;
   JSONObject := TJSONObject(JSON.Parse(Data.ResponseText));
   JSONArray  := TJSONArray(JSONObject.GetValue('ROW'));

   for i := 0 to JSONArray.Count - 1 do begin
      jo := TJSONObject(JSONArray.Items[i]);
      DataSet.Append;
      DataSet.FieldByName('CD_INJURY_TIME_OF_ONSET').AsString := jo.GetJSONValue('CD_INJURY_TIME_OF_ONSET');
      DataSet.FieldByName('DS_INJURY_TIME_OF_ONSET').AsString := jo.GetJSONValue('DS_INJURY_TIME_OF_ONSET');
      DataSet.Post;
   end;

   Assert.IsTrue(JSONArray.Count > 3, 'Recovered plus than 3');
end;

procedure TTestInjuryAuxModels.TestGetOneTimeOfOnset;
var Request    :TWebHttpRequest;
    Data       :TJSXMLHttpRequest;
    JSON       :TJSON;
    JSONObject :TJSONObject;
    DataToSend :TJSONObject;
    JSONArray  :TJSONArray;
    jo         :TJSONObject;

var DataSet :TWebClientDataSet;
begin
   DataSet := CreateDataSet('TIME_OF_ONSET');
   DataSet.Active := True;

   Request := TMVCReq.CreateJSON_JSONRequest(TMVCReq.Host+LocalPath+'/getonetimeofonset');
   DataToSend := TJSONObject.Create;
   DataToSend.AddPair('Language', 'EN');
   DataToSend.AddPair('CD_INJURY_TIME_OF_ONSET', '003');
   Request.PostData := DataToSend.ToString;

   Data := await(TJSXMLHttpRequest, Request.Perform);
   Assert.IsTrue(Data.Status = 200, 'Data.Status is different of 200');

   JSON       := TJSON.Create;
   JSONObject := TJSONObject(JSON.Parse(Data.ResponseText));
   JSONArray  := TJSONArray(JSONObject.GetValue('ROW'));
   jo := TJSONObject(JSONArray.Items[0]);

   if JSONArray.Count > 0 then begin
      DataSet.EmptyDataset;
      DataSet.Append;
      DataSet.FieldByName('CD_INJURY_TIME_OF_ONSET').AsString := jo.GetJSONValue('CD_INJURY_TIME_OF_ONSET');
      DataSet.FieldByName('DS_INJURY_TIME_OF_ONSET').AsString := jo.GetJSONValue('DS_INJURY_TIME_OF_ONSET');
      DataSet.Post;
   end;

   Assert.IsTrue(JSONArray.Count = 1, 'Recovered Only one');
end;

procedure TTestInjuryAuxModels.TestGetAllType;
var Request    :TWebHttpRequest;
    Data       :TJSXMLHttpRequest;
    JSON       :TJSON;
    JSONObject :TJSONObject;
    DataToSend :TJSONObject;
    JSONArray  :TJSONArray;
    jo         :TJSONObject;
    i          :integer;

var DataSet :TWebClientDataSet;
    US      :TFormatSettings;
begin
   US := TFormatSettings.Create('en-US');
   US.ShortDateFormat := 'MM/DD/YYYY';

   DataSet := CreateDataSet('TYPE');

   DataSet.Active := True;

   {Create the data to be send to the server}
   {that includes the PageNumber requested  }
   Request := TMVCReq.CreateJSON_JSONRequest(TMVCReq.Host+LocalPath+'/getalltype');
   DataToSend := TJSONObject.Create;
   DataToSend.AddPair('Language', 'EN');
   Request.PostData := DataToSend.ToString;

   Data := await(TJSXMLHttpRequest, Request.Perform);
   Assert.IsTrue(Data.Status = 200, 'Data.Status -> '+IntToStr(Data.Status));

   JSON       := TJSON.Create;
   JSONObject := TJSONObject(JSON.Parse(Data.ResponseText));
   JSONArray  := TJSONArray(JSONObject.GetValue('ROW'));

   for i := 0 to JSONArray.Count - 1 do begin
      jo := TJSONObject(JSONArray.Items[i]);
      DataSet.Append;
      DataSet.FieldByName('CD_INJURY_TYPE').AsString := jo.GetJSONValue('CD_INJURY_TYPE');
      DataSet.FieldByName('DS_INJURY_TYPE').AsString := jo.GetJSONValue('DS_INJURY_TYPE');
      DataSet.Post;
   end;

   Assert.IsTrue(JSONArray.Count > 3, 'Recovered plus than 3');
end;

procedure TTestInjuryAuxModels.TestGetOneType;
var Request    :TWebHttpRequest;
    Data       :TJSXMLHttpRequest;
    JSON       :TJSON;
    JSONObject :TJSONObject;
    DataToSend :TJSONObject;
    JSONArray  :TJSONArray;
    jo         :TJSONObject;

var DataSet :TWebClientDataSet;
begin
   DataSet := CreateDataSet('TYPE');
   DataSet.Active := True;

   Request := TMVCReq.CreateJSON_JSONRequest(TMVCReq.Host+LocalPath+'/getonetype');
   DataToSend := TJSONObject.Create;
   DataToSend.AddPair('Language', 'EN');
   DataToSend.AddPair('CD_INJURY_TYPE', '003');
   Request.PostData := DataToSend.ToString;

   Data := await(TJSXMLHttpRequest, Request.Perform);
   Assert.IsTrue(Data.Status = 200, 'Data.Status is different of 200');

   JSON       := TJSON.Create;
   JSONObject := TJSONObject(JSON.Parse(Data.ResponseText));
   JSONArray  := TJSONArray(JSONObject.GetValue('ROW'));
   jo := TJSONObject(JSONArray.Items[0]);

   if JSONArray.Count > 0 then begin
      DataSet.EmptyDataset;
      DataSet.Append;
      DataSet.FieldByName('CD_INJURY_TYPE').AsString := jo.GetJSONValue('CD_INJURY_TYPE');
      DataSet.FieldByName('DS_INJURY_TYPE').AsString := jo.GetJSONValue('DS_INJURY_TYPE');
      DataSet.Post;
   end;

   Assert.IsTrue(JSONArray.Count = 1, 'Recovered Only one');
end;

procedure TTestInjuryAuxModels.TestGetAllMechanism;
var Request    :TWebHttpRequest;
    Data       :TJSXMLHttpRequest;
    JSON       :TJSON;
    JSONObject :TJSONObject;
    DataToSend :TJSONObject;
    JSONArray  :TJSONArray;
    jo         :TJSONObject;
    i          :integer;

var DataSet :TWebClientDataSet;
    US      :TFormatSettings;
begin
   US := TFormatSettings.Create('en-US');
   US.ShortDateFormat := 'MM/DD/YYYY';

   DataSet := CreateDataSet('MECHANISM');

   DataSet.Active := True;

   {Create the data to be send to the server}
   {that includes the PageNumber requested  }
   Request := TMVCReq.CreateJSON_JSONRequest(TMVCReq.Host+LocalPath+'/getallmechanism');
   DataToSend := TJSONObject.Create;
   DataToSend.AddPair('Language', 'EN');
   Request.PostData := DataToSend.ToString;

   Data := await(TJSXMLHttpRequest, Request.Perform);
   Assert.IsTrue(Data.Status = 200, 'Data.Status -> '+IntToStr(Data.Status));

   JSON       := TJSON.Create;
   JSONObject := TJSONObject(JSON.Parse(Data.ResponseText));
   JSONArray  := TJSONArray(JSONObject.GetValue('ROW'));

   for i := 0 to JSONArray.Count - 1 do begin
      jo := TJSONObject(JSONArray.Items[i]);
      DataSet.Append;
      DataSet.FieldByName('CD_INJURY_MECHANISM').AsString := jo.GetJSONValue('CD_INJURY_MECHANISM');
      DataSet.FieldByName('DS_INJURY_MECHANISM').AsString := jo.GetJSONValue('DS_INJURY_MECHANISM');
      DataSet.Post;
   end;

   Assert.IsTrue(JSONArray.Count > 3, 'Recovered plus than 3');
end;

procedure TTestInjuryAuxModels.TestGetOneMechanism;
var Request    :TWebHttpRequest;
    Data       :TJSXMLHttpRequest;
    JSON       :TJSON;
    JSONObject :TJSONObject;
    DataToSend :TJSONObject;
    JSONArray  :TJSONArray;
    jo         :TJSONObject;

var DataSet :TWebClientDataSet;
begin
   DataSet := CreateDataSet('MECHANISM');
   DataSet.Active := True;

   Request := TMVCReq.CreateJSON_JSONRequest(TMVCReq.Host+LocalPath+'/getonemechanism');
   DataToSend := TJSONObject.Create;
   DataToSend.AddPair('Language', 'EN');
   DataToSend.AddPair('CD_INJURY_MECHANISM', '003');
   Request.PostData := DataToSend.ToString;

   Data := await(TJSXMLHttpRequest, Request.Perform);
   Assert.IsTrue(Data.Status = 200, 'Data.Status is different of 200');

   JSON       := TJSON.Create;
   JSONObject := TJSONObject(JSON.Parse(Data.ResponseText));
   JSONArray  := TJSONArray(JSONObject.GetValue('ROW'));
   jo := TJSONObject(JSONArray.Items[0]);

   if JSONArray.Count > 0 then begin
      DataSet.EmptyDataset;
      DataSet.Append;
      DataSet.FieldByName('CD_INJURY_MECHANISM').AsString := jo.GetJSONValue('CD_INJURY_MECHANISM');
      DataSet.FieldByName('DS_INJURY_MECHANISM').AsString := jo.GetJSONValue('DS_INJURY_MECHANISM');
      DataSet.Post;
   end;

   Assert.IsTrue(JSONArray.Count = 1, 'Recovered Only one');
end;

procedure TTestInjuryAuxModels.TestGetAllAffectedOrgan;
var Request    :TWebHttpRequest;
    Data       :TJSXMLHttpRequest;
    JSON       :TJSON;
    JSONObject :TJSONObject;
    DataToSend :TJSONObject;
    JSONArray  :TJSONArray;
    jo         :TJSONObject;
    i          :integer;

var DataSet :TWebClientDataSet;
    US      :TFormatSettings;
begin
   US := TFormatSettings.Create('en-US');
   US.ShortDateFormat := 'MM/DD/YYYY';

   DataSet := CreateDataSet('AFFECTED_ORGAN');

   DataSet.Active := True;

   {Create the data to be send to the server}
   {that includes the PageNumber requested  }
   Request := TMVCReq.CreateJSON_JSONRequest(TMVCReq.Host+LocalPath+'/getallaffectedorgan');
   DataToSend := TJSONObject.Create;
   DataToSend.AddPair('Language', 'EN');
   Request.PostData := DataToSend.ToString;

   Data := await(TJSXMLHttpRequest, Request.Perform);
   Assert.IsTrue(Data.Status = 200, 'Data.Status -> '+IntToStr(Data.Status));

   JSON       := TJSON.Create;
   JSONObject := TJSONObject(JSON.Parse(Data.ResponseText));
   JSONArray  := TJSONArray(JSONObject.GetValue('ROW'));

   for i := 0 to JSONArray.Count - 1 do begin
      jo := TJSONObject(JSONArray.Items[i]);
      DataSet.Append;
      DataSet.FieldByName('CD_INJURY_AFFECTED_ORGAN').AsString := jo.GetJSONValue('CD_INJURY_AFFECTED_ORGAN');
      DataSet.FieldByName('DS_INJURY_AFFECTED_ORGAN').AsString := jo.GetJSONValue('DS_INJURY_AFFECTED_ORGAN');
      DataSet.Post;
   end;

   Assert.IsTrue(JSONArray.Count > 3, 'Recovered plus than 3');
end;

procedure TTestInjuryAuxModels.TestGetOneAffectedOrgan;
var Request    :TWebHttpRequest;
    Data       :TJSXMLHttpRequest;
    JSON       :TJSON;
    JSONObject :TJSONObject;
    DataToSend :TJSONObject;
    JSONArray  :TJSONArray;
    jo         :TJSONObject;

var DataSet :TWebClientDataSet;
begin
   DataSet := CreateDataSet('AFFECTED_ORGAN');
   DataSet.Active := True;

   Request := TMVCReq.CreateJSON_JSONRequest(TMVCReq.Host+LocalPath+'/getoneaffectedorgan');
   DataToSend := TJSONObject.Create;
   DataToSend.AddPair('Language', 'EN');
   DataToSend.AddPair('CD_INJURY_AFFECTED_ORGAN', '003');
   Request.PostData := DataToSend.ToString;

   Data := await(TJSXMLHttpRequest, Request.Perform);
   Assert.IsTrue(Data.Status = 200, 'Data.Status is different of 200');

   JSON       := TJSON.Create;
   JSONObject := TJSONObject(JSON.Parse(Data.ResponseText));
   JSONArray  := TJSONArray(JSONObject.GetValue('ROW'));
   jo := TJSONObject(JSONArray.Items[0]);

   if JSONArray.Count > 0 then begin
      DataSet.EmptyDataset;
      DataSet.Append;
      DataSet.FieldByName('CD_INJURY_AFFECTED_ORGAN').AsString := jo.GetJSONValue('CD_INJURY_AFFECTED_ORGAN');
      DataSet.FieldByName('DS_INJURY_AFFECTED_ORGAN').AsString := jo.GetJSONValue('DS_INJURY_AFFECTED_ORGAN');
      DataSet.Post;
   end;

   Assert.IsTrue(JSONArray.Count = 1, 'Recovered Only one');
end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestInjuryAuxModels);
end.
