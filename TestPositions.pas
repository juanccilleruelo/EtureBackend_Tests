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
    LocalPath :string;
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
  SysUtils;

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
   NewField.FieldName   := 'CD_POSITION_ES';
   NewField.Size        := 3;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'DS_POSITION_EN';
   NewField.Size        := 30;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'DS_POSITION_ES';
   NewField.Size        := 30;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TMemoField.Create(Result);
   NewField.FieldName   := 'IMG_ICON';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);
end;

procedure TTestPositions.TestGetAll;
var Request    :TWebHttpRequest;
    Data       :TJSXMLHttpRequest;
    JSON       :TJSON;
    JSONObject :TJSONObject;
    DataToSend :TJSONObject;
    JSONArray  :TJSONArray;
    jo         :TJSONObject;
    i          :integer;

var DataSet :TWebClientDataSet;
begin
   LocalPath := '/positions';

   DataSet := CreateDataSet;
   DataSet.Active := True;

   {Create the data to be send to the server}
   {that includes the PageNumber requested  }
   Request := TMVCReq.CreateJSON_JSONRequest(TMVCReq.Host+LocalPath+'/getall');
   DataToSend := TJSONObject.Create;
   Request.PostData := DataToSend.ToString;

   Data := await(TJSXMLHttpRequest, Request.Perform);
   Assert.IsTrue(Data.Status = 200, 'Data.Status -> '+IntToStr(Data.Status));

   JSON       := TJSON.Create;
   JSONObject := TJSONObject(JSON.Parse(Data.ResponseText));
   JSONArray  := TJSONArray(JSONObject.GetValue('ROW'));

   DataSet.EmptyDataSet;

   for i := 0 to JSONArray.Count - 1 do begin
      jo := TJSONObject(JSONArray.Items[i]);
      DataSet.Append;
      DataSet.FieldByName('CD_POSITION'   ).AsString := jo.GetJSONValue('CD_POSITION'   );
      DataSet.FieldByName('CD_POSITION_ES').AsString := jo.GetJSONValue('CD_POSITION_ES');
      DataSet.FieldByName('DS_POSITION_EN').AsString := jo.GetJSONValue('DS_POSITION_EN');
      DataSet.FieldByName('DS_POSITION_ES').AsString := jo.GetJSONValue('DS_POSITION_ES');
      DataSet.FieldByName('IMG_ICON'      ).AsString := jo.GetJSONValue('IMG_ICON'      );
      DataSet.Post;
   end;

   Assert.IsTrue(JSONArray.Count > 10, 'Recovered plus than 10');

end;

procedure TTestPositions.TestGetOne;
var Request    :TWebHttpRequest;
    Data       :TJSXMLHttpRequest;
    JSON       :TJSON;
    JSONObject :TJSONObject;
    DataToSend :TJSONObject;
    JSONArray  :TJSONArray;
    jo         :TJSONObject;

var DataSet :TWebClientDataSet;
begin
   LocalPath := '/positions';

   DataSet := CreateDataSet;
   DataSet.Active := True;

   Request := TMVCReq.CreateJSON_JSONRequest(TMVCReq.Host+LocalPath+'/getone');
   DataToSend := TJSONObject.Create;
   DataToSend.AddPair('CD_POSITION', 'LWB');
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
      DataSet.FieldByName('CD_POSITION'   ).AsString := jo.GetJSONValue('CD_POSITION'   );
      DataSet.FieldByName('CD_POSITION_ES').AsString := jo.GetJSONValue('CD_POSITION_ES');
      DataSet.FieldByName('DS_POSITION_EN').AsString := jo.GetJSONValue('DS_POSITION_EN');
      DataSet.FieldByName('DS_POSITION_ES').AsString := jo.GetJSONValue('DS_POSITION_ES');
      DataSet.FieldByName('IMG_ICON'      ).AsString := jo.GetJSONValue('IMG_ICON'      );
      DataSet.Post;
   end;

   Assert.IsTrue(JSONArray.Count = 1, 'Recovered Only one');
end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestPositions);
end.
