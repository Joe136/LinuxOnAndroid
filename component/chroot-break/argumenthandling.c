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

/*      if ( (i + 1 < argc) && (!strncmp (argv[i], "--directory", 12) ) ) {
         ++i;
         struct DirectoryEntity *directory;
         struct stat stat_dir;

         // Check if argument is a directory
         if (stat (argv[i], &stat_dir) || (unsigned char)( (stat_dir.st_mode >> 12) & 0x7) != 4 ) {
            fprintf (stderr, "warning: directory defined in argument %i doesn't exist\n", i);
            continue;
         }

         if (!args->directory) {
            directory = args->directory = (struct DirectoryEntity*) malloc (sizeof (struct DirectoryEntity) );
         } else {
            for (directory = args->directory; directory->next != NULL; directory = directory->next) ;
            directory = directory->next = (struct DirectoryEntity*) malloc (sizeof (struct DirectoryEntity) );
         }

         directory->name = argv[i];
         directory->next = NULL;

      }
      else if ( (i + 1 < argc) && (!strncmp (argv[i], "--log", 6) ) ) {
         ++i;
         args->logfile = argv[i];

      }
      else if ( (!strncmp (argv[i], "--next", 7) ) ) {
         struct stat stat_dir;
         signal (SIGALRM, nopSignal);

         if (!stat ("/system/bin/mksh", &stat_dir) ) {
            // If Android
            char *argv2[] = {"/system/bin/mksh", "-c", "killall -14 wallpaper-changer", NULL};
            int pid;

            if (!(pid = fork() ) ) {
               execvp ("/system/bin/mksh", argv2);
               exit (1);
            } else {
               waitpid (pid, NULL, 0);
            }
         } else
            // If Linux
            system ("killall -14 wallpaper-changer");

         args->breakup = 1;
         return 1;

      }
      else if ( (!strncmp (argv[i], "--quiet", 8) ) ) {
         args->verbose = 0;

      }
      else if ( (i + 1 < argc) && (!strncmp (argv[i], "--reload", 9) ) ) {
         ++i;
         int n = atoi (argv[i]);
         if (n > 0)
            args->reloadmult = n;

      }
      else if ( (!strncmp (argv[i], "--status", 9) ) ) {
         struct stat stat_dir;
         signal (SIGUSR2, nopSignal);

         if (!stat ("/system/bin/mksh", &stat_dir) ) {
            // If Android
            char *argv2[] = {"/system/bin/mksh", "-c", "killall -12 wallpaper-changer", NULL};
            int pid;

            if (!(pid = fork() ) ) {
               execvp ("/system/bin/mksh", argv2);
               exit (1);
            } else {
               waitpid (pid, NULL, 0);
            }
         } else
            // If Linux
            system ("killall -12 wallpaper-changer");

         args->breakup = 1;
         return 1;

      }
      else if ( (i + 1 < argc) && (!strncmp (argv[i], "--time", 7) ) ) {
         ++i;
         int len = strnlen (argv[i], 10); --len;
         char temp1[10];

         for (n = 0; n < len; ++n) {
            if (argv[i][n] < '0' || argv[i][n] > '9') {
               fprintf (stderr, "error: wrong time format. Possible formats are <time>s|m|h|D|W|M|J . <time> must be a number\n");
               return 0;
            }
            temp1[n] = argv[i][n];
         }
         temp1[n] = 0;

         if (argv[i][len] == 's') {
            args->time = atoi (temp1);
         } else if (argv[i][len] == 'm') {
            args->time = atoi (temp1) * 60;
         } else if (argv[i][len] == 'h') {
            args->time = atoi (temp1) * 60 * 60;
         } else if (argv[i][len] == 'D') {
            args->time = atoi (temp1) * 60 * 60 * 24;
         } else if (argv[i][len] == 'W') {
            args->time = atoi (temp1) * 60 * 60 * 24 * 7;
         } else if (argv[i][len] == 'M') {
            args->time = atoi (temp1) * 60 * 60 * 24 * 31;
         } else if (argv[i][len] == 'Y') {
            args->time = atoi (temp1) * 60 * 60 * 24 * 365;
         } else {
            fprintf (stderr, "error: wrong time format. Possible formats are <time>s|m|h|D|W|M|J\n");
            return 0;
         }

      }
      else if ( (i + 1 < argc) && (!strncmp (argv[i], "--timeoffset", 13) ) ) {
         ++i;
         int n = atoi (argv[i]);
         if (n >= -12 && n <= 12)
            args->timeoffset = n * 60 * 60;

      }
      else if ( (!strncmp (argv[i], "--verbose", 10) ) ) {
         ++args->verbose;

      }
      else if ( (i + 1 < argc) && (!strncmp (argv[i], "--waitfirst", 12) ) ) {
         ++i;
         int n = atoi (argv[i]);
         if (n > 7200) n = 7200;
         sleep (n);

      }
      else*/ if ( (!strncmp (argv[i], "-h", 3) ) || (!strncmp (argv[i], "--help", 7) ) ) {
         printf ("chroot-break " VERSION "\n");
         printf ("Break out of a chroot environment\n");
         printf ("\n");
/*         printf ("Usage: chroot-break <options>\n");
         printf ("Options:\n");
         printf ("  -h | --help                Print this help\n");
         printf ("  --directory <directory>    Add directory to watched directories (starts the daemon mode)\n");
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

