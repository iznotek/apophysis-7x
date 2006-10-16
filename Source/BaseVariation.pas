unit BaseVariation;

interface

type
  TCalcFunction = procedure of object;

type
  TBaseVariation = class

  protected
    procedure CalcFunction; virtual; abstract;

  public
    vvar:  double;
    FTx, FTy: ^double;
    FPx, FPy: ^double;

    class function GetName: string; virtual; abstract;
    class function GetInstance: TBaseVariation; virtual; abstract;

    class function GetNrVariables: integer; virtual;
    class function GetVariableNameAt(const Index: integer): string; virtual;

    function GetVariable(const Name: string; var Value: double): boolean; virtual;
    function SetVariable(const Name: string; var Value: double): boolean; virtual;
    function ResetVariable(const Name: string): boolean; virtual;

    function GetVariableStr(const Name: string): string; virtual;
    function SetVariableStr(const Name: string; var strValue: string): boolean; virtual;

    procedure Prepare; virtual;

    procedure GetCalcFunction(var Delphi_Suxx: TCalcFunction); virtual;
  end;

  TBaseVariationClass = class of TBaseVariation;


implementation

uses SysUtils;

{ TBaseVariation }

///////////////////////////////////////////////////////////////////////////////
class function TBaseVariation.GetNrVariables: integer;
begin
  Result := 0;
end;

///////////////////////////////////////////////////////////////////////////////
function TBaseVariation.GetVariable(const Name: string; var value: double): boolean;
begin
  Result := False;
end;

function TBaseVariation.SetVariable(const Name: string; var value: double): boolean;
begin
  Result := False;
end;

function TBaseVariation.ResetVariable(const Name: string): boolean;
var
  zero: double;
begin
  zero := 0;
  Result := SetVariable(Name, zero);
end;

///////////////////////////////////////////////////////////////////////////////
function TBaseVariation.GetVariableStr(const Name: string): string;
var
  value: double;
begin
  if GetVariable(Name, value) then
    Result := Format('%.6g', [value])
  else
    Result := '';
end;

function TBaseVariation.SetVariableStr(const Name: string; var strValue: string): boolean;
var
  v, oldv: double;
begin
  if GetVariable(Name, oldv) then begin
    try
      v := StrToFloat(strValue);
      SetVariable(Name, v);
    except
      v := oldv;
    end;
    strValue := Format('%.6g', [v]);
    Result := true;
  end
  else Result := false;
end;

///////////////////////////////////////////////////////////////////////////////
class function TBaseVariation.GetVariableNameAt(const Index: integer): string;
begin
  Result := ''
end;

///////////////////////////////////////////////////////////////////////////////
procedure TBaseVariation.Prepare;
begin
end;

///////////////////////////////////////////////////////////////////////////////
procedure TBaseVariation.GetCalcFunction(var Delphi_Suxx: TCalcFunction);
begin
  Delphi_Suxx := CalcFunction;
end;

end.
