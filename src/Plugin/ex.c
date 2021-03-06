/*
    Apophysis Plugin

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
*/

typedef struct
{
	/* DEFINE VARIABLE NAMES HERE:
	   e.g. double pluginname_varname;
    */
} Variables;

#include "apoplugin.h"

/* SET PLUGIN NAME HERE:
   e.g. name-me
*/
APO_PLUGIN("ex");

APO_VARIABLES(
	/* DEFINE VARIABLES HERE:
       e.g. VAR_REAL(pluginname_varname, 1.0);
       Second parameter is default value
    */
);

/* DO PREPARE STUFF HERE:
   You must call the argument "vp"
*/
int PluginVarPrepare(Variation* vp)
{
    return TRUE; // Always return TRUE.
}

/* DO CALC STUFF HERE:
   You must call the argument "vp"
*/
int PluginVarCalc(Variation* vp)
{
    double FAngle = atan2(FTy, FTx);
    double r = sqrt(FTx*FTx+FTy*FTy);
    double n0 = sin(FAngle + r);
    double n1 = cos(FAngle - r);
    double m0 = sqr(n0) * n0;
    double m1 = sqr(n1) * n1;
    
    r = r * VVAR;
    FPx = FPx + r * (m0 + m1);
    FPy = FPy + r * (m0 - m1);

    return TRUE;
}
