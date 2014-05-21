// See the file "license.terms" for information on usage and redistribution of
// this file, and for a DISCLAIMER OF ALL WARRANTIES.


//---------------------------Includes----------------------------------------------//
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<time.h>
#include<sys/types.h>
#include<sys/wait.h>
#include<sys/stat.h>
#include<signal.h>
#include<unistd.h>

#include "argumenthandling.h"



//---------------------------Defines-----------------------------------------------//
void nopSignal (int sigNr) {}



//---------------------------Start checkArguments----------------------------------//
int checkArguments (struct Arguments *args, int argc, const char *argv[], const char* envp[]) {
   int i = 0;


   if (args == NULL)
      return 0;

   for (i = 1; i < argc; ++i) {

      if ( (!strncmp (argv[i], "--level", 8) ) ) {
         args->getlevel = 1;

      }
      else if ( (i + 1 < argc) && (!strncmp (argv[i], "--log", 6) ) ) {
         ++i;
         args->logfile = argv[i];

      }
      else if ( (!strncmp (argv[i], "--quiet", 8) ) ) {
         args->verbose = 0;

      }
      else if ( (!strncmp (argv[i], "--verbose", 10) ) ) {
         ++args->verbose;

      }
      else if ( (!strncmp (argv[i], "-h", 3) ) || (!strncmp (argv[i], "--help", 7) ) ) {
         printf ("battery-notification " VERSION "\n");
         printf ("Control the battery level and alarm if empty\n");
         printf ("\n");
         printf ("Usage: battery-notification <options>\n");
         printf ("Options:\n");
         printf ("  -h | --help                Print this help\n");
         printf ("  --level                    Get the battery level and exit\n");
         printf ("  --log <logfile>            Set log file (only one file)\n");
         printf ("  --quiet                    Disables logging (except errors)\n");
         printf ("  --verbose                  Increases log level\n");
         printf ("\n");
/*         printf ("Examples:\n");
         printf ("Change WP every 6 hours: wallpaper-changer --time 6h --directory /mnt/sdcard/wallpaper --directory /mnt/sd...\n");
         printf ("Change WP now:           wallpaper-changer --next\n");
*/
         args->breakup = 1;
         return 1;

      }

   }//end for

   return 1;
}//end Fct

