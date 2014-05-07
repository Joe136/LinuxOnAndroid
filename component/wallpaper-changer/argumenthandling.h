// See the file "license.terms" for information on usage and redistribution of
// this file, and for a DISCLAIMER OF ALL WARRANTIES.

#ifndef ARGUMENTHANDLING_H
#define ARGUMENTHANDLING_H

//---------------------------Includes----------------------------------------------//
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<time.h>
#include<sys/types.h>
#include<sys/stat.h>
//#include<unistd.h>

#include "wallpaper-changer.h"



//---------------------------Struct DirectoryEntity--------------------------------//
struct DirectoryEntity {
   char const             *name;
   struct DirectoryEntity *next;
};//end struct



//---------------------------Struct Arguments--------------------------------------//
struct Arguments {
   struct DirectoryEntity *directory;
   size_t                  time;
   int                     likelihood;
   int                     verbose;
   char const             *logfile;
   int                     updatetime;
   bool                    breakup;
};//end struct



//---------------------------Start checkArguments----------------------------------//
bool checkArguments (struct Arguments *args, int argc, const char *argv[], const char* envp[]) {
   int i = 0, n = 0;


   if (args == NULL)
      return false;

   for (i = 1; i < argc; ++i) {

      if ( (!strncmp (argv[i], "--verbose", 10) ) ) {
         args->verbose = 2;

      }
      else if ( (!strncmp (argv[i], "--quiet",8) ) ) {
         args->verbose = 0;

      }
      else if ( (!strncmp (argv[i], "--next",7) ) ) {

         struct stat stat_dir;

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

         args->breakup = true;

         return true;

      }
      else if ( (i + 1 < argc) && (!strncmp (argv[i], "--waitfirst", 12) ) ) {
         ++i;
         int n = atoi (argv[i]);
         if (n > 7200) n = 7200;
         sleep (n);

      }
      else if ( (i + 1 < argc) && (!strncmp (argv[i], "--out", 6) ) ) {
         ++i;
         args->logfile = argv[i];

      }
      else if ( (i + 1 < argc) && (!strncmp (argv[i], "--directory", 12) ) ) {
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
      else if ( (i + 1 < argc) && (!strncmp (argv[i], "--time", 7) ) ) {
         ++i;
         int len = strnlen (argv[i], 10); --len;
         char temp1[10];

         for (n = 0; n < len; ++n) {
            if (argv[i][n] < '0' || argv[i][n] > '9') {
               fprintf (stderr, "error: wrong time format. Possible formats are <time>s|m|h|D|W|M|J . <time> must be a number\n");
               return false;
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
         } else if (argv[i][len] == 'J') {
            args->time = atoi (temp1) * 60 * 60 * 24 * 365;
         } else {
            fprintf (stderr, "error: wrong time format. Possible formats are <time>s|m|h|D|W|M|J\n");
            return false;
         }

      }

   }//end for

   return true;
}//end Fct

#endif //ARGUMENTHANDLING_H

