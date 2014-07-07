// See the file "license.terms" for information on usage and redistribution of
// this file, and for a DISCLAIMER OF ALL WARRANTIES.

#ifndef SIGNALHANDLING_H
#define SIGNALHANDLING_H

//---------------------------Includes----------------------------------------------//
#include<signal.h>



//---------------------------Start execSignal--------------------------------------//
void execSignal (const char *msg, bool *var, bool val) {
   printf ("\n%s\n", msg); fflush (stdout);
   *var = val;
}//end Fct



//---------------------------Start catchSignal-------------------------------------//
void catchSignal (int sigNr) {
   switch (sigNr) {
   case SIGHUP:
      execSignal ("catched signal SIGHUP", &g_bRepeat, false);
      break;
   case SIGINT:
      execSignal ("catched signal SIGINT", &g_bRepeat, false);
      break;
   case SIGQUIT:
      execSignal ("catched signal SIGQUIT", &g_bRepeat, false);
      break;
   case SIGTRAP:
      execSignal ("catched signal SIGTRAP", &g_bTime, true);
      break;
   case SIGUSR1:
      execSignal ("catched signal SIGUSR1", &g_bReload, true);
      break;
   case SIGUSR2:
      execSignal ("catched signal SIGUSR2", &g_bStatus, true);
      break;
   case SIGALRM:
      execSignal ("catched signal SIGALRM", &g_bNext, true);
      break;
   case SIGTERM:
      execSignal ("catched signal SIGTERM", &g_bRepeat, false);
      break;
   case SIGSTKFLT:
      execSignal ("catched signal SIGSTKFLT", &g_bCurrent, true);
      break;
   default:
      printf ("\ncatched signal %i\n", sigNr); fflush (stdout);
      g_bRepeat = false;
   }//end switch
}//end Fct


//---------------------------Start registerSignals---------------------------------//
void registerSignals () {

   signal (SIGHUP   , catchSignal);
   signal (SIGINT   , catchSignal);
   signal (SIGQUIT  , catchSignal);
   signal (SIGTRAP  , catchSignal);
   signal (SIGUSR1  , catchSignal);
   signal (SIGUSR2  , catchSignal);
   signal (SIGALRM  , catchSignal);
   signal (SIGTERM  , catchSignal);
   signal (SIGSTKFLT, catchSignal);

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

