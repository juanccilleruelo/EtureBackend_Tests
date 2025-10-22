unit TestParents;

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
  TTestParents = class(TObject)
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

{ TTestParents }

constructor TTestParents.Create;
begin
   inherited;
   {Place where initialize de Dataset when we use it.}
end;

function TTestParents.CreateDataSet:TWebClientDataSet;
var NewField :TField;
begin
   inherited;
   Result := TWebClientDataSet.Create(nil);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'CD_USER';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'EMAIL';
   NewField.Size        := 100;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TDateTimeField.Create(Result);
   NewField.FieldName   := 'CREATED';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'DS_USER';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'ADDRESS_LN_1';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'ADDRESS_LN_2';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'CITY';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'POSTAL_CODE';
   NewField.Size        := 15;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'PROVINCE';
   NewField.Size        := 50;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'STATE';
   NewField.Size        := 40;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'COUNTRY';
   NewField.Size        := 40;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'PHONE_NUMBER';
   NewField.Size        := 20;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TStringField.Create(Result);
   NewField.FieldName   := 'PREFERED_LANGUAGE';
   NewField.Size        := 2;
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);

   NewField := TMemoField.Create(Result);
   NewField.FieldName   := 'NOTES';
   NewField.DataSet     := Result;
   Result.FieldDefs.Add(NewField.FieldName, ftString, NewField.Size);
end;

procedure TTestParents.TestGetAll;
var Request    :TWebHttpRequest;
    Data       :TJSXMLHttpRequest;
    JSON       :TJSON;
    JSONObject :TJSONObject;
    DataToSend :TJSONObject;
    JSONArray  :TJSONArray;
    jo         :TJSONObject;
    i          :integer;

var DataSet :TWebClientDataSet;

    US         :TFormatSettings;
begin
   US := TFormatSettings.Create('en-US');
   US.ShortDateFormat := 'MM/DD/YYYY';

   LocalPath := '/parents';

   DataSet := CreateDataSet;

   DataSet.Active := True;

   {Create the data to be send to the server}
   {that includes the PageNumber requested  }
   (*Request := TMVCReq.CreateJSON_JSONRequest(TMVCReq.Host+LocalPath+'/getall');
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
      DataSet.FieldByName('CD_USER'          ).AsString   := jo.GetJSONValue('CD_USER'          );
      DataSet.FieldByName('EMAIL'            ).AsString   := jo.GetJSONValue('EMAIL'            );
      DataSet.FieldByName('CREATED'          ).AsDateTime := StrToDateTime(jo.GetJSONValue('CREATED'), US);
      DataSet.FieldByName('DS_USER'          ).AsString   := jo.GetJSONValue('DS_USER'          );
      DataSet.FieldByName('ADDRESS_LN_1'     ).AsString   := jo.GetJSONValue('ADDRESS_LN_1'     );
      DataSet.FieldByName('ADDRESS_LN_2'     ).AsString   := jo.GetJSONValue('ADDRESS_LN_2'     );
      DataSet.FieldByName('CITY'             ).AsString   := jo.GetJSONValue('CITY'             );
      DataSet.FieldByName('POSTAL_CODE'      ).AsString   := jo.GetJSONValue('POSTAL_CODE'      );
      DataSet.FieldByName('PROVINCE'         ).AsString   := jo.GetJSONValue('PROVINCE'         );
      DataSet.FieldByName('STATE'            ).AsString   := jo.GetJSONValue('STATE'            );
      DataSet.FieldByName('COUNTRY'          ).AsString   := jo.GetJSONValue('COUNTRY'          );
      DataSet.FieldByName('PHONE_NUMBER'     ).AsString   := jo.GetJSONValue('PHONE_NUMBER'     );
      DataSet.FieldByName('PREFERED_LANGUAGE').AsString   := jo.GetJSONValue('PREFERED_LANGUAGE');
      DataSet.Post;
   end;

   Assert.IsTrue(JSONArray.Count > 10, 'Recovered plus than 10');*)

end;

procedure TTestParents.TestGetOne;
var Request    :TWebHttpRequest;
    Data       :TJSXMLHttpRequest;
    JSON       :TJSON;
    JSONObject :TJSONObject;
    DataToSend :TJSONObject;
    JSONArray  :TJSONArray;
    jo         :TJSONObject;

var DataSet :TWebClientDataSet;
begin
   LocalPath := '/parents';

   DataSet := CreateDataSet;
   DataSet.Active := True;

   (*Request := TMVCReq.CreateJSON_JSONRequest(TMVCReq.Host+LocalPath+'/getone');
   DataToSend := TJSONObject.Create;
   DataToSend.AddPair('Language', 'EN');
   DataToSend.AddPair('CD_USER', 'LWB');
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
      DataSet.FieldByName('CD_USER'          ).AsString := jo.GetJSONValue('CD_USER'          );
      DataSet.FieldByName('EMAIL'            ).AsString := jo.GetJSONValue('EMAIL'            );
      DataSet.FieldByName('CREATED'          ).AsString := jo.GetJSONValue('CREATED'          );
      DataSet.FieldByName('DS_USER'          ).AsString := jo.GetJSONValue('DS_USER'          );
      DataSet.FieldByName('ADDRESS_LN_1'     ).AsString := jo.GetJSONValue('ADDRESS_LN_1'     );
      DataSet.FieldByName('ADDRESS_LN_2'     ).AsString := jo.GetJSONValue('ADDRESS_LN_2'     );
      DataSet.FieldByName('CITY'             ).AsString := jo.GetJSONValue('CITY'             );
      DataSet.FieldByName('POSTAL_CODE'      ).AsString := jo.GetJSONValue('POSTAL_CODE'      );
      DataSet.FieldByName('PROVINCE'         ).AsString := jo.GetJSONValue('PROVINCE'         );
      DataSet.FieldByName('STATE'            ).AsString := jo.GetJSONValue('STATE'            );
      DataSet.FieldByName('COUNTRY'          ).AsString := jo.GetJSONValue('COUNTRY'          );
      DataSet.FieldByName('PHONE_NUMBER'     ).AsString := jo.GetJSONValue('PHONE_NUMBER'     );
      DataSet.FieldByName('PREFERED_LANGUAGE').AsString := jo.GetJSONValue('PREFERED_LANGUAGE');
      DataSet.Post;
   end;

   Assert.IsTrue(JSONArray.Count = 1, 'Recovered Only one');*)
end;

initialization
   TTMSWEBUnitTestingRunner.RegisterClass(TTestParents);
end.
