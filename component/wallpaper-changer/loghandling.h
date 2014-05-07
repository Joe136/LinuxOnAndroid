// See the file "license.terms" for information on usage and redistribution of
// this file, and for a DISCLAIMER OF ALL WARRANTIES.

#ifndef LOGHANDLING_H
#define LOGHANDLING_H

//---------------------------Includes----------------------------------------------//



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



//---------------------------Defines-----------------------------------------------//
#define logStatus() \
         printf ("directories: "); for (directory = m_oArguments.directory; directory != NULL; directory = directory->next) printf ("%s,", directory->name); \
         printf ("\ntime: %u\n", m_oArguments.time); \
         if (g_oLog) { fprintf (g_oLog, "wallpaper-changer: verbose: directories: "); for (directory = m_oArguments.directory; directory != NULL; directory = directory->next) fprintf (g_oLog, "%s,", directory->name); } \
         if (g_oLog) fprintf (g_oLog, "\nwallpaper-changer: verbose: time: %u\n", m_oArguments.time); \
\
         int maxImages = 0; \
         for (vectorLast = vector; vectorLast != NULL; vectorLast = vectorLast->next) { \
            if (!vectorLast->vector.vector) \
               continue; \
            maxImages += vectorLast->vector.length; \
         } \
\
         printf ("found images: %i\n", maxImages); \
         printf ("accepted images: %i\n", sumImages); \
         if (g_oLog) fprintf (g_oLog, "wallpaper-changer: verbose: found images: %i\n", maxImages); \
         if (g_oLog) fprintf (g_oLog, "wallpaper-changer: verbose: accepted images: %i\n", sumImages); \
\
         time_t temp11 = m_oArguments.time + begtime; struct tm *temp10 = localtime (&temp11); \
         printf ("next change: %.0fs (%4i-%02i-%02i %02i:%02i:%02i)\n", m_oArguments.time - difftime (time(NULL), begtime), temp10->tm_year + 1900, temp10->tm_mon, temp10->tm_mday, temp10->tm_hour, temp10->tm_min, temp10->tm_sec); \
         if (g_oLog) fprintf (g_oLog, "wallpaper-changer: verbose: next change: %.0fs (%4i-%02i-%02i %02i:%02i:%02i)\n", m_oArguments.time - difftime (time(NULL), begtime),  temp10->tm_year + 1900, temp10->tm_mon, temp10->tm_mday, temp10->tm_hour, temp10->tm_min, temp10->tm_sec); \


#endif //LOGHANDLING_H

