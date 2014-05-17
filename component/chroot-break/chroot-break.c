// See the file "license.terms" for information on usage and redistribution of
// this file, and for a DISCLAIMER OF ALL WARRANTIES.


//---------------------------Includes----------------------------------------------//
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>

#include "chroot-break.h"
#include "argumenthandling.h"



//---------------------------Defines-----------------------------------------------//



//---------------------------Start Main--------------------------------------------//
/* Break out of a chroot() environment in C */
int main (int argc, const char* argv[], const char* envp[]) {

   /*------------------------Read Arguments----------------------------------------*/
   struct Arguments m_oArguments;
   memset (&m_oArguments, 0, sizeof (struct Arguments) );

   m_oArguments.likelihood = 1;
   m_oArguments.verbose    = 1;
   m_oArguments.updatetime = 172800;   // two days
   m_oArguments.reloadmult = 5;

   if (!checkArguments (&m_oArguments, argc, argv, envp) ) {
      return 1;
   }

   if (m_oArguments.breakup)
      return 0;

   enum tResult res = breakChrootEnv ();

   if (res != NOERROR)
      return 2;

   setEnvParams ();

   return openShell ();
}//end Main

