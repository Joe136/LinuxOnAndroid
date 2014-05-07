// See the file "license.terms" for information on usage and redistribution of
// this file, and for a DISCLAIMER OF ALL WARRANTIES.


//---------------------------Includes----------------------------------------------//
#include<stdio.h>
#include<unistd.h>
#include<stdlib.h>
#include<fcntl.h>
#include<sys/wait.h>
#include<sys/ioctl.h>
#include<linux/rtc.h>
#include "wallpaper-changer.h"
#include "argumenthandling.h"
#include "directoryhandling.h"
#include "randomhandling.h"



//---------------------------Global Variables--------------------------------------//
static bool  g_bRepeat = true;
static bool  g_bReload = false;
static bool  g_bNext   = false;
static bool  g_bStatus = false;
static FILE *g_oLog    = NULL;

#include "signalhandling.h"
#include "loghandling.h"



//---------------------------Start Main--------------------------------------------//
int main (int argc, const char *argv[], const char *envp[]) {

   // Catch Ctrl + C
   registerSignals ();


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

   if (m_oArguments.logfile)
      g_oLog = fopen (m_oArguments.logfile, "w");   //TODO check input first

   if (!m_oArguments.directory) {
      errMsg ("no directories defined");
      return 2;
   }

/*   if (m_oArguments.time < 20) {
      wrnMsg ("changing time to 20s (minimum)");
      m_oArguments.time = 20;
   }
*/

   /*------------------------Verbose Output----------------------------------------*/
   struct DirectoryEntity   *directory;

   if (m_oArguments.verbose >= 2) {
      printf ("directories: "); for (directory = m_oArguments.directory; directory != NULL; directory = directory->next) printf ("%s,", directory->name);
      printf ("\ntime: %u\n", m_oArguments.time);
      if (g_oLog) { fprintf (g_oLog, "wallpaper-changer: verbose: directories: "); for (directory = m_oArguments.directory; directory != NULL; directory = directory->next) fprintf (g_oLog, "%s,", directory->name); }
      if (g_oLog) fprintf (g_oLog, "\nwallpaper-changer: verbose: time: %u\n", m_oArguments.time);
   }


   /*------------------------Read Directories--------------------------------------*/
   struct ImageVectorEntity *vector     = NULL;
   struct ImageVectorEntity *vectorLast = NULL;

   readDirectories (&vector, m_oArguments.directory);

   /*------------------------Count accepted Images---------------------------------*/
   int sumImages = 0;
   countAcceptedImages (&sumImages, vector);

   if (m_oArguments.verbose >= 2) {
      int maxImages = 0;
      for (vectorLast = vector; vectorLast != NULL; vectorLast = vectorLast->next) {
         if (!vectorLast->vector.vector)
            continue;
         maxImages += vectorLast->vector.length;
      }//end for

      printf ("found images: %i\n", maxImages);
      printf ("accepted images: %i\n", sumImages);
      if (g_oLog) fprintf (g_oLog, "wallpaper-changer: verbose: found images: %i\n", maxImages);
      if (g_oLog) fprintf (g_oLog, "wallpaper-changer: verbose: accepted images: %i\n", sumImages);
   }

   if (sumImages <= 1) {
      errMsg ("not enough images to rotate (< 2)");
      return 3;
   }


   /*------------------------Create Image Random List------------------------------*/
   struct RandomListEntity *randomVector = NULL;
   long long oldLikelihood = 0;
   createRandomList (&randomVector, &oldLikelihood, vector, sumImages, m_oArguments.likelihood);


   /*------------------------Main Loop---------------------------------------------*/
   bool gosleep     = true;
   int reloadcount  = 0;
   long long random = 0;
   time_t begtime   = time (NULL);
   char command[1024];
   struct RandomListEntity *current = &randomVector[0];
   char *argv2[]    = {"/system/bin/mksh", "-c", NULL, NULL};

   srand (time(NULL) );
   logFlush ();


   while (g_bRepeat) {
      if (gosleep) {
         //sleep (m_oArguments.time);
         //sleep ( (m_oArguments.time > 300)?300:m_oArguments.time);   //TODO calculate sleep value in more intelligent way
         sleep ( (m_oArguments.time > 300)?300:(m_oArguments.time-difftime(time(NULL),begtime)) );   //TODO calculate sleep value in more intelligent way

         if (m_oArguments.verbose >= 3) { logMsg ("waked up"); logFlush (); }
      }

      if (!g_bRepeat)
         break;

      if (g_bReload) {
         if (m_oArguments.verbose >= 2) logMsg ("reload directories");

         free (randomVector); randomVector = NULL;

         for (vectorLast = vector; vectorLast != NULL; vectorLast = vectorLast->next) {
            cleanupImageVector (&vectorLast->vector);
         }//end for
         vector = NULL;

         readDirectories (&vector, m_oArguments.directory);
         countAcceptedImages (&sumImages, vector);

         if (sumImages <= 1) {
            errMsg ("not enough images to rotate (< 2)");
            return 4;
         }

         createRandomList (&randomVector, &oldLikelihood, vector, sumImages, m_oArguments.likelihood);

         reloadcount = 0;
         g_bReload   = false;
         gosleep     = true;
         continue;
      }

      if (g_bStatus) {
         logStatus ();
         logFlush ();
         g_bStatus = false;
      }

      if (!g_bNext && (difftime (time (NULL), begtime) < m_oArguments.time) ) {
         continue;
      }

      gosleep = true;
      g_bNext = false;


      random = randomValue (random, oldLikelihood);

      ++random;

      int n = sumImages - 1;
      int a = sumImages / 2 + 1;
      while (a >= 1) {
         if (randomVector[n-a].likelihood >= random) {
            n -= a;
         }

         if (a <= 2) {
            --a;
            continue;
         } else if (a%2)
            ++a;

         a /= 2;
      }//end while

      if (current == &randomVector[n]) {
         gosleep = false;
         continue;
      }

      current = &randomVector[n];


      strncpy (&current->vector->temp1[current->vector->temp2], current->vector->vector.vector[current->pos], 512 - current->vector->temp2);

      snprintf (command, 1024, "cp \"%s\" \"/data/data/com.android.settings/files/wallpaper\"", current->vector->temp1);

      argv2[2] = command;

      int pid;

      if (!(pid = fork() ) ) {
         if (g_oLog) { dup2 (fileno(g_oLog), fileno(stderr) ); /*dup2 (fileno(g_oLog), fileno(stdout) );*/ fclose (g_oLog); }
         execvp ("/system/bin/mksh", argv2);
         exit (1);
      }


      waitpid (pid, NULL, 0);

      time_t curr = time (NULL);
      if (begtime + m_oArguments.time <= curr)
         while ( (begtime += m_oArguments.time) < curr) ;

      if (m_oArguments.verbose >= 2) {
         printf ("set wallpaper: %s\n", current->vector->temp1);
         if (g_oLog) fprintf (g_oLog, "wallpaper-changer: log: set wallpaper: %s\n", current->vector->temp1);
      }

      if (++reloadcount >= m_oArguments.reloadmult) {   //TODO make this more dynamic
         g_bReload = true;
         gosleep   = false;
      }

      logFlush ();
   }//end while


   /*------------------------Cleanup-----------------------------------------------*/
   free (randomVector);
   for (vectorLast = vector; vectorLast != NULL; vectorLast = vectorLast->next) {
      cleanupImageVector (&vectorLast->vector);
   }//end for

   if (g_oLog) fclose (g_oLog);

   return 0;
}//end Main

