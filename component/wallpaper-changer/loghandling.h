// See the file "license.terms" for information on usage and redistribution of
// this file, and for a DISCLAIMER OF ALL WARRANTIES.

#ifndef LOGHANDLING_H
#define LOGHANDLING_H

//---------------------------Includes----------------------------------------------//



//---------------------------Struct StatisticsConfig-------------------------------//
struct StatisticsConfig {
   struct Arguments          *arguments;
   struct ImageVectorEntity **vector;
   struct RandomListEntity  **current;
   int                       *sumImages;
   time_t                    *begtime;
};//end struct




//---------------------------Forward Declarations----------------------------------//
char* logStatus (struct StatisticsConfig *statistics, bool returnOnly);



//---------------------------Includes----------------------------------------------//
#include "argumenthandling.h"
#include "directoryhandling.h"
#include "randomhandling.h"




//---------------------------Start logMsg------------------------------------------//
void logMsg (const char *msg) {
   printf ("%s\n", msg);
   if (g_oLog) fprintf (g_oLog, "wallpaper-changer: log: %s\n", msg);
}//end Fct



//---------------------------Start wrnMsg------------------------------------------//
void wrnMsg (const char *msg) {
   fprintf (stderr, "warning: %s\n", msg);
   if (g_oLog) fprintf (g_oLog, "wallpaper-changer: warning: %s\n", msg);
}//end Fct



//---------------------------Start errMsg------------------------------------------//
void errMsg (const char *msg) {
   fprintf (stderr, "error: %s\n", msg);
   if (g_oLog) fprintf (g_oLog, "wallpaper-changer: error: %s\n", msg);
}//end Fct



//---------------------------Start logFlush----------------------------------------//
void logFlush () {
   fflush (stdout);
   fflush (stderr);
   if (g_oLog) fflush (g_oLog);
}//end Fct



//---------------------------Start logStatus---------------------------------------//
char* logStatus (struct StatisticsConfig *statistics, bool returnOnly) {
   if (!statistics) return NULL;

   char *message = (char*) malloc (4096);
   int   pos     = 0;

   struct DirectoryEntity   *directory;

   pos += snprintf (&message[pos], 4096, "wallpaper-changer: verbose: directories: "); for (directory = statistics->arguments->directory; directory != NULL; directory = directory->next) pos += snprintf (&message[pos], 4096, "%s,", directory->name);
   pos += snprintf (&message[pos], 4096, "\nwallpaper-changer: verbose: time: %u\n", statistics->arguments->time);


   struct ImageVectorEntity *vectorLast = NULL;
   int maxImages = 0;
   for (vectorLast = *statistics->vector; vectorLast != NULL; vectorLast = vectorLast->next) {
      if (!vectorLast->vector.vector)
         continue;
      maxImages += vectorLast->vector.length;
   }


   pos += snprintf (&message[pos], 4096, "wallpaper-changer: verbose: found images: %i\n", maxImages);
   pos += snprintf (&message[pos], 4096, "wallpaper-changer: verbose: accepted images: %i\n", *statistics->sumImages);
   pos += snprintf (&message[pos], 4096, "wallpaper-changer: verbose: current image: %s\n", (*statistics->current)->vector->temp1);


   time_t temp11 = statistics->arguments->time + *statistics->begtime + statistics->arguments->timeoffset; struct tm *temp10 = localtime (&temp11);
   pos += snprintf (&message[pos], 4096, "wallpaper-changer: verbose: next change: %.0fs (%4i-%02i-%02i %02i:%02i:%02i)\n", statistics->arguments->time - difftime (time(NULL), *statistics->begtime), temp10->tm_year + 1900, temp10->tm_mon, temp10->tm_mday, temp10->tm_hour, temp10->tm_min, temp10->tm_sec);


   if (returnOnly)
      return message;
   else {
      puts (message);
      if (g_oLog)  fputs (message, g_oLog);
      if (message) free (message);
      return NULL;
   }
}//end Fct

#endif //LOGHANDLING_H

