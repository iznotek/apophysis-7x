unit XFormMan;

interface

uses
  BaseVariation;

const
  NRLOCVAR = 29;

function NrVar: integer;
function Varnames(const index: integer): String;
procedure RegisterVariation(Variation: TBaseVariationClass);
function GetNrRegisteredVariations: integer;
function GetRegisteredVariation(const Index: integer): TBaseVariationClass;
function GetNrVariableNames: integer;
function GetVariableNameAt(const Index: integer): string;
function GetVariationIndex(const str: string): integer;

implementation

uses
  Classes;

var
  VariationList: TList;
  VariableNames: TStringlist;

///////////////////////////////////////////////////////////////////////////////
function NrVar: integer;
begin
  Result := NRLOCVAR + VariationList.Count;
end;

///////////////////////////////////////////////////////////////////////////////
function Varnames(const index: integer): String;
const
  cvarnames: array[0..NRLOCVAR-1] of string = (
    'linear',
    'sinusoidal',
    'spherical',
    'swirl',
    'horseshoe',
    'polar',
    'handkerchief',
    'heart',
    'disc',
    'spiral',
    'hyperbolic',
    'diamond',
    'ex',
    'julia',
    'bent',
    'waves',
    'fisheye',
    'popcorn',
    'exponential',
    'power',
    'cosine',
    'rings',
    'fan',
    'eyefish',
    'bubble',
    'cylinder',
    'noise',
    'blur',
    'gaussian_blur'
    );
begin
  if Index < NRLOCVAR then
    Result := cvarnames[Index]
  else
    Result := TBaseVariationClass(VariationList[Index - NRLOCVAR]).GetName;
end;

///////////////////////////////////////////////////////////////////////////////
function GetVariationIndex(const str: string): integer;
var
  i: integer;
begin
  i := NRVAR-1;
  while (i >= 0) and (Varnames(i) <> str) do Dec(i);
  Result := i;
end;

///////////////////////////////////////////////////////////////////////////////
procedure RegisterVariation(Variation: TBaseVariationClass);
var
  i: integer;
begin
  VariationList.Add(Variation);

  for i := 0 to Variation.GetNrVariables - 1 do
    VariableNames.Add(Variation.GetVariableNameAt(i))
end;

///////////////////////////////////////////////////////////////////////////////
function GetNrRegisteredVariations: integer;
begin
  Result := VariationList.count;
end;

///////////////////////////////////////////////////////////////////////////////
function GetRegisteredVariation(const Index: integer): TBaseVariationClass;
begin
  Result := TBaseVariationClass(VariationList[Index]);
end;

///////////////////////////////////////////////////////////////////////////////
function GetNrVariableNames: integer;
begin
  Result := VariableNames.Count;
end;

///////////////////////////////////////////////////////////////////////////////
function GetVariableNameAt(const Index: integer): string;
begin
  Result := VariableNames[Index];
end;

///////////////////////////////////////////////////////////////////////////////
initialization
  VariationList := TList.Create;
  VariableNames := TStringlist.create;
finalization
  VariableNames.Free;
  VariationList.Free;
end.
