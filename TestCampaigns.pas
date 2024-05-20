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
    LocalPath :string;
    function GetCurrentJSON(DataSet :TWebClientDataSet):TJSONObject;
  public
    constructor Create; reintroduce; virtual;
    function CreateDataSet:TWebClientDataSet;
    [async] procedure LoadIntoDataSet(DataSet :TWebClientDataSet);
  published
    [Test] [async] procedure TestInsert;
    [Test] [async] procedure Load;
    [Test] [async] procedure Update;
    [Test] [async] function DeleteRow:Boolean;
    [Text] [async] function IsReferenced(var TextMessage :string):Boolean;
  end;
{$M-}

implementation

uses
  SysUtils;

{ TTestCampaigns }

constructor TTestCampaigns.Create;
begin
   inherited;
   {Place where initialize de Dataset when we use it.}
end;

function TTestCampaigns.GetCurrentJSON(DataSet :TWebClientDataSet): TJSONObject;
var US :TFormatSettings;
begin
   US := TFormatSettings.Create('en-US');
   US.ShortDateFormat := 'MM/DD/YYYY';

   Result := TJSONObject.Create;
   Result.AddPair('CD_CAMPAIGN', DataSet.FieldByName('CD_CAMPAIGN').AsString);
   Result.AddPair('DS_CAMPAIGN', DataSet.FieldByName('DS_CAMPAIGN').AsString);
   Result.AddPair('COLOR'      , DataSet.FieldByName('COLOR'      ).AsInteger);
   Result.AddPair('NOTES'      , DataSet.FieldByName('NOTES'      ).AsString);
   Result.AddPair('IMG_LOGO'   , DataSet.FieldByName('IMG_LOGO'   ).AsString);
end;

function TTestCampaigns.CreateDataSet:TWebClientDataSet;
var NewField :TField;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'CD_CAMPAIGN';
   NewField.Size        := 14; // Establecer el tamaño del campo
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'DS_CAMPAIGN';
   NewField.Size        := 50; // Establecer el tamaño del campo
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TIntegerField.Create(Result);
   NewField.FieldName   := 'COLOR';
   NewField.Size        := 14; // Establecer el tamaño del campo
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
end;

procedure TTestCampaigns.TestInsert;
var Request :TWebHttpRequest;
    Data    :TJSXMLHttpRequest;
    DataSet :TWebClientDataSet;
begin
   LocalPath := '/campaigns';

   DataSet := CreateDataSet;
   DataSet.Active := True;

   DataSet.Append;
   DataSet.FieldByName('CD_CAMPAIGN').AsString  := 'TEST_DATA';
   DataSet.FieldByName('DS_CAMPAIGN').AsString  := 'TEST DATA, CAN BE DELETED';
   DataSet.FieldByName('COLOR'      ).AsInteger := 9999;
   DataSet.FieldByName('NOTES'      ).AsString  := 'Notes of test';
   DataSet.FieldByName('IMG_LOGO'   ).AsString  := 'Image loaded';
   DataSet.Post;

   Request := TMVCReq.CreatePOSTRequest(TMVCReq.Host+LocalPath+'/insert');
   Request.PostData := GetCurrentJSON(DataSet).ToString;

   Data := await(TJSXMLHttpRequest, Request.Perform);

   Assert.IsTrue(Data.Status = 200       , 'Data.Status   -> '+IntToStr(Data.Status));
   Assert.IsTrue(Data.ResponseText = 'OK', 'Data.Response -> '+Data.ResponseText);
end;


procedure TTestCampaigns.LoadIntoDataSet(DataSet :TWebClientDataSet);
var Request    :TWebHttpRequest;
    Data       :TJSXMLHttpRequest;
    JSON       :TJSON;
    JSONObject :TJSONObject;
    DataToSend :TJSONObject;
    JSONArray  :TJSONArray;
    jo         :TJSONObject;
    i          :integer;
    US         :TFormatSettings;
    Rows       :string;
    Element    :TJSHTMLElement;
begin
   {Create the data to be send to the server}
   {that includes the PageNumber requested  }
   Request := TMVCReq.CreateJSON_JSONRequest(TMVCReq.Host+LocalPath+'/load');
   DataToSend := TJSONObject.Create;
   DataToSend.AddPair('PageNumber', 0);
   DataToSend.AddPair('SearchText', 'TEST_DATA');
   DataToSend.AddPair('OrderField', 'CAMPAIGNS.CD_CAMPAIGN');
   Request.PostData := DataToSend.ToString;

   Data := await(TJSXMLHttpRequest, Request.Perform);
   Assert.IsTrue(Data.Status = 200, 'Data.Status -> '+IntToStr(Data.Status));

   JSON       := TJSON.Create;
   JSONObject := TJSONObject(JSON.Parse(Data.ResponseText));
   JSONArray  := TJSONArray(JSONObject.GetValue('ROW'));

   DataSet.EmptyDataSet;
   {Check if an error exists }
   if JSONArray.Count = 1 then begin
      jo := TJSONObject(JSONArray.Items[0]);
   end;

   {The first row holds the NumberOfPages you can recover}
   jo := TJSONObject(JSONArray.Items[0]);
   for i := 1 to JSONArray.Count - 1 do begin
      jo := TJSONObject(JSONArray.Items[i]);
      DataSet.Append;
      DataSet.FieldByName('CD_CAMPAIGN').AsString := jo.GetJSONValue('CD_CAMPAIGN');
      DataSet.FieldByName('DS_CAMPAIGN').AsString := jo.GetJSONValue('DS_CAMPAIGN');
      DataSet.Post;
   end;
