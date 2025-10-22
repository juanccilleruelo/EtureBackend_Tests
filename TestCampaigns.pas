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
    function GetCurrentJSONPlayer(DataSet :TWebClientDataSet):TJSONObject;
  public
    constructor Create; reintroduce; virtual;
    function CreateDataSet:TWebClientDataSet;
    [async] procedure LoadIntoDataSet(DataSet :TWebClientDataSet);
    [async] procedure GetOne(DataSet :TWebClientDataSet);
    {--- CAMPAIGN_PLAYERS ---}
    [async] function GetDataSetPlayers:TWebClientDataSet;
    [async] function CreateDataSetCampaigns :TWebClientDataSet;
  published
    [Test] [async] procedure TestInsert;
    [Test] [async] procedure TestLoad;
    [Test] [async] procedure TestUpdate;
    [Test] [async] function TestDelete:Boolean;
    [Text] [async] function TestIsReferenced(var TextMessage :string):Boolean;
    {--- CAMPAIGN_PLAYERS ---}
    [Test] [async] procedure TestInsertPlayer;
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
begin
   Result := TJSONObject.Create;
   Result.AddPair('CD_CAMPAIGN', DataSet.FieldByName('CD_CAMPAIGN').AsString );
   Result.AddPair('DS_CAMPAIGN', DataSet.FieldByName('DS_CAMPAIGN').AsString );
   Result.AddPair('COLOR'      , DataSet.FieldByName('COLOR'      ).AsInteger);
   Result.AddPair('SECTION'    , DataSet.FieldByName('SECTION'    ).AsString );
   Result.AddPair('NOTES'      , DataSet.FieldByName('NOTES'      ).AsString );
   Result.AddPair('IMG_LOGO'   , DataSet.FieldByName('IMG_LOGO'   ).AsString );
end;

function TTestCampaigns.GetCurrentJSONPlayer(DataSet :TWebClientDataSet): TJSONObject;
begin
   Result := TJSONObject.Create;
   Result.AddPair('CD_CAMPAIGN', DataSet.FieldByName('CD_CAMPAIGN').AsString );
   Result.AddPair('CD_USER'    , DataSet.FieldByName('CD_USER'    ).AsString );
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

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'SECTION';
   NewField.Size        := 12; // GAP_YEAR, ETURE, SCHOLARSHIP
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

function TTestCampaigns.GetDataSetPlayers:TWebClientDataSet;
var NewField :TField;

var Request    :TWebHttpRequest;
    Data       :TJSXMLHttpRequest;
    JSON       :TJSON;
    JSONObject :TJSONObject;
    DataToSend :TJSONObject;
    JSONArray  :TJSONArray;
    jo         :TJSONObject;
    i          :Integer;
    Counter    :Integer;

begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'CD_CAMPAIGN';
   NewField.Size        := 14; // Establecer el tamaño del campo
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'CD_USER';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   {-----------}
   {Create the data to be send to the server}
   {that includes the PageNumber requested  }
   (*Request := TMVCReq.CreateJSON_JSONRequest(TMVCReq.Host+'/players'+'/load');
   DataToSend := TJSONObject.Create;
   DataToSend.AddPair('PageNumber', 0);
   DataToSend.AddPair('SearchText', '');
   DataToSend.AddPair('OrderField', 'USERS.CD_USER');
   Request.PostData := DataToSend.ToString;

   Data := await(TJSXMLHttpRequest, Request.Perform);
   Assert.IsTrue(Data.Status = 200, 'Data.Status -> '+IntToStr(Data.Status));

   JSON       := TJSON.Create;
   JSONObject := TJSONObject(JSON.Parse(Data.ResponseText));
   JSONArray  := TJSONArray(JSONObject.GetValue('ROW'));

   Result.Active := True;
   {Check if an error exists }
   if JSONArray.Count = 1 then begin
      jo := TJSONObject(JSONArray.Items[0]);
   end;

   if JSONArray.Count > 4 then Counter := 5
   else Counter := JSONArray.Count;

   {The first row holds the NumberOfPages you can recover}
   jo := TJSONObject(JSONArray.Items[0]);
   for i := 1 to Counter do begin
      jo := TJSONObject(JSONArray.Items[i]);
      Result.Append;
      Result.FieldByName('CD_CAMPAIGN').AsString := 'TEST_DATA';
      Result.FieldByName('CD_USER'    ).AsString := jo.GetJSONValue('CD_USER');
      Result.Post;
   end;*)
