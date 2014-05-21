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
   struct Arguments arguments;
   memset (&arguments, 0, sizeof (struct Arguments) );

   arguments.verbose    = 1;

   if (!checkArguments (&arguments, argc, argv, envp) ) {
      return 1;
   }

   if (arguments.breakup)
      return 0;

   enum tResult res = breakChrootEnv ();

   if (res != NOERROR)
      return 2;

   setEnvParams ();


   if (arguments.begcommands) {
      if (execv (argv[arguments.begcommands], (char* const*)&argv[arguments.begcommands]) < 0) {
         printf("Failed to exec - %s\n", strerror(errno) );
         return ERR_UNDEFINED;   //TODO: Set a better error value
      }

      return NOERROR;
   } else
      return openShell ();
}//end Main

