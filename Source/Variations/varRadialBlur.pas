{
     Apophysis Copyright (C) 2001-2004 Mark Townsend
     Apophysis Copyright (C) 2005-2006 Ronald Hordijk, Piotr Borys, Peter Sdobnov
     Apophysis Copyright (C) 2007-2008 Piotr Borys, Peter Sdobnov
     
     Apophysis "3D hack" Copyright (C) 2007-2008 Peter Sdobnov
     Apophysis "7X" Copyright (C) 2009-2010 Georg Kiehne

     This program is free software; you can redistribute it and/or modify
     it under the terms of the GNU General Public License as published by
     the Free Software Foundation; either version 2 of the License, or
     (at your option) any later version.

     This program is distributed in the hope that it will be useful,
     but WITHOUT ANY WARRANTY; without even the implied warranty of
     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
     GNU General Public License for more details.

     You should have received a copy of the GNU General Public License
     along with this program; if not, write to the Free Software
     Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
}

unit varRadialBlur;

interface

uses
  BaseVariation, XFormMan, AsmRandom;

const
  var_name = 'radial_blur';
  var_a_name = 'radial_blur_angle';

{$define _ASM_}

type
  TVariationRadialBlur = class(TBaseVariation)
  private
    angle,
    spin_var, zoom_var: double;

    rnd: array[0..3] of double;
    N: integer;

    procedure CalcZoom;
    procedure CalcSpin;

  public
    constructor Create;

    class function GetName: string; override;
    class function GetInstance: TBaseVariation; override;

    function GetNrVariables: integer; override;
    function GetVariableNameAt(const Index: integer): string; override;

    function GetVariable(const Name: string; var value: double): boolean; override;
    function SetVariable(const Name: string; var value: double): boolean; override;
    function ResetVariable(const Name: string): boolean; override;

    procedure Prepare; override;
    procedure CalcFunction; override;
    procedure GetCalcFunction(var f: TCalcFunction); override;
  end;

implementation

uses
  math;

// TVariationRadialBlur

///////////////////////////////////////////////////////////////////////////////
constructor TVariationRadialBlur.Create;
begin
  angle := random * 2 - 1;
end;

procedure TVariationRadialBlur.Prepare;
begin
  spin_var := vvar * sin(angle * pi/2);
  zoom_var := vvar * cos(angle * pi/2);

  N := 0;
  rnd[0] := random;
  rnd[1] := random;
  rnd[2] := random;
  rnd[3] := random;
end;

///////////////////////////////////////////////////////////////////////////////
procedure TVariationRadialBlur.GetCalcFunction(var f: TCalcFunction);
begin
  if IsZero(spin_var) then f := CalcZoom
  else if IsZero(zoom_var) then f := CalcSpin
  else f := CalcFunction;
end;

///////////////////////////////////////////////////////////////////////////////
procedure TVariationRadialBlur.CalcFunction;
{$ifndef _ASM_}
var
  rndG, rz, ra: double;
  sina, cosa: extended;
begin
  rndG := (rnd[0] + rnd[1] + rnd[2] + rnd[3] - 2);
  rnd[N] := random;
  N := (N+1) and $3;

  ra := sqrt(sqr(FTx^) + sqr(FTy^));
  SinCos(arctan2(FTy^, FTx^) + spin_var * rndG, sina, cosa);
  rz := zoom_var * rndG - 1;

  FPx^ := FPx^ + ra * cosa + rz * FTx^;
  FPy^ := FPy^ + ra * sina + rz * FTy^;
{$else}
asm
    mov     edx, [eax + FTx]
    fld     qword ptr [edx + 8] // FTy
    fld     qword ptr [edx]     // FTx

    fld     st(1)
    fmul    st, st
    fld     st(1)
    fmul    st, st
    faddp
    fsqrt

    fld     st(2)
    fld     st(2)
    fpatan

    fld     qword ptr [eax + rnd]
    fadd    qword ptr [eax + rnd+8]
    fadd    qword ptr [eax + rnd+16]
    fadd    qword ptr [eax + rnd+24]
    fld1
    fsub    st(1), st
    fsub    st(1), st

    fld     st(1)
    fmul    qword ptr [eax + zoom_var]
    fsubrp

    fmul    st(4), st
    fmulp   st(5), st

    fmul    qword ptr [eax + spin_var]
    faddp

    call    AsmRandExt
    mov     edx, [eax + N]
    fstp    qword ptr [eax + rnd + edx*8]
    inc     edx
    and     edx,$03
    mov     [eax + N], edx

    fsincos

    fmul    st, st(2)
    faddp   st(3), st
    fmulp
    faddp   st(2), st
    mov     edx, [eax + FPx]
    fadd    qword ptr [edx]
    fstp    qword ptr [edx]
    fadd    qword ptr [edx + 8]
    fstp    qword ptr [edx + 8]
    fwait
{$endif}
end;

///////////////////////////////////////////////////////////////////////////////
procedure TVariationRadialBlur.CalcZoom;
{$ifndef _ASM_}
var
  r: double;