end;

function TTestCampaigns.CreateDataSetCampaigns :TWebClientDataSet;
begin

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
   DataSet.FieldByName('SECTION'    ).AsString  := 'GAP_YEAR';
   DataSet.FieldByName('NOTES'      ).AsString  := 'Notes of test';
   DataSet.FieldByName('IMG_LOGO'   ).AsString  := 'Image loaded';
   DataSet.Post;

   (*Request := TMVCReq.CreatePOSTRequest(TMVCReq.Host+LocalPath+'/insert');
   Request.PostData := GetCurrentJSON(DataSet).ToString;

   Data := await(TJSXMLHttpRequest, Request.Perform);

   Assert.IsTrue(Data.Status = 200       , 'Data.Status   -> '+IntToStr(Data.Status));
   Assert.IsTrue(Data.ResponseText = 'OK', 'Data.Response -> '+Data.ResponseText);*)
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

    Color      :Integer;
begin
   {Create the data to be send to the server}
   {that includes the PageNumber requested  }
   (*Request := TMVCReq.CreateJSON_JSONRequest(TMVCReq.Host+LocalPath+'/load');
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
      DataSet.FieldByName('CD_CAMPAIGN').AsString  := jo.GetJSONValue('CD_CAMPAIGN');
      DataSet.FieldByName('DS_CAMPAIGN').AsString  := jo.GetJSONValue('DS_CAMPAIGN');
      TryStrToInt(jo.GetJSONValue('COLOR'), Color);
      DataSet.FieldByName('COLOR'      ).AsInteger := Color;
      DataSet.FieldByName('SECTION'    ).AsString  := jo.GetJSONValue('SECTION'    );
      DataSet.Post;
   end;*)
end;

procedure TTestCampaigns.GetOne(DataSet :TWebClientDataSet);
var Request    :TWebHttpRequest;
    Data       :TJSXMLHttpRequest;
    JSON       :TJSON;
    JSONObject :TJSONObject;
    DataToSend :TJSONObject;
    JSONArray  :TJSONArray;
    jo         :TJSONObject;

    Color      :Integer;
begin
   (*Request := TMVCReq.CreateJSON_JSONRequest(TMVCReq.Host+LocalPath+'/getone');
   DataToSend := TJSONObject.Create;
   DataToSend.AddPair('CD_CAMPAIGN', 'TEST_DATA');
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
      DataSet.FieldByName('CD_CAMPAIGN').AsString   := jo.GetJSONValue('CD_CAMPAIGN');
      DataSet.FieldByName('DS_CAMPAIGN').AsString   := jo.GetJSONValue('DS_CAMPAIGN');
      TryStrToInt(jo.GetJSONValue('COLOR'), Color);
      DataSet.FieldByName('COLOR'      ).AsInteger  := Color;
      DataSet.FieldByName('SECTION'    ).AsString   := jo.GetJSONValue('SECTION'    );
      DataSet.FieldByName('NOTES'      ).Value      := jo.GetJSONValue('NOTES'      );
      if jo.GetJSONValue('IMG_LOGO') = '' then DataSet.FieldByName('IMG_LOGO').Clear
      else DataSet.FieldByName('IMG_LOGO').AsString := jo.GetJSONValue('IMG_LOGO'   );
      DataSet.Post;
   end;*)
end;

procedure TTestCampaigns.TestUpdate;
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

   (*Request := TMVCReq.CreatePOSTRequest(TMVCReq.Host+LocalPath+'/update');
   Request.PostData := GetCurrentJSON(DataSet).ToString;

   Data := await(TJSXMLHttpRequest, Request.Perform);
   Assert.IsTrue(Data.Status = 200       , 'Data.Status   -> '+IntToStr(Data.Status));
   Assert.IsTrue(Data.ResponseText = 'OK', 'Data.Response -> '+Data.ResponseText);

   DataSet.EmptyDataSet;
   await(LoadIntoDataSet(DataSet));
   Assert.IsTrue(DataSet.FieldByName('DS_CAMPAIGN').AsString.Trim = 'Modified Row. Can be deleted', DataSet.FieldByName('DS_CAMPAIGN').AsString.Trim);*)
end;

function TTestCampaigns.TestDelete: Boolean;
var Request :TWebHttpRequest;
    Data    :TJSXMLHttpRequest;
    DataSet :TWebClientDataSet;
begin
   LocalPath := '/campaigns';

   DataSet := CreateDataSet;
   DataSet.Active := True;

   await(GetOne(DataSet));

   (*Request := TMVCReq.CreatePOSTRequest(TMVCReq.Host+LocalPath+'/delete');
   Request.PostData := GetCurrentJSON(DataSet).ToString;

   Data := await(TJSXMLHttpRequest, Request.Perform);
   Assert.IsTrue(Data.Status = 200       , 'Data.Status   -> '+IntToStr(Data.Status));
   Assert.IsTrue(Data.ResponseText = 'OK', 'Data.Response -> '+Data.ResponseText);

   DataSet.EmptyDataset;
   await(GetOne(DataSet));
   Assert.IsTrue(DataSet.IsEmpty, 'Has been deleted');*)
end;

procedure TTestCampaigns.TestLoad;
var DataSet :TWebClientDataSet;
begin
   LocalPath := '/campaigns';

   DataSet := CreateDataSet;
   DataSet.Active := True;

   await(LoadIntoDataSet(DataSet));

   Assert.IsTrue(DataSet.FieldByName('CD_CAMPAIGN').AsString = 'TEST_DATA', 'Load OK');
end;

function TTestCampaigns.TestIsReferenced(var TextMessage: string): Boolean;
begin

end;

{--- CAMPAIGN_PLAYERS ---}
procedure TTestCampaigns.TestInsertPlayer;
var Request     :TWebHttpRequest;
    Data        :TJSXMLHttpRequest;
    DataSet     :TWebClientDataSet;
    Players     :TWebClientDataSet;
    FirstPlayer :string;
    i           :Integer;
    JSONArray   :TJSONArray;
    JSON        :TJSON;
    JSONObject  :TJSONObject;
    jo          :TJSONObject;
    DataToSend  :TJSONObject;
