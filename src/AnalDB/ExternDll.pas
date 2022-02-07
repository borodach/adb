unit ExternDll;

interface
uses ShareMem, db;

procedure getString (id: Pointer; //parser
buf: Pointer; //buffer
pos: Integer; //number of field
q: TDataSet; //query
var
st, //result
df, //differens
f0: String; //last value
cd: Integer //
);
stdcall; external 'FieldTypes.dll' name 'getString';

function getSize (
id: Pointer;
query: TDataSet;
io: Integer
): Integer;
stdcall; external 'FieldTypes.dll' name 'getSize';

procedure writeBuffer (id: Pointer;
bf: Pointer;
q: TDataSet;
io: Integer
);
stdcall; external 'FieldTypes.dll' name 'writeBuffer';

function createParser (_fields: Pointer;
_fieldsSize: Integer;
inFields: Pointer;
inCount: Integer;
outFields: Pointer;
outCount: Integer
): Pointer;
stdcall; external 'FieldTypes.dll' name 'createParser';

procedure destroyParser (inFields: Pointer);
stdcall; external 'FieldTypes.dll' name 'destroyParser';


implementation

end.


