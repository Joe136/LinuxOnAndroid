// See the file "license.terms" for information on usage and redistribution of
// this file, and for a DISCLAIMER OF ALL WARRANTIES.

#ifndef CHROOTBREAK_H
#define CHROOTBREAK_H


//---------------------------Includes----------------------------------------------//



//---------------------------Defines-----------------------------------------------//
enum tResult {
  NOERROR = 0,

  // Errors
  ERR_UNDEFINED = -1,

  // Warnings
  WRN_UNDEFINED = 1
};//end enum



//---------------------------Forward Declarations----------------------------------//
enum tResult breakChrootEnv ();
void setEnvParams ();
enum tResult openShell ();


#include "chroot-break.inl"

#endif
