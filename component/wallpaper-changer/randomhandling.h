// See the file "license.terms" for information on usage and redistribution of
// this file, and for a DISCLAIMER OF ALL WARRANTIES.

#ifndef RANDOMHANDLING_H
#define RAND0MHANDLING_H

//---------------------------Includes----------------------------------------------//
//#include<signal.h>



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



//---------------------------Start readDirectories---------------------------------//
bool readDirectories (struct ImageVectorEntity **vector_, struct DirectoryEntity *directoryList) {
   if (vector_ == NULL)
      return false;

   struct DirectoryEntity   *directory;
   struct ImageVectorEntity *vector     = NULL;
   struct ImageVectorEntity *vectorLast = NULL;

   for (directory = directoryList; directory != NULL; directory = directory->next) {
      if (!vector)
         vector = vectorLast = (struct ImageVectorEntity*) malloc (sizeof(struct ImageVectorEntity) );
      else
         vectorLast = vectorLast->next = (struct ImageVectorEntity*) malloc (sizeof(struct ImageVectorEntity) );

      vectorLast->directory = directory->name;
      vectorLast->next      = NULL;
      vectorLast->temp2     = strnlen (directory->name, 512);
      strncpy (vectorLast->temp1, directory->name, vectorLast->temp2);
      vectorLast->temp1[vectorLast->temp2++] = '/';

      parseDirectory (&vectorLast->vector, directory->name);
   }//end for

   *vector_ = vector;
   return true;
}//end Fct



//---------------------------Start countAcceptedImages-----------------------------//
bool countAcceptedImages (int *sumImages_, struct ImageVectorEntity *vector) {
   if (sumImages_ == NULL || vector == NULL)
      return false;

   int sumImages = 0;
   struct ImageVectorEntity *vectorLast = NULL;

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

   *sumImages_ = sumImages;
   return true;
}//end Fct



//---------------------------Start createRandomList--------------------------------//
bool createRandomList (struct RandomListEntity **randomVector_, long long *oldLikelihood_, struct ImageVectorEntity *vector, int sumImages, int defaultLikelihood) {
   if (randomVector_ == NULL || oldLikelihood_ == NULL)
      return false;

   struct RandomListEntity *randomVector = (struct RandomListEntity*) malloc (sizeof (struct RandomListEntity) * sumImages);
   int a = 0;
   long long oldLikelihood = 0;
   struct ImageVectorEntity *vectorLast = NULL;

   for (vectorLast = vector; vectorLast != NULL; vectorLast = vectorLast->next) {
      if (!vectorLast->vector.vector)
         continue;

      int n = 0;
      if (!vectorLast->vector.likelihood) {
         for (; n < vectorLast->vector.length; ++n) {
            randomVector[a].vector     = vectorLast;
            randomVector[a].pos        = n;
            randomVector[a].counter    = 0;
            randomVector[a].likelihood = (oldLikelihood += defaultLikelihood);
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
               randomVector[a].likelihood = (oldLikelihood += defaultLikelihood);
            else if (vectorLast->vector.likelihood[n] > 0)
               randomVector[a].likelihood = (oldLikelihood += vectorLast->vector.likelihood[n]);

            ++a;
         }//end for
      }
   }//end for

   *randomVector_  = randomVector;
   *oldLikelihood_ = oldLikelihood;
   return true;
}//end Fct



//---------------------------Start randomValue-------------------------------------//
long long randomValue (long long random, long long maxval) {
   if (maxval > RAND_MAX) {   //TODO better random algorithm for big values
      //random = maxval / ( (unsigned int)rand () + 1);
      random += (long long)rand () + (long long)rand () + (long long)rand (); random %= maxval;
      random += (long long)rand () + (long long)rand () + (long long)rand (); random %= maxval;
      random += (long long)rand () + (long long)rand () + (long long)rand (); random %= maxval;
      random += (long long)rand () + (long long)rand () + (long long)rand (); random %= maxval;
      random += (long long)rand () + (long long)rand () + (long long)rand (); random %= maxval;
      random += (long long)rand () + (long long)rand () + (long long)rand (); random %= maxval;
      random += (long long)rand () + (long long)rand () + (long long)rand (); random %= maxval;
   } else {
      random  = rand () % maxval;
   }

   return random;
}//end Fct

#endif //RANDOMHANDLING_H
