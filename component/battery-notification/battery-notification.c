
//See the file "license.terms" for information on usage and redistribution of
//this file, and for a DISCLAIMER OF ALL WARRANTIES.


//---------------------------Includes----------------------------------------------//
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <string.h>
#include <stdio.h>

#include "argumenthandling.h"
#include "systemhandling.h"



//---------------------------Defines-----------------------------------------------//



//---------------------------Start Main--------------------------------------------//
int main (int argc, const char* argv[], const char* envp[]) {

   /*------------------------Read Arguments----------------------------------------*/
   struct Arguments m_oArguments;
   memset (&m_oArguments, 0, sizeof (struct Arguments) );

   m_oArguments.verbose    = 1;

   if (!checkArguments (&m_oArguments, argc, argv, envp) ) {
      return 1;
   }

   if (m_oArguments.breakup)
      return 0;


   breakChroot ();

   if (m_oArguments.getlevel) {
      int level = getBatteryLevel ();

      if (level >= 0)
         printf ("%i", level);
      else
         return level;

      return 0;
   }

   return 0;
}//end Main

