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

//---------------------------Global Variables--------------------------------------//
static bool  g_bCurrent = false;
static bool  g_bNext    = false;
static bool  g_bRepeat  = true;
static bool  g_bReload  = false;
static bool  g_bStatus  = false;
static bool  g_bTime    = false;
static FILE *g_oLog     = NULL;



//---------------------------Includes----------------------------------------------//
#include "loghandling.h"
#include "ipchandling.h"
#include "argumenthandling.h"
#include "directoryhandling.h"
#include "randomhandling.h"
#include "signalhandling.h"



//---------------------------Start Main--------------------------------------------//
int main (int argc, const char *argv[], const char *envp[]) {

   struct ServerConfig     sconfig;    memset (&sconfig,    0, sizeof (struct ServerConfig) );
   struct StatisticsConfig statistics; memset (&statistics, 0, sizeof (struct StatisticsConfig) );

   // Catch Ctrl + C
   registerSignals ();


   /*------------------------Read Arguments----------------------------------------*/
   struct Arguments m_oArguments;
   memset (&m_oArguments, 0, sizeof (struct Arguments) );

   m_oArguments.likelihood = 1;
   m_oArguments.verbose    = 1;
   m_oArguments.updatetime = 172800;   // two days
   m_oArguments.reloadmult = 5;
   statistics.arguments    = &m_oArguments;
   sconfig.statistics      = &statistics;

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

   if (m_oArguments.time < 20) {
      wrnMsg ("changing time to 20s (minimum)");
      m_oArguments.time = 20;
   }

   if (m_oArguments.selftest) {
      struct stat stat_dir;
      if (stat ("/data/data/com.android.settings/files/wallpaper", &stat_dir) )
         errMsg ("selftest: cannot find wallpaper file, changing wallpaper will not work");

      wrnMsg ("selftest: disable time");
      m_oArguments.time = 1;
   } else {
      openIPCServer  (&sconfig);
      startIPCServer (&sconfig);
   }


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
   bool gosleep         = true;
   int reloadcount      = 0;
   long long random     = 0;
   time_t begtime       = time (NULL);
   char command[1024];
   struct RandomListEntity *current = &randomVector[0];
   char *argv2[]       = {"/system/bin/mksh", "-c", NULL, NULL};
   int  *selfteststats = NULL; size_t sts = sumImages * 10; size_t stcount = 0; if (m_oArguments.selftest) { selfteststats = (int*)malloc (sts); memset (selfteststats, 0, sts); }

   statistics.vector    = &vector;
   statistics.current   = &current;
   statistics.sumImages = &sumImages;
   statistics.begtime   = &begtime;

   srand (time(NULL) );
   logFlush ();


   while (g_bRepeat) {
      if (gosleep) {
         //int temp1 = m_oArguments.time - difftime (time (NULL), begtime);
         //sleep (m_oArguments.time);
         //sleep ( (m_oArguments.time > 300)?300:m_oArguments.time);   //TODO calculate sleep value in more intelligent way
         sleep ( (m_oArguments.time > 300)?300:(m_oArguments.time-difftime(time(NULL),begtime)) );   //TODO calculate sleep value in more intelligent way
         //sleep ( (temp1 > 300)?300:temp1);   //TODO calculate sleep value in more intelligent way

         if (m_oArguments.verbose >= 3) { logMsg ("waked up"); logFlush (); }
      }

      if (g_bTime) {
         begtime = time (NULL);
         g_bTime = false;
         continue;
      }

      if (!g_bRepeat)
         break;

      if (g_bReload) {
         if (m_oArguments.verbose >= 2) logMsg ("reload directories");

         char temp3[512];
         strcpy (temp3, current->vector->vector.vector[current->pos]);
         size_t temp4 = strnlen (temp3, 512);
         current = NULL;

         free (randomVector); randomVector = NULL;

         for (vectorLast = vector; vectorLast != NULL; vectorLast = vectorLast->next) {
            cleanupImageVector (&vectorLast->vector);
         }//end for
         vector = NULL;

         readDirectories (&vector, m_oArguments.directory);
         countAcceptedImages (&sumImages, vector);

         if (sumImages <= 1) { errMsg ("not enough images to rotate (< 2)"); return 4; }

         createRandomList (&randomVector, &oldLikelihood, vector, sumImages, m_oArguments.likelihood);
         current = &randomVector[0];

         for (int i = 0; i < sumImages; ++i) {   // Restore 'current' reference
            if (!strncmp (randomVector[i].vector->vector.vector[randomVector[i].pos], temp3, temp4) ) {
               current = &randomVector[i];
               strncpy (&current->vector->temp1[current->vector->temp2], current->vector->vector.vector[current->pos], 512 - current->vector->temp2);
               break;
            }
         }//end for


         reloadcount = 0;
         g_bReload   = false;
         gosleep     = true;
         continue;
      }

      if (g_bStatus) {
         logStatus (&statistics, false);
         logFlush ();
         g_bStatus = false;
      }

      if (g_bCurrent) {
         if (argv2[2]) {
            int pid;

            if (!(pid = fork() ) ) {
               if (g_oLog) { dup2 (fileno(g_oLog), fileno(stderr) ); /*dup2 (fileno(g_oLog), fileno(stdout) );*/ fclose (g_oLog); }
               execvp ("/system/bin/mksh", argv2);
               exit (1);
            }

            if (m_oArguments.verbose >= 2) {
               printf ("set wallpaper (again): %s\n", current->vector->temp1);
               if (g_oLog) fprintf (g_oLog, "wallpaper-changer: log: set wallpaper (again): %s\n", current->vector->temp1);
            }

            waitpid (pid, NULL, 0);
         }

         g_bCurrent  = false;
         gosleep     = true;
         continue;
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

      if (!m_oArguments.selftest) {
         if (!(pid = fork() ) ) {
            if (g_oLog) { dup2 (fileno(g_oLog), fileno(stderr) ); /*dup2 (fileno(g_oLog), fileno(stdout) );*/ fclose (g_oLog); }
            execvp ("/system/bin/mksh", argv2);
            exit (1);
         }

         waitpid (pid, NULL, 0);
      }

      time_t curr = time (NULL);

      while (begtime + m_oArguments.time <= curr) {
         begtime += m_oArguments.time;
      }//end while


      if (m_oArguments.verbose >= 2) {
         printf ("set wallpaper: %s\n", current->vector->temp1);
         if (g_oLog) fprintf (g_oLog, "wallpaper-changer: log: set wallpaper: %s\n", current->vector->temp1);
      }

      if (m_oArguments.selftest) {
         if (n < sts)
            ++selfteststats[n];

         ++stcount;
         gosleep = false;
         g_bNext = true;
      }

      if (++reloadcount >= m_oArguments.reloadmult) {   //TODO make this more dynamic
         g_bReload = true;
         gosleep   = false;
      }

      logFlush ();
   }//end while


   /*------------------------Cleanup-----------------------------------------------*/
   if (selfteststats) {
      printf ("selftest:\n");
      if (g_oLog) fprintf (g_oLog, "wallpaper-changer: selftest:\n");

      int i, cmin = 0x7FFFFFFF, cmax = 0, pmin = 0, pmax = 0;
      for (i = 0; i < sumImages; ++i) {
         if (selfteststats[i] < cmin) { cmin = selfteststats[i]; pmin = i; }
         if (selfteststats[i] > cmax) { cmax = selfteststats[i]; pmax = i; }
         printf ("%i, %i, %i, %s\n", i, selfteststats[i], randomVector[i].vector->vector.likelihood[randomVector[i].pos], randomVector[i].vector->vector.vector[randomVector[i].pos]);
         if (g_oLog) fprintf (g_oLog, "%i, %i, %i, %s\n", i, selfteststats[i], randomVector[i].vector->vector.likelihood[randomVector[i].pos], randomVector[i].vector->vector.vector[randomVector[i].pos]);
      }//end for

      printf ("selftest: count of set images: %i\n", stcount);
      printf ("selftest: min set: %i, %i, %i, %s\n", pmin, cmin, randomVector[pmin].vector->vector.likelihood[randomVector[pmin].pos], randomVector[pmin].vector->vector.vector[randomVector[pmin].pos]);
      printf ("selftest: max set: %i, %i, %i, %s\n", pmax, cmax, randomVector[pmax].vector->vector.likelihood[randomVector[pmax].pos], randomVector[pmax].vector->vector.vector[randomVector[pmax].pos]);
      if (g_oLog) {
         fprintf (g_oLog, "wallpaper-changer: selftest: count of set images: %i\n", stcount);
         fprintf (g_oLog, "wallpaper-changer: selftest: min set: %i, %i, %i, %s\n", pmin, cmin, randomVector[pmin].vector->vector.likelihood[randomVector[pmin].pos], randomVector[pmin].vector->vector.vector[randomVector[pmin].pos]);
         fprintf (g_oLog, "wallpaper-changer: selftest: max set: %i, %i, %i, %s\n", pmax, cmax, randomVector[pmax].vector->vector.likelihood[randomVector[pmax].pos], randomVector[pmax].vector->vector.vector[randomVector[pmax].pos]);
      }

      free (selfteststats);
   }

   free (randomVector);
   for (vectorLast = vector; vectorLast != NULL; vectorLast = vectorLast->next) {
      cleanupImageVector (&vectorLast->vector);
   }//end for

   closeIPCServer (&sconfig);

   if (g_oLog) fclose (g_oLog);

   return 0;
}//end Main

