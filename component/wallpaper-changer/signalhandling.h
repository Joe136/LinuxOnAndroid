// See the file "license.terms" for information on usage and redistribution of
// this file, and for a DISCLAIMER OF ALL WARRANTIES.

#ifndef SIGNALHANDLING_H
#define SIGNALHANDLING_H

//---------------------------Includes----------------------------------------------//
#include<signal.h>



//---------------------------Start catchSignal-------------------------------------//
void catchSignal (int sigNr) {
   switch (sigNr) {
   case SIGINT:
      printf ("\ncatched signal SIGINT\n"); fflush (stdout);
      g_bRepeat = false;
      break;
   case SIGUSR1:
      printf ("\ncatched signal SIGUSR1\n"); fflush (stdout);
      g_bReload = true;
      break;
   case SIGALRM:
      printf ("\ncatched signal SIGALRM\n"); fflush (stdout);
      g_bNext = true;
      break;
   case SIGTERM:
      printf ("\ncatched signal SIGTERM\n"); fflush (stdout);
      g_bRepeat = false;
      break;
   default:
      printf ("\ncatched signal %i\n", sigNr); fflush (stdout);
      g_bRepeat = false;
   }//end switch
}//end Fct


//---------------------------Start registerSignals---------------------------------//
void registerSignals () {

   signal (SIGINT , catchSignal);
   signal (SIGUSR1, catchSignal);
   signal (SIGALRM, catchSignal);
   signal (SIGTERM, catchSignal);

   //for (int sigNr = 1; sigNr < 32; ++sigNr) {
      //signal (sigNr, catchSignal);

      //if (sigNr == 13 || sigNr == 25) continue;   // debugging with GDB
      //if (sigNr == 2) continue;   // CTRL + C
      //printf ("nr: %i\n", sigNr);

//      struct sigaction sa;
//      sigaction(sigNr, 0, &sa); // reads existing handler, iniz's sa

      //assert(sa.sa_handler == SIG_DFL);
//      sa.sa_flags = SA_NODEFER;
//      sa.sa_handler = HandleSIGNAL; // set our handler

//      sigaction(sigNr, &sa, 0);
   //}//end for
}//end Fct

#endif //SIGNALHANDLING_H
