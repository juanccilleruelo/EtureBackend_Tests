unit senCille.MVCRequests;

interface

uses System.SysUtils, System.Classes, JS, Web,
     WEBLib.DB, WEBLib.Forms, WEBLib.Dialogs, WEBLib.Buttons,
     WEBLib.ExtCtrls, WEBLib.REST, WEBLib.CDS, Data.DB, WEBLib.DBCtrls, Vcl.StdCtrls, WEBLib.StdCtrls,
     WEBLib.ComCtrls, WEBLib.Grids, WebLib.JSON, Vcl.Controls,
     ConfigurationConsts;

type
  TMVCReq = class
    class function Host:string;
    class function GetDataStatusMsg(Value :Integer):string; {Return the error status text for the returned code by a Request method}
    class function CreateGETRequest (AURL :string):TWebHttpRequest;
    class function CreatePOSTRequest(AURL :string):TWebHttpRequest;
    //class function CreateLOADRequest(AURL :string):TWebHttpRequest;
    class function CreateJSON_JSONRequest(AURL :string):TWebHttpRequest;
  end;

implementation

{ TMVCReq }

class function TMVCReq.Host:string;
begin
   Result := BACKEND_HOST;
end;

class function TMVCReq.GetDataStatusMsg(Value :Integer):string;
begin
   case Value of
      201 : Result := '201 Created'               ;
      202 : Result := '202 Accepted'              ;
      203 : Result := '203 No Content'            ;
      204 : Result := '204 Reset Content'         ;
      206 : Result := '206 Partial Content'       ;

      400 : Result := '400 Bad Request'           ;
      401 : Result := '401 Unauthorized'          ;
      403 : Result := '403 Forbidden'             ;
      404 : Result := '404 Not found'             ;
      405 : Result := '405 Method Not Allowed'    ;
      406 : Result := '406 Not Acceptable'        ;
      408 : Result := '408 Request Timeout'       ;
      409 : Result := '409 Conflict'              ;
      410 : Result := '410 Gone'                  ;
      411 : Result := '411 Length Required'       ;
      415 : Result := '415 Unsupported Media Type';

      500 : Result := '500 Internal Server Error' ;
      501 : Result := '501 Not Implemented'       ;
      503 : Result := '503 Service Unavailable'   ;
      else Result := IntToStr(Value) + ' : Unknow error';
   end;
end;

class function TMVCReq.CreateGETRequest(AURL :string):TWebHttpRequest;
begin
   { Create the Request object for communicate with the server }
   Result := TWebHttpRequest.Create(nil);
   Result.Headers.Clear;
   Result.Command      := httpGET;
   Result.ResponseType := rtText;
   Result.TimeOut      := 3000;
   Result.Headers.AddPair('Content-Type', 'text/plain');
   Result.Headers.AddPair('Accept'      , 'application/json');
   { Add Basic Authorization }
   //Request.Headers.AddPair('Authorization', 'Basic '+window.btoa(USERNAME_2 + ':' + PASSWORD_2));
   Result.URL := AURL;
end;

class function TMVCReq.CreatePOSTRequest(AURL :string):TWebHttpRequest;
begin
   { Create the Request object for communicate with the server }
   Result := TWebHttpRequest.Create(nil);
   Result.Headers.Clear;
   Result.Command      := httpPOST;
   Result.ResponseType := rtText;
   Result.TimeOut      := 3000;
   Result.Headers.AddPair('Content-Type', 'application/json');
   Result.Headers.AddPair('Accept'      , 'text/plain');
   { Add Basic Authorization }
   //Request.Headers.AddPair('Authorization', 'Basic '+window.btoa(USERNAME_2 + ':' + PASSWORD_2));
   Result.URL := AURL;
end;

(*class function TMVCReq.CreateLOADRequest(AURL :string):TWebHttpRequest;
begin
   { Create the Request object for communicate with the server }
   Result := TWebHttpRequest.Create(nil);
   Result.Headers.Clear;
   Result.Command      := httpPOST;
   Result.ResponseType := rtText;
   Result.TimeOut      := 3000;
   Result.Headers.AddPair('Content-Type', 'application/json');
   Result.Headers.AddPair('Accept'      , 'application/json');
   { Add Basic Authorization }
   //Request.Headers.AddPair('Authorization', 'Basic '+window.btoa(USERNAME_2 + ':' + PASSWORD_2));
   Result.URL := AURL;
end;*)

class function TMVCReq.CreateJSON_JSONRequest(AURL :string):TWebHttpRequest;
begin
   { Create the Request object for communicate with the server }
   Result := TWebHttpRequest.Create(nil);
   Result.Headers.Clear;
   Result.Command      := httpPOST;
   Result.ResponseType := rtText;
   Result.TimeOut      := 3000;
   Result.Headers.AddPair('Content-Type', 'application/json');
   Result.Headers.AddPair('Accept'      , 'application/json');
   { Add Basic Authorization }
   //Request.Headers.AddPair('Authorization', 'Basic '+window.btoa(USERNAME_2 + ':' + PASSWORD_2));
   Result.URL := AURL;
end;


end.