begin
  r := zoom_var * (rnd[0] + rnd[1] + rnd[2] + rnd[3] - 2);

  rnd[N] := random;
  N := (N+1) and $3;

  FPx^ := FPx^ + r * FTx^;
  FPy^ := FPy^ + r * FTy^;
{$else}
asm
    fld     qword ptr [eax + rnd]
    fadd    qword ptr [eax + rnd+8]
    fadd    qword ptr [eax + rnd+16]
    fadd    qword ptr [eax + rnd+24]
    fld1
    fadd    st, st
    fsubp   st(1), st
    fmul    qword ptr [eax + zoom_var]

    call    AsmRandExt
    mov     edx, [eax + N]
    fstp    qword ptr [eax + rnd + edx*8]
    inc     edx
    and     edx,$03
    mov     [eax + N], edx

    mov     edx, [eax + FTx]
    fld     qword ptr [edx + 8] // FTy
//    mov     ecx, [eax + FTx]
    fld     qword ptr [edx]

    fmul    st, st(2)
//    mov     edx, [eax + FPx]
    fadd    qword ptr [edx + 16]
    fstp    qword ptr [edx + 16]
    fmulp
//    mov     edx, [eax + FPy]
    fadd    qword ptr [edx + 24]
    fstp    qword ptr [edx + 24]
    fwait
{$endif}
end;

///////////////////////////////////////////////////////////////////////////////
procedure TVariationRadialBlur.CalcSpin;
{$ifndef _ASM_}
var
  r: double;
  sina, cosa: extended;
begin
  SinCos(arctan2(FTy^, FTx^) + spin_var * (rnd[0] + rnd[1] + rnd[2] + rnd[3] - 2),
         sina, cosa);
  r := sqrt(sqr(FTx^) + sqr(FTy^));

  rnd[N] := random;
  N := (N+1) and $3;

  FPx^ := FPx^ + r * cosa - FTx^;
  FPy^ := FPy^ + r * sina - FTy^;
{$else}
asm
    mov     edx, [eax + FTx]
//    mov     edx, [eax + FTy]
    fld     qword ptr [edx + 8]
//    mov     edx, [eax + FTx]
    fld     qword ptr [edx]
    fld     st(1)
    fld     st(1)
    fpatan

    fld     qword ptr [eax + rnd]
    fadd    qword ptr [eax + rnd+8]
    fadd    qword ptr [eax + rnd+16]
    fadd    qword ptr [eax + rnd+24]
    fld1
    fadd    st, st
    fsubp   st(1), st
    fmul    qword ptr [eax + spin_var]

    call    AsmRandExt
    mov     edx, [eax + N]
    fstp    qword ptr [eax + rnd + edx*8]
    inc     edx
    and     edx,$03
    mov     [eax + N], edx

    faddp
    fsincos

    fld     st(3)
    fmul    st,st
    fld     st(3)
    fmul    st,st
    faddp
    fsqrt
    fmul    st(2), st
    fmulp   st(1), st
    mov     edx, [eax + FPx]
    fadd    qword ptr [edx]
    fsubrp  st(2),st
//    mov     edx, [eax + FPy]
    fadd    qword ptr [edx + 8]
    fsubrp  st(2), st
    fstp    qword ptr [edx]
    fstp    qword ptr [edx + 8]
    fwait
{$endif}
end;

///////////////////////////////////////////////////////////////////////////////
class function TVariationRadialBlur.GetInstance: TBaseVariation;
begin
  Result := TVariationRadialBlur.Create;
end;

///////////////////////////////////////////////////////////////////////////////
class function TVariationRadialBlur.GetName: string;
begin
  Result := var_name;
end;

///////////////////////////////////////////////////////////////////////////////
function TVariationRadialBlur.GetVariableNameAt(const Index: integer): string;
begin
  case Index of
    0: Result := var_a_name;
  else
    Result := '';
  end
end;

///////////////////////////////////////////////////////////////////////////////
function TVariationRadialBlur.GetVariable(const Name: string; var value: double): boolean;
begin
  Result := False;
  if Name = var_a_name then begin
    Value := angle;
    Result := true;
  end;
end;

function TVariationRadialBlur.SetVariable(const Name: string; var value: double): boolean;
begin
  Result := False;
  if Name = var_a_name then begin
    angle := Value;
    Result := True;
  end;
end;

function TVariationRadialBlur.ResetVariable(const Name: string): boolean;
begin
  Result := False;
  if Name = var_a_name then begin
    if angle <> 0 then angle := 0
    else if angle = 0 then angle := 1;
    Result := True;
  end;
end;

///////////////////////////////////////////////////////////////////////////////
function TVariationRadialBlur.GetNrVariables: integer;
begin
  Result := 1;
end;

///////////////////////////////////////////////////////////////////////////////
initialization
  RegisterVariation(TVariationClassLoader.Create(TVariationRadialBlur), false, false);
end.