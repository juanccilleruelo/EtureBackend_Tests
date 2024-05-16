unit senCille.Miscellaneous;

interface

uses System.SysUtils, System.Classes, JS, Web,
     WEBLib.DB, WEBLib.Forms, WEBLib.Dialogs, WEBLib.Buttons,
     WEBLib.ExtCtrls, WEBLib.REST, WEBLib.CDS, Data.DB, WEBLib.DBCtrls, Vcl.StdCtrls, WEBLib.StdCtrls,
     WEBLib.ComCtrls, WEBLib.Grids, WebLib.JSON, Vcl.Controls,
     ConfigurationConsts;

const SEARCH_INTERVAL = 1500;

type
  TMessageType = (mtNone, mtWarn, mtInfo, mtError, mtSuccess, mtProgress, mtHelp);

  TMisc = class
    class function RandomNumber(Length :Integer):string;
    class function CheckPasswordStrength(const Password: string):Boolean;
    class function IsValidEmail(const email: string): Boolean;
    class procedure ShowMessage(const ASection :string; const AType :TMessageType; const AMessage :string);
    class procedure ClearMessage(const ASection :string);
    class procedure BlurStatus(Active :Boolean);
  end;

implementation

{ TMVCReq }

class function TMisc.RandomNumber(Length :Integer):string;
var i :Integer;
begin
   Result := '';
   for i := 1 to Length do begin
      Result := Result + IntToStr(Random(10)); { Generate a random digit (0-9) and append it to the result }
   end;
end;

class procedure TMisc.ShowMessage(const ASection :string; const AType :TMessageType; const AMessage :string);
var Element :TJSHTMLElement;
begin
   {Localizar el sitio y poner el HTML}
   Element := Document.GetHTMLElementById(ASection);
   case AType of
      mtWarn  :Element.InnerHTML :=
                  Format('<div class="alert alert-warning" role="alert">                      '+
                         '   <div class="row">                                              '+
                         '      <div class="form-group col-lg-9">                           '+
                         '         <label class="form-label">%s</label>                     '+
                         '      </div>                                                      '+
                         '   </div>                                                         '+
                         '</div>                                                            ',
                         [AMessage]);
      mtInfo  :Element.InnerHTML :=
                  Format('<div class="alert alert-light" role="alert">                      '+
                         '   <div class="row">                                              '+
                         '      <div class="form-group col-lg-9">                           '+
                         '         <label class="form-label">%s</label>                     '+
                         '      </div>                                                      '+
                         '   </div>                                                         '+
                         '</div>                                                            ',
                         [AMessage]);
      mtError :Element.InnerHTML :=
                  Format('<div class="alert alert-danger" role="alert">                     '+
                         '   <div class="row">                                              '+
                         '      <div class="spinner-grow text-danger" role="status"> </div> '+
                         '      <div class="form-group col-lg-9">                           '+
                         '         <label class="form-label">%s</label>                     '+
                         '      </div>                                                      '+
                         '   </div>                                                         '+
                         '</div>                                                            ',
                         [AMessage]);
      mtSuccess:Element.InnerHTML :=
                 Format('<div class="alert alert-success" role="alert">                      '+
                         '   <div class="row">                                              '+
                         '      <div class="form-group col-lg-9">                           '+
                         '         <label class="form-label">%s</label>                     '+
                         '      </div>                                                      '+
                         '   </div>                                                         '+
                         '</div>                                                            ',
                         [AMessage]);
      mtProgress:Element.InnerHTML :=
                  Format('<div class="alert alert-secondary" role="alert">                      '+
                         '   <div class="row">                                              '+
                         '      <div class="form-group col-lg-9">                           '+
                         '         <label class="form-label">%s</label>                     '+
                         '      </div>                                                      '+
                         '   </div>                                                         '+
                         '</div>                                                            ',
                         [AMessage]);
      mtHelp  :Element.InnerHTML :=
                  Format('<div class="alert alert-info" role="alert">                      '+
                         '   <div class="row">                                              '+
                         '      <div class="form-group col-lg-9">                           '+
                         '         <label class="form-label">%s</label>                     '+
                         '      </div>                                                      '+
                         '   </div>                                                         '+
                         '</div>                                                            ',
                         [AMessage]);
   end;
end;

class procedure TMisc.ClearMessage(const ASection :string);
var Element :TJSHTMLElement;
begin
   Element := Document.GetHTMLElementById(ASection);
   if Element <> nil then Element.InnerHTML := '';
end;

class procedure TMisc.BlurStatus(Active :Boolean);
var Element :TJSHTMLElement;
begin
   Element := Document.GetHTMLElementById('PageBodyWrapper');
   {classList contains a list of all the elements in the class attribute of the HTML element.}
   if Active then Element.SetAttribute('style', 'filter: blur(5px);')
   else Element.removeAttribute('style');
end;

class function TMisc.CheckPasswordStrength(const Password: string):Boolean;
type TCharType = (ctUpperCase, ctLowerCase, ctNumber);
//const SpecialChars = ['!', '@', '#', '$', '%', '_'];
var CharType         :TCharType;
    CharCode         :Integer;
    CharCount        :array[TCharType] of Boolean;
    //SpecialCharFound :Boolean;
begin
   {$IFDEF DEBUG}
     Result := True;
     Exit;
   {$ENDIF}

   { Initialize counters }
   for CharType := Low(TCharType) to High(TCharType) do begin
      CharCount[CharType] := False;
   end;

   //SpecialCharFound := False;

   { Check Minimum length }
   if Length(Password) < 8 then Exit(False);

   { Check the characters }
   for CharCode := 1 to Length(Password) do begin
      if Password[CharCode] in ['A'..'Z'] then CharCount[ctUpperCase] := True else
      if Password[CharCode] in ['a'..'z'] then CharCount[ctLowerCase] := True else
      if Password[CharCode] in ['0'..'9'] then CharCount[ctNumber   ] := True;
      //if Password[CharCode] in SpecialChars then SpecialCharFound       := True;
   end;

   { Check that all the contitions are correct }
   Result := CharCount[ctUpperCase] and CharCount[ctLowerCase] and CharCount[ctNumber]; // and SpecialCharFound;
end;

class function TMisc.IsValidEmail(const email: string): Boolean;
var Regex :TJSRegExp;
begin
  Regex  := TJSRegExp.New('^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  Result := Regex.Test(Email);
end;

initialization
  Randomize; { Initialize the random number generator }
end.
