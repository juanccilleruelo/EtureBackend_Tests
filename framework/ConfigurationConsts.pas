unit ConfigurationConsts;

interface

const
   {$IFDEF DEBUG}
   BACKEND_HOST = 'http://192.168.10.146:8181';
   //BACKEND_HOST = 'http://200.234.231.180:8181';
   {$ELSE}
   BACKEND_HOST = 'http://200.234.231.180:8181';
   {$ENDIF}

implementation

end.
