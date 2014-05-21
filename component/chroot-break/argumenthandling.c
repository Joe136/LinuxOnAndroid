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

      if ( (i + 1 < argc) && (!strncmp (argv[i], "-c", 3) ) ) {
         ++i;
         args->begcommands = i;

      }
      else if ( (!strncmp (argv[i], "-h", 3) ) || (!strncmp (argv[i], "--help", 7) ) ) {
         printf ("chroot-break " VERSION "\n");
         printf ("Break out of a chroot environment\n");
         printf ("\n");
         printf ("Usage: chroot-break <options>\n");
         printf ("Options:\n");
         printf ("  -h | --help                Print this help\n");
         printf ("  -c                         The rest of the arguments is the command to execute\n");
/*         printf ("  --directory <directory>    Add directory to watched directories (starts the daemon mode)\n");
         printf ("  --log <logfile>            Set log file (only one file)\n");
         printf ("  --next                     Change the wallpaper now (needs running daemon)\n");
         printf ("  --quiet                    Disables logging (except errors)\n");
         printf ("  --reload <multiplicator>   Times of WP changes until reloading the directories\n");
         printf ("  --status                   Let the daemon print some infos\n");
         printf ("  --time <time>s|m|h|D|W|M|Y Time between WP changes (default: 2 days)\n");
         printf ("  --timeoffset <hour>        Offset for timestamps (-12 to 12)\n");
         printf ("  --verbose                  Increases log level\n");
         printf ("  --waitfirst <seconds>      Wait some time before starting (e.g. if directory is not mounted)\n");
         printf ("\n");
         printf ("Examples:\n");
         printf ("Change WP every 6 hours: wallpaper-changer --time 6h --directory /mnt/sdcard/wallpaper --directory /mnt/sd...\n");
         printf ("Change WP now:           wallpaper-changer --next\n");
*/
         args->breakup = 1;
         return 1;

      }

   }//end for

   return 1;
}//end Fct

