// See the file "license.terms" for information on usage and redistribution of
// this file, and for a DISCLAIMER OF ALL WARRANTIES.


//---------------------------Includes----------------------------------------------//
#include<stdio.h>
#include<unistd.h>
#include<stdlib.h>
#include<fcntl.h>
#include<sys/wait.h>
#include "wallpaper-changer.h"
#include "argumenthandling.h"
#include "directoryhandling.h"



//---------------------------Global Variables--------------------------------------//
static bool g_bRepeat = true;
static bool g_bReload = false;

#include "signalhandling.h"



//---------------------------Struct ImageVectorEntity------------------------------//
struct ImageVectorEntity {
   char const               *directory;
   struct ImageVector        vector;
   char                      temp1[512];
   size_t                    temp2;
   //char                     *temp3;
   //char                     *temp4;
   struct ImageVectorEntity *next;
};//end struct



//---------------------------Struct ImageVectorEntity------------------------------//
struct RandomListEntity {
   struct ImageVectorEntity *vector;
   int                       pos;
   long long                 likelihood;
   size_t                    counter;
};//end struct



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
   m_oArguments.breakup    = false;
   m_oArguments.updatetime = 172800;   // two days

   if (!checkArguments (&m_oArguments, argc, argv, envp) ) {
      return 1;
   }

   if (m_oArguments.breakup)
      return 0;

   if (!m_oArguments.directory) {
      fprintf (stderr, "error: no directories defined\n");
      return 2;
   }

   if (m_oArguments.time < 20) {
      fprintf (stderr, "warning: changing time to 20s (minimum)\n");
      m_oArguments.time = 20;
   }


   /*------------------------Verbose Output----------------------------------------*/
   struct DirectoryEntity   *directory;

   if (m_oArguments.verbose >= 2) {
      printf ("directories: "); for (directory = m_oArguments.directory; directory != NULL; directory = directory->next) printf ("%s,", directory->name);
      printf ("\ntime: %u\n", m_oArguments.time);
   }


   /*------------------------Read Directories--------------------------------------*/
   struct ImageVectorEntity *vector     = NULL;
   struct ImageVectorEntity *vectorLast = NULL;

   for (directory = m_oArguments.directory; directory != NULL; directory = directory->next) {
      if (!vector)
         vector = vectorLast = (struct ImageVectorEntity*) malloc (sizeof(struct ImageVectorEntity) );
      else
         vectorLast = vectorLast->next = (struct ImageVectorEntity*) malloc (sizeof(struct ImageVectorEntity) );

      vectorLast->directory = directory->name;
      vectorLast->temp2     = strnlen (directory->name, 512);
      strncpy (vectorLast->temp1, directory->name, vectorLast->temp2);
      vectorLast->temp1[vectorLast->temp2++] = '/';

      parseDirectory (&vectorLast->vector, directory->name);
   }//end for


   /*------------------------Count accepted Images---------------------------------*/
   int sumImages = 0;
   for (vectorLast = vector; vectorLast != NULL; vectorLast = vectorLast->next) {
      if (!vectorLast->vector.vector)
         continue;

      if (!vectorLast->vector.likelihood) {
         sumImages += vectorLast->vector.length;
      } else {
         int n = 0;
         for (; n < vectorLast->vector.length; ++n)
            if (vectorLast->vector.likelihood[n] != 0)
               ++sumImages;
      }
   }//end for

   if (sumImages <= 1) {
      fprintf (stderr, "error: not enough images to rotate (< 2)\n");
      return 3;
   }


   /*------------------------Create Image Random List------------------------------*/
   struct RandomListEntity *randomVector = (struct RandomListEntity*) malloc (sizeof (struct RandomListEntity) * sumImages);
   int a = 0;
   long long oldLikelihood = 0;

   for (vectorLast = vector; vectorLast != NULL; vectorLast = vectorLast->next) {
      if (!vectorLast->vector.vector)
         continue;

      int n = 0;
      if (!vectorLast->vector.likelihood) {
         for (; n < vectorLast->vector.length; ++n) {
            randomVector[a].vector     = vectorLast;
            randomVector[a].pos        = n;
            randomVector[a].counter    = 0;
            randomVector[a].likelihood = (oldLikelihood += m_oArguments.likelihood);
            ++a;
         }//end for
      } else {
         for (; n < vectorLast->vector.length; ++n) {
            if (vectorLast->vector.likelihood[n] == 0)
               continue;

            randomVector[a].vector     = vectorLast;
            randomVector[a].pos        = n;
            randomVector[a].counter    = 0;

            if (vectorLast->vector.likelihood[n] == -1)
               randomVector[a].likelihood = (oldLikelihood += m_oArguments.likelihood);
            else if (vectorLast->vector.likelihood[n] > 0)
               randomVector[a].likelihood = (oldLikelihood += vectorLast->vector.likelihood[n]);

            ++a;
         }//end for
      }
   }//end for


   /*------------------------Main Loop---------------------------------------------*/
   bool twoRandom = false;
   bool gosleep   = true;
   long long random = 0;
   char command[1024];
   struct RandomListEntity *current = &randomVector[0];
   char *argv2[] = {"/system/bin/mksh", "-c", NULL, NULL};

   if (oldLikelihood > RAND_MAX)
      twoRandom = true;

   srand (time(NULL) );


   while (g_bRepeat) {
      if (gosleep)
         sleep (m_oArguments.time);

      gosleep = true;

      if (!g_bRepeat)
         break;

      if (g_bReload) {


         g_bReload = false;
         continue;
      }

      if (twoRandom) {   //TODO better random algorithm for big values
         //random = oldLikelihood / ( (unsigned int)rand () + 1);
         random += (long long)rand () + (long long)rand () + (long long)rand (); random %= oldLikelihood;
         random += (long long)rand () + (long long)rand () + (long long)rand (); random %= oldLikelihood;
         random += (long long)rand () + (long long)rand () + (long long)rand (); random %= oldLikelihood;
         random += (long long)rand () + (long long)rand () + (long long)rand (); random %= oldLikelihood;
         random += (long long)rand () + (long long)rand () + (long long)rand (); random %= oldLikelihood;
         random += (long long)rand () + (long long)rand () + (long long)rand (); random %= oldLikelihood;
         random += (long long)rand () + (long long)rand () + (long long)rand (); random %= oldLikelihood;
      } else {
         random  = rand () % oldLikelihood;
      }

      ++random;


      int n;
      for (n = 0; n < sumImages; ++n) {
         if (randomVector[n].likelihood >= random) {
            if (current == &randomVector[n])
               gosleep = false;
            else
               current = &randomVector[n];
            break;
         }
      }//end for

      if (!gosleep)
         continue;


      strncpy (&current->vector->temp1[current->vector->temp2], current->vector->vector.vector[current->pos], 512 - current->vector->temp2);

      snprintf (command, 1024, "cp \"%s\" \"/data/data/com.android.settings/files/wallpaper\"", current->vector->temp1);

      argv2[2] = command;

      int pid;

      if (!(pid = fork() ) ) {
         execvp ("/system/bin/mksh", argv2);
         exit (1);
      } else {
         waitpid (pid, NULL, 0);
      }


/*      int in_fd = open (current->vector->temp1, O_RDONLY);

      if (!in_fd) {
         fprintf (stderr, "warning: cannot copy image \"%s\"\n", current->vector->temp1);
         continue;
      }

      //posix_fadvise(in_fd, 0, 0, POSIX_FADV_SEQUENTIAL);




      int out_fd = open ("/data/data/com.android.settings/files/wallpaper", O_WRONLY);

      if (!out_fd) {
         close (in_fd);
         fprintf (stderr, "warning: cannot copy image to \"/data/data/com.android.settings/files/wallpaper\"\n");
         continue;
      }

      char buf[8192];

      while (true) {
         ssize_t result = read (in_fd, &buf[0], sizeof(buf) );
         if (result < 0) {
            fprintf (stderr, "warning: problems while reading image\n");
            break;
         }
         if (result == 0) {
            fprintf (stderr, "warning: problems while reading image2\n");
            break;
         }
fprintf (stderr, "point1\n");
         if (write (out_fd, &buf[0], result) <= 0) {
            fprintf (stderr, "warning: problems while writing image\n");
            break;
         }
      }

      close (in_fd);
      close (out_fd);
*/
      printf ("set wallpaper: %s\n", current->vector->temp1);

      //printf ("working %lli %i %lli \n", oldLikelihood, RAND_MAX, random);
      fflush(stdout);
   }//end while


   /*------------------------Cleanup-----------------------------------------------*/
   for (vectorLast = vector; vectorLast != NULL; vectorLast = vectorLast->next) {
      cleanupImageVector (&vectorLast->vector);
   }//end for


   return 0;
}//end Main

