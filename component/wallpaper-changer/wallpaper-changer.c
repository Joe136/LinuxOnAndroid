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
static bool g_bRepeat = true;
static bool g_bReload = false;
static bool g_bNext   = false;

#include "signalhandling.h"



//---------------------------Start Main--------------------------------------------//
int main (int argc, const char *argv[], const char *envp[]) {

   // Catch Ctrl + C
   registerSignals ();


   /*------------------------Read Arguments----------------------------------------*/
   struct Arguments m_oArguments;

   m_oArguments.directory  = NULL;
   m_oArguments.time       = 0;
   m_oArguments.likelihood = 1;
   m_oArguments.verbose    = 1;
   m_oArguments.logfile    = NULL;
   m_oArguments.breakup    = false;
   m_oArguments.updatetime = 172800;   // two days

   if (!checkArguments (&m_oArguments, argc, argv, envp) ) {
      return 1;
   }

   if (m_oArguments.breakup)
      return 0;

   FILE *log = NULL;
   if (m_oArguments.logfile)
      log = fopen (m_oArguments.logfile, "w");   //TODO check input first

   if (!m_oArguments.directory) {
      fprintf (stderr, "error: no directories defined\n");
      if (log) fprintf (log, "error: no directories defined\n");
      return 2;
   }

/*   if (m_oArguments.time < 20) {
      fprintf (stderr, "warning: changing time to 20s (minimum)\n");
      m_oArguments.time = 20;
   }
*/

   /*------------------------Verbose Output----------------------------------------*/
   struct DirectoryEntity   *directory;

   if (m_oArguments.verbose >= 2) {
      printf ("directories: "); for (directory = m_oArguments.directory; directory != NULL; directory = directory->next) printf ("%s,", directory->name);
      printf ("\ntime: %u\n", m_oArguments.time);
      if (log) { fprintf (log, "verbose: directories: "); for (directory = m_oArguments.directory; directory != NULL; directory = directory->next) fprintf (log, "%s,", directory->name); }
      if (log) fprintf (log, "\nverbose: time: %u\n", m_oArguments.time);
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
      if (log) fprintf (log, "verbose: found images: %i\n", maxImages);
      if (log) fprintf (log, "verbose: accepted images: %i\n", sumImages);
   }

   if (sumImages <= 1) {
      fprintf (stderr, "error: not enough images to rotate (< 2)\n");
      if (log) fprintf (log, "error: not enough images to rotate (< 2)\n");
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
   if (log) fflush (log);

/*
   struct rtc_time rtctime; memset (&rtctime, 0, sizeof (struct rtc_time) );
   //rtctime.tm_sec = 15;
   struct rtc_wkalrm rtcalarm; memset (&rtcalarm, 0, sizeof (struct rtc_wkalrm) );
   rtcalarm.enabled = 1;
   unsigned long irqp = 1;
   int ret;
   struct timespec andtime;

   int rtcfd = open ("/dev/rtc0", O_RDONLY);
   int andcfd = open ("/dev/alarm", O_RDONLY);

   ret = ioctl (andfd, ANDROID_ALARM_GET_TIME, &andtime);

   printf ("point3: %i %i\n", rtcfd, ret);

   ret       = ioctl (rtcfd, RTC_RD_TIME, &rtctime);

   printf ("point1: %i %i, %4i-%02i-%02i %02i:%02i:%02i\n", rtcfd, ret, 1900 + rtctime.tm_year, rtctime.tm_mon, rtctime.tm_mday, rtctime.tm_hour, rtctime.tm_min, rtctime.tm_sec);

   rtctime.tm_sec += 20;
   if (rtctime.tm_sec >= 60) {
      rtctime.tm_sec %= 60;
      rtctime.tm_min++;
   }
   if (rtctime.tm_min == 60) {
      rtctime.tm_min = 0;
      rtctime.tm_hour++;
   }
   if (rtctime.tm_hour == 24)
      rtctime.tm_hour = 0;

   rtcalarm.time = rtctime;

   //ret       = ioctl (rtcfd, RTC_AIE_ON, &irqp);
   ret       = ioctl (rtcfd, RTC_WKALM_SET, &rtcalarm);

   printf ("point2: %i %i, %4i-%02i-%02i %02i:%02i:%02i\n", rtcfd, ret, 1900 + rtctime.tm_year, rtctime.tm_mon, rtctime.tm_mday, rtctime.tm_hour, rtctime.tm_min, rtctime.tm_sec);
   //printf ("point1: %i %i, %hhu %hhu \n", rtcfd, ret, rtcalarm.enabled, rtcalarm.pending);
   //printf ("point1: %i %i, %lu\n", rtcfd, ret, irqp);

   //ret       = ioctl (rtcfd, RTC_AIE_ON, 0);

   //printf ("point3: %i %i\n", rtcfd, ret);

   ret       = ioctl (rtcfd, RTC_WKALM_RD, &rtcalarm);

   rtctime = rtcalarm.time;

   printf ("point4: %i %i, %4i-%02i-%02i %02i:%02i:%02i\n", rtcfd, ret, 1900 + rtctime.tm_year, rtctime.tm_mon, rtctime.tm_mday, rtctime.tm_hour, rtctime.tm_min, rtctime.tm_sec);

   ret       = read (rtcfd, &irqp, sizeof(unsigned long) );

   printf ("point5: %i %i, %lu\n", rtcfd, ret, irqp);
*/

   while (g_bRepeat) {
      if (gosleep) {
         //sleep (m_oArguments.time);
         sleep ( (m_oArguments.time > 300)?300:m_oArguments.time);   //TODO calculate sleep value in more intelligent way

         //if (m_oArguments.verbose >= 2) { printf ("log: waked up\n"); fflush (stdout); }
         if (log && m_oArguments.verbose >= 2) { fprintf (log, "log: waked up\n"); fflush (log); }
      }

      if (!g_bRepeat)
         break;

      if (g_bReload) {
         if (m_oArguments.verbose >= 2) {
            printf ("reload directories\n");
            if (log) fprintf (log, "log: reload directories\n");
         }

         free (randomVector); randomVector = NULL;

         for (vectorLast = vector; vectorLast != NULL; vectorLast = vectorLast->next) {
            cleanupImageVector (&vectorLast->vector);
         }//end for
         vector = NULL;

         readDirectories (&vector, m_oArguments.directory);
         countAcceptedImages (&sumImages, vector);

         if (sumImages <= 1) {
            fprintf (stderr, "error: not enough images to rotate (< 2)\n");
            if (log) fprintf (log, "error: not enough images to rotate (< 2)\n");
            return 4;
         }

         createRandomList (&randomVector, &oldLikelihood, vector, sumImages, m_oArguments.likelihood);

         reloadcount = 0;
         g_bReload   = false;
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

      if (!(pid = fork() ) ) {
         if (log) { dup2 (fileno(log), fileno(stdout) ); dup2 (fileno(log), fileno(stderr) ); fclose (log); }
         execvp ("/system/bin/mksh", argv2);
         exit (1);
      }


      waitpid (pid, NULL, 0);
      
      time_t curr = time (NULL);
      if (begtime + m_oArguments.time < curr)
         while ( (begtime += m_oArguments.time) < curr) ;

      if (m_oArguments.verbose >= 2) {
         printf ("set wallpaper: %s\n", current->vector->temp1);
         if (log) fprintf (log, "log: set wallpaper: %s\n", current->vector->temp1);
      }

      if (++reloadcount >= 5) {   //TODO make this more dynamic
         g_bReload = true;
         gosleep   = false;
      }

      //printf ("working %lli %i %lli \n", oldLikelihood, RAND_MAX, random);
      fflush(stdout);
      if (log) fflush(log);
   }//end while


   /*------------------------Cleanup-----------------------------------------------*/
   free (randomVector);
   for (vectorLast = vector; vectorLast != NULL; vectorLast = vectorLast->next) {
      cleanupImageVector (&vectorLast->vector);
   }//end for

   if (log) fclose (log);

   return 0;
}//end Main

