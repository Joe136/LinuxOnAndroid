// See the file "license.terms" for information on usage and redistribution of
// this file, and for a DISCLAIMER OF ALL WARRANTIES.

#ifndef ARGUMENTHANDLING_H
#define ARGUMENTHANDLING_H


//---------------------------Includes----------------------------------------------//



//---------------------------Defines-----------------------------------------------//



//---------------------------Struct Arguments--------------------------------------//
struct Arguments {
   int                     verbose;
   char const             *logfile;
   int                     breakup;
   int                     getlevel;
};//end struct



//---------------------------Forward Declarations----------------------------------//
int checkArguments (struct Arguments *args, int argc, const char *argv[], const char* envp[]);

#endif //ARGUMENTHANDLING_H
