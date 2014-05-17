// See the file "license.terms" for information on usage and redistribution of
// this file, and for a DISCLAIMER OF ALL WARRANTIES.

#ifndef ARGUMENTHANDLING_H
#define ARGUMENTHANDLING_H


//---------------------------Includes----------------------------------------------//



//---------------------------Defines-----------------------------------------------//



//---------------------------Struct DirectoryEntity--------------------------------//
struct DirectoryEntity {
   char const             *name;
   struct DirectoryEntity *next;
};//end struct



//---------------------------Struct Arguments--------------------------------------//
struct Arguments {
   struct DirectoryEntity *directory;
   size_t                  time;
   int                     timeoffset;
   int                     likelihood;
   int                     verbose;
   char const             *logfile;
   int                     updatetime;
   int                     reloadmult;
   int                     breakup;
};//end struct



//---------------------------Forward Declarations----------------------------------//
int checkArguments (struct Arguments *args, int argc, const char *argv[], const char* envp[]);

#endif //ARGUMENTHANDLING_H
