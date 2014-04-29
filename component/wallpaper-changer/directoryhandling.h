// See the file "license.terms" for information on usage and redistribution of
// this file, and for a DISCLAIMER OF ALL WARRANTIES.

#ifndef DIRECTORYHANDLING_H
#define DIRECTORYHANDLING_H

//---------------------------Includes----------------------------------------------//
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<dirent.h>
#include<sys/types.h>
#include<sys/stat.h>
//#include<unistd.h>

#include "wallpaper-changer.h"



//---------------------------Enum ConfigMode---------------------------------------//
#define ConfigMode int
#define UNKNOWN    0
#define LIKELIHOOD 1
#define DISABLE    2
#define CONFIG     3



//---------------------------Struct ImageVector------------------------------------//
struct ImageVector {
   char   **vector;
   int     *likelihood;
   size_t   length;
};//end struct



//---------------------------Struct FileEntity-------------------------------------//
struct FileEntity {
   char              *name;
   struct FileEntity *next;
};//end struct



//---------------------------Start parseDirectoryConfig----------------------------//
bool parseDirectoryConfig (struct ImageVector *vector, const char *dirname) {

   if (!dirname)
      return false;

   char        filename[512];
   char       *line = NULL;
   size_t      len  = 0;
   ssize_t     read;
   ConfigMode  mode     = LIKELIHOOD;
   ConfigMode  linemode = LIKELIHOOD;

   snprintf (filename, 512, "%s/.wallpaperrc", dirname);

   FILE *file = fopen (filename, "r");

   if (file) {

      while ( (read = getline(&line, &len, file) ) != -1) {
         int i = 0, n = 0, a = 0;
         bool comment = true;

         if (line[read-1] == '\n')
            --read;

         for (i = 0; i < read; ++i) {
            if (line[i] == ' ')
               continue;
            else if (line[i] == '#')
               break;
            else {
               comment = false;
               break;
            }
         }//end for

         if (comment)
            continue;

         if (line[i] >= '[' && line[read-1] <= ']') {
            if (!strncmp (&line[i+1], "likelihood", read - i - 2) ) {
               mode = LIKELIHOOD;
            } else if (!strncmp (&line[i+1], "disable", read - i - 2) ) {
               mode = DISABLE;
            } else if (!strncmp (&line[i+1], "config", read - i - 2) ) {
               mode = CONFIG;
            }

            continue;
         }

         if (mode == LIKELIHOOD) {   // Both supported, LIKELIHOOD and DISABLE
            linemode = UNKNOWN;

            for (n = i; n < read; ++n) {
               if (line[n] >= '0' && line[n] <= '9') {
                  linemode = LIKELIHOOD;
                  continue;
               } else if (line[n] == ' ') {
                  continue;
               } else {
                  if (n == i)
                     linemode = DISABLE;
                  break;
               }
            }//end for

            if (linemode == UNKNOWN)
               continue;

            for (a = 0; a < vector->length; ++a) {
               if (!strncmp (vector->vector[a], &line[n], read - n) ) {
                  if (!vector->likelihood) {
                     vector->likelihood = (int*) malloc (sizeof(int) * vector->length);
                     memset (vector->likelihood, -1, sizeof(int) * vector->length);
                  }

                  if (linemode == DISABLE)
                     vector->likelihood[a] = 0;
                  else if (linemode == LIKELIHOOD) {
                     line[n - 1] = 0;
                     vector->likelihood[a] = atoi (&line[i]);
                  }
               }
            }//end for

         } else if (mode == DISABLE) {
            for (a = 0; a < vector->length; ++a) {
               if (!strncmp (vector->vector[a], &line[i], read - i) ) {
                  if (!vector->likelihood) {
                     vector->likelihood = (int*) malloc (sizeof(int) * vector->length);
                     memset (vector->likelihood, -1, sizeof(int) * vector->length);
                  }

                  vector->likelihood[a] = 0;
               }
            }//end for

         } else if (mode == CONFIG) {
         }

      }//end while

      fclose (file);
      return true;
   }

   return false;
}//end Fct



//---------------------------Start parseDirectory----------------------------------//
bool parseDirectory (struct ImageVector *vector, const char *dirname) {

   if (!vector || !dirname)
      return false;

   DIR               *dir;
   struct dirent     *ent;
   size_t             length = 0;
   struct FileEntity  first;
   struct FileEntity *next   = NULL;
   struct FileEntity *last   = &first;

   if ( (dir = opendir (dirname) ) != NULL) {
      while ( (ent = readdir (dir) ) != NULL) {
         int len = strnlen (ent->d_name, 255);

         if (!strncmp (&ent->d_name[len-4], ".jpg", 5) ||
             !strncmp (&ent->d_name[len-5], ".jpeg", 6) ||
             !strncmp (&ent->d_name[len-4], ".png", 5) ) {

            last = last->next = (struct FileEntity*) malloc (sizeof (struct FileEntity) );
            last->name        = (char*) malloc (len + 1);

            strncpy (last->name, ent->d_name, len); last->name[len] = 0;
            last->next = NULL;
            ++length;
         }
      }

      closedir (dir);

      if (length == 0) {
         vector->vector = NULL;
         vector->length = 0;
         return true;
      }

      vector->vector     = (char**) malloc (sizeof (char*) * length );
      vector->likelihood = NULL;
      vector->length     = 0;

      for (next = first.next; next != NULL; next = last) {
         vector->vector[vector->length++] = next->name;
         last = next->next;
         free (next);
      }

      parseDirectoryConfig (vector, dirname);

      return true;
   }

   return false;
}



//---------------------------Start cleanupImageVector------------------------------//
bool cleanupImageVector (struct ImageVector *vector) {
   if (!vector)
      return false;

   if (vector->vector) {
      int i;
      for (i = 0; i < vector->length; ++i)
         free (vector->vector[i]);

      free (vector->vector);
   }

   if (vector->likelihood) {
      free (vector->likelihood);
   }

   return true;
}//end Fct

#endif //DIRECTORYHANDLING_H

