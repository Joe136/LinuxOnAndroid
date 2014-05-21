
//See the file "license.terms" for information on usage and redistribution of
//this file, and for a DISCLAIMER OF ALL WARRANTIES.


//---------------------------Includes----------------------------------------------//
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

#include "../chroot-break/chroot-break.h"



//---------------------------Defines-----------------------------------------------//



//---------------------------Start breakChrootEnv----------------------------------//
int breakChroot () {
   enum tResult res = breakChrootEnv ();

   if (res == NOERROR)
      return 1;
   else
      return 0;
}//end Fct



//---------------------------Start getBatteryLevel---------------------------------//
int getBatteryLevel () {
   int pipefd[2];

   int ret = pipe (pipefd);

   if (ret != 0)
      return -3;

   int child = fork();

   if (!child) {
      dup2 (pipefd[1], STDOUT_FILENO);

      close (pipefd[0]);
      close (pipefd[1]);

      setEnvParams ();

      execl ("/system/bin/dumpsys", "dumpsys", "battery", NULL);

      perror("exec of the child process");

      exit (1);
   }

   char buffer[4096];

   ssize_t len = read (pipefd[0], &buffer, 4096);

   int status;
   waitpid (child, &status, 0);

   buffer[len] = 0;

   if (!len) {
      printf ("error: could not read battery status\n");
      return -4;
   }

   char *beg = strstr (buffer, "level:");

   if (!beg) {
      printf ("error: could not detect battery level\n");
      return -5;
   }

   char *end = strstr (beg, "\n");

   if (!end) {
      printf ("error: could not detect battery level\n");
      return -6;
   }

   end[0] = 0;

   return atoi (&beg[6]);
}//end Fct
