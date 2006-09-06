unit varPerspective;

interface

uses
  BaseVariation, XFormMan;

const
  var_a_name = 'perspective_angle';
  var_f_name = 'perspective_dist';

{$define _ASM_}

type
  TVariationPerspective = class(TBaseVariation)
  private
    angle, focus: double;
    vsin, vf, vfcos: double;

    procedure CalcLinear;

  public
    constructor Create;

    class function GetName: string; override;
    class function GetInstance: TBaseVariation; override;

    class function GetNrVariables: integer; override;
    class function GetVariableNameAt(const Index: integer): string; override;

    function SetVariable(const Name: string; var value: double): boolean; override;
    function GetVariable(const Name: string; var value: double): boolean; override;
    function ResetVariable(const Name: string): boolean; override;

    procedure Prepare; override;
    procedure CalcFunction; override;
    procedure GetCalcFunction(var f: TCalcFunction); override;
  end;

implementation

uses
  math;

// TVariationPerspective

///////////////////////////////////////////////////////////////////////////////
procedure TVariationPerspective.Prepare;
begin
  vsin := sin(angle*pi/2);
  vf := vvar * focus;
  vfcos := vf * cos(angle*pi/2);
end;

///////////////////////////////////////////////////////////////////////////////
procedure TVariationPerspective.GetCalcFunction(var f: TCalcFunction);
begin
  if IsZero(angle) then f := CalcLinear
  else f := CalcFunction;
end;

///////////////////////////////////////////////////////////////////////////////
procedure TVariationPerspective.CalcFunction;
{$if false}
var
  t: double;
begin
  t := (focus - vsin * FTy^);
  FPx^ := FPx^ + vf * FTx^ / t;
  FPy^ := FPy^ + vfcos * FTy^ / t;
{$else}
asm
    mov     ecx, [eax + FTy]
    fld     qword ptr [ecx]
    fld     st
    fmul    qword ptr [eax + vsin]
    fsubr   qword ptr [eax + focus]
    fld     st
    mov     ecx, [eax + FTx]
    fdivr   qword ptr [ecx]
    fmul    qword ptr [eax + vf]
    mov     ecx, [eax+FPx]
    fadd    qword ptr [ecx]
    fstp    qword ptr [ecx]
    fdivp   st(1), st
    fmul    qword ptr [eax + vfcos]
    mov     ecx, [eax+FPy]
    fadd    qword ptr [ecx]
    fstp    qword ptr [ecx]
    fwait
{$ifend}
end;

procedure TVariationPerspective.CalcLinear;
{$if false}
begin
  FPx^ := FPx^ + vvar * FTx^;
  FPy^ := FPy^ + vvar * FTy^;
{$else}
asm
    fld     qword ptr [eax + vvar]
    mov     edx, [eax + FTx]
    fld     qword ptr [edx]
    fmul    st, st(1)
    fadd    qword ptr [edx + 16]
    fstp    qword ptr [edx + 16]
    fld     qword ptr [edx + 8]
    fmulp
    fadd    qword ptr [edx + 24]
    fstp    qword ptr [edx + 24]
    fwait
{$ifend}
end;

///////////////////////////////////////////////////////////////////////////////
constructor TVariationPerspective.Create;
begin
  angle := random;
  focus := 2*random + 1;
end;

class function TVariationPerspective.GetInstance: TBaseVariation;
begin
  Result := TVariationPerspective.Create;
end;

///////////////////////////////////////////////////////////////////////////////
class function TVariationPerspective.GetName: string;
begin
  Result := 'perspective';
end;

///////////////////////////////////////////////////////////////////////////////
class function TVariationPerspective.GetVariableNameAt(const Index: integer): string;
begin
  case Index of
  0: Result := var_a_name;
  1: Result := var_f_name;
  else
    Result := '';
  end
end;

///////////////////////////////////////////////////////////////////////////////
function TVariationPerspective.SetVariable(const Name: string; var value: double): boolean;
begin
  Result := False;
  if Name = var_a_name then begin
    angle := Value;
    Result := True;
  end else if Name = var_f_name then begin
    focus := Value;
    Result := True;
  end
end;

function TVariationPerspective.ResetVariable(const Name: string): boolean;
begin
  Result := False;
  if Name = var_a_name then begin
    angle := 0;
    Result := True;
  end
  else if Name = var_f_name then begin
    focus := 2;
    Result := True;
  end;
end;

///////////////////////////////////////////////////////////////////////////////
class function TVariationPerspective.GetNrVariables: integer;
begin
  Result := 2;
end;

///////////////////////////////////////////////////////////////////////////////
function TVariationPerspective.GetVariable(const Name: string; var value: double): boolean;
begin
  Result := False;
  if Name = var_a_name then begin
    Value := angle;
    Result := True;
  end else if Name = var_f_name then begin
    Value := focus;
    Result := True;
  end
end;

///////////////////////////////////////////////////////////////////////////////
initialization
  RegisterVariation(TVariationPerspective);
end.