end;

procedure TTestCampaigns.Update;
var Request :TWebHttpRequest;
    Data    :TJSXMLHttpRequest;
    DataSet :TWebClientDataSet;
begin
   LocalPath := '/campaigns';

   DataSet := CreateDataSet;
   DataSet.Active := True;

   await(LoadIntoDataSet(DataSet));

   DataSet.Edit;
   DataSet.FieldByName('DS_CAMPAIGN').AsString := 'Modified Row. Can be deleted';
   DataSet.Post;

   Request := TMVCReq.CreatePOSTRequest(TMVCReq.Host+LocalPath+'/update');
   Request.PostData := GetCurrentJSON(DataSet).ToString;

   Data := await(TJSXMLHttpRequest, Request.Perform);
   Assert.IsTrue(Data.Status = 200       , 'Data.Status   -> '+IntToStr(Data.Status));
   Assert.IsTrue(Data.ResponseText = 'OK', 'Data.Response -> '+Data.ResponseText);

   DataSet.EmptyDataSet;
   await(LoadIntoDataSet(DataSet));
   Assert.IsTrue(DataSet.FieldByName('DS_CAMPAIGN').AsString.Trim = 'Modified Row. Can be deleted', DataSet.FieldByName('DS_CAMPAIGN').AsString.Trim);
end;

function TTestCampaigns.DeleteRow: Boolean;
var Request :TWebHttpRequest;
    Data    :TJSXMLHttpRequest;
    DataSet :TWebClientDataSet;
begin
   LocalPath := '/campaigns';

   DataSet := CreateDataSet;
   DataSet.Active := True;

   await(LoadIntoDataSet(DataSet));

   Request := TMVCReq.CreatePOSTRequest(TMVCReq.Host+LocalPath+'/delete');
   Request.PostData := GetCurrentJSON(DataSet).ToString;

   Data := await(TJSXMLHttpRequest, Request.Perform);
   Assert.IsTrue(Data.Status = 200       , 'Data.Status   -> '+IntToStr(Data.Status));
   Assert.IsTrue(Data.ResponseText = 'OK', 'Data.Response -> '+Data.ResponseText);

   DataSet.EmptyDataSet;
   await(LoadIntoDataSet(DataSet));
   Assert.IsTrue(DataSet.IsEmpty, 'Has been deleted');
end;

procedure TTestCampaigns.Load;
var Request    :TWebHttpRequest;
    Data       :TJSXMLHttpRequest;
    JSON       :TJSON;
    JSONObject :TJSONObject;
    DataToSend :TJSONObject;
    JSONArray  :TJSONArray;
    jo         :TJSONObject;
    i          :integer;
    US         :TFormatSettings;
    Rows       :string;
    Element    :TJSHTMLElement;

    DataSet :TWebClientDataSet;
begin
   US := TFormatSettings.Create('en-US');
   US.ShortDateFormat := 'MM/DD/YYYY';

   LocalPath := '/campaigns';

   DataSet := CreateDataSet;
   DataSet.Active := True;

   {Create the data to be send to the server}
   {that includes the PageNumber requested  }
   Request := TMVCReq.CreateJSON_JSONRequest(TMVCReq.Host+LocalPath+'/load');
   DataToSend := TJSONObject.Create;
   DataToSend.AddPair('PageNumber', 0);
   DataToSend.AddPair('SearchText', 'TEST_DATA');
   DataToSend.AddPair('OrderField', 'CAMPAIGNS.CD_CAMPAIGN');
   Request.PostData := DataToSend.ToString;

   Data := await(TJSXMLHttpRequest, Request.Perform);
   Assert.IsTrue(Data.Status = 200, 'Data.Status -> '+IntToStr(Data.Status));

   JSON       := TJSON.Create;
   JSONObject := TJSONObject(JSON.Parse(Data.ResponseText));
   JSONArray  := TJSONArray(JSONObject.GetValue('ROW'));

   DataSet.EmptyDataSet;
   {Check if an error exists }
   if JSONArray.Count = 1 then begin
      jo := TJSONObject(JSONArray.Items[0]);
      Assert.IsTrue(jo.GetValue('##ERROR##') <> nil, '##ERROR##');
   end;
   {-----------}

   {The first row holds the NumberOfPages you can recover}
   jo := TJSONObject(JSONArray.Items[0]);
   //LastPage := StrToInt(jo.GetJSONValue('NUMBER_OF_PAGES'));

   for i := 1 to JSONArray.Count - 1 do begin
      jo := TJSONObject(JSONArray.Items[i]);
      DataSet.Append;
      DataSet.FieldByName('CD_CAMPAIGN').AsString := jo.GetJSONValue('CD_CAMPAIGN');
      DataSet.FieldByName('DS_CAMPAIGN').AsString := jo.GetJSONValue('DS_CAMPAIGN');
      DataSet.Post;
   end;

   Assert.IsTrue(DataSet.FieldByName('CD_CAMPAIGN').AsString = 'TEST_DATA', 'Load OK');
end;

function TTestCampaigns.IsReferenced(var TextMessage: string): Boolean;
begin

end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestCampaigns);
end.