begin
   LocalPath := '/campaigns';

   DataSet := CreateDataSet;
   DataSet.Active := True;

   DataSet.Append;
   DataSet.FieldByName('CD_CAMPAIGN').AsString  := 'TEST_DATA';
   DataSet.FieldByName('DS_CAMPAIGN').AsString  := 'TEST DATA, CAN BE DELETED';
   DataSet.FieldByName('COLOR'      ).AsInteger := 9999;
   DataSet.FieldByName('SECTION'    ).AsString  := 'GAP_YEAR';
   DataSet.FieldByName('NOTES'      ).AsString  := 'Notes of test';
   DataSet.FieldByName('IMG_LOGO'   ).AsString  := 'Image loaded';
   DataSet.Post;

   (*Request := TMVCReq.CreatePOSTRequest(TMVCReq.Host+LocalPath+'/insert');
   Request.PostData := GetCurrentJSON(DataSet).ToString;

   Data := await(TJSXMLHttpRequest, Request.Perform);

   Assert.IsTrue(Data.Status = 200       , 'Data.Status   -> '+IntToStr(Data.Status));
   Assert.IsTrue(Data.ResponseText = 'OK', 'Data.Response -> '+Data.ResponseText);

   {--- Insertion of players in this campaign ---}

   Players := await(TWebClientDataSet, GetDataSetPlayers);
   Assert.IsTrue(Players.RecordCount = 5, 'Five Users to Insert');

   Players.First;
   FirstPlayer := Players.FieldByName('CD_USER').AsString;

   while not Players.EOF do begin
      Request := TMVCReq.CreatePOSTRequest(TMVCReq.Host+LocalPath+'/insertplayer');
      Request.PostData := GetCurrentJSONPlayer(Players).ToString;

      Data := await(TJSXMLHttpRequest, Request.Perform);
      Assert.IsTrue(Data.Status = 200       , 'Data.Status   -> '+IntToStr(Data.Status));
      Assert.IsTrue(Data.ResponseText = 'OK', 'Data.Response -> '+Data.ResponseText);
      Players.Next;
   end;

   {--- Delete the first player in this campaign ---}
   Players.First;
   Request := TMVCReq.CreatePOSTRequest(TMVCReq.Host+LocalPath+'/deleteplayer');
   Request.PostData := GetCurrentJSONPlayer(Players).ToString;

   Data := await(TJSXMLHttpRequest, Request.Perform);
   Assert.IsTrue(Data.Status = 200       , 'Data.Status   -> '+IntToStr(Data.Status));
   Assert.IsTrue(Data.ResponseText = 'OK', 'Data.Response -> '+Data.ResponseText);
   Players.Delete;

   {--- Get Players ---}

   Players.EmptyDataSet;

   {Create the data to be send to the server}
   {that includes the PageNumber requested  }
   Request := TMVCReq.CreateJSON_JSONRequest(TMVCReq.Host+LocalPath+'/getplayers');
   DataToSend := TJSONObject.Create;
   DataToSend.AddPair('CD_CAMPAIGN', 'TEST_DATA');
   Request.PostData := DataToSend.ToString;

   Data := await(TJSXMLHttpRequest, Request.Perform);
   Assert.IsTrue(Data.Status = 200, 'Data.Status -> '+IntToStr(Data.Status));

   JSON       := TJSON.Create;
   JSONObject := TJSONObject(JSON.Parse(Data.ResponseText));
   JSONArray  := TJSONArray(JSONObject.GetValue('ROW'));

   Players.EmptyDataSet;
   {Check if an error exists }
   if JSONArray.Count = 1 then begin
      jo := TJSONObject(JSONArray.Items[0]);
   end;

   for i := 0 to JSONArray.Count - 1 do begin
      jo := TJSONObject(JSONArray.Items[i]);
      Players.Append;
      Players.FieldByName('CD_CAMPAIGN').AsString := jo.GetJSONValue('CD_CAMPAIGN');
      Players.FieldByName('CD_USER'    ).AsString := jo.GetJSONValue('CD_USER'    );
      Players.Post;
   end;

   Assert.IsTrue(Players.RecordCount = 4, 'Four users recovered');

   {--- Delete All players ---}
   Players.First;
   while not Players.EOF do begin
      Request := TMVCReq.CreatePOSTRequest(TMVCReq.Host+LocalPath+'/deleteplayer');
      Request.PostData := GetCurrentJSONPlayer(Players).ToString;

      Data := await(TJSXMLHttpRequest, Request.Perform);
      Assert.IsTrue(Data.Status = 200       , 'Data.Status   -> '+IntToStr(Data.Status));
      Assert.IsTrue(Data.ResponseText = 'OK', 'Data.Response -> '+Data.ResponseText);
      Players.Delete;
   end;

   Assert.IsTrue(Players.RecordCount = 0, 'All Users Deleted');

   {--- Delete CAMPAIGN ---}
   Request := TMVCReq.CreatePOSTRequest(TMVCReq.Host+LocalPath+'/delete');
   Request.PostData := GetCurrentJSON(DataSet).ToString;

   Data := await(TJSXMLHttpRequest, Request.Perform);
   Assert.IsTrue(Data.Status = 200       , 'Data.Status   -> '+IntToStr(Data.Status));
   Assert.IsTrue(Data.ResponseText = 'OK', 'Data.Response -> '+Data.ResponseText);

   DataSet.EmptyDataset;
   await(GetOne(DataSet));
   Assert.IsTrue(DataSet.IsEmpty, 'Has been deleted');*)
end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestCampaigns);
end.
