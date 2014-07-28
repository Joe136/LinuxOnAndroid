// See the file "license.terms" for information on usage and redistribution of
// this file, and for a DISCLAIMER OF ALL WARRANTIES.

#ifndef IPCHANDLING_H
#define IPCHANDLING_H

//---------------------------Includes----------------------------------------------//
#define _GNU_SOURCE
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/prctl.h>
#include <sys/un.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <string.h>
#include <pthread.h>



//---------------------------Defines-----------------------------------------------//
#define NAME "/dev/socket/wallpaper"
#define SBUF 32



//---------------------------Struct ServerConfig-----------------------------------//
struct ServerConfig {
   int sock;
   struct sockaddr_un server;
   struct StatisticsConfig *statistics;
};//end struct



//---------------------------Forward Declarations----------------------------------//
char *sendIPC (struct ServerConfig *config, char *message);



//---------------------------Includes----------------------------------------------//
#include "loghandling.h"



//---------------------------Start openIPCServer-----------------------------------//
bool openIPCServer (struct ServerConfig *config) {
   if (config == NULL) return false;

   config->sock = socket (AF_UNIX, SOCK_STREAM, 0);
   if (config->sock <= 0)
      return false;

   config->server.sun_family = AF_UNIX;
   strcpy (config->server.sun_path, NAME);

   int res = bind (config->sock, (struct sockaddr*) &config->server, sizeof (struct sockaddr_un) );
   if (res)
      return false;

   listen (config->sock, 3);

   return true;
}//end Fct



//---------------------------Start openIPCClient-----------------------------------//
bool openIPCClient (struct ServerConfig *config) {
   if (config == NULL) return false;

   config->sock = socket (PF_UNIX, SOCK_STREAM, 0);
   if (config->sock <= 0)
      return false;

   config->server.sun_family = AF_UNIX;
   strcpy (config->server.sun_path, NAME);

   int res = connect (config->sock, (struct sockaddr*) &config->server, sizeof (struct sockaddr_un) );

   if (res)
      return false;

   return true;
}//end Fct



//---------------------------Start runIPCServer------------------------------------//
void *runIPCServer (void *vconfig) {
   if (vconfig == NULL) return NULL;

   prctl (PR_SET_NAME, "IPCServer", 0, 0, 0);

   struct ServerConfig *config = (struct ServerConfig*)vconfig;

   char buffer[SBUF];

   while (g_bRepeat) {
      int sock = accept (config->sock, 0, 0);

      if (sock != -1) {
         bzero (buffer, SBUF);

         int rval = read (sock, buffer, SBUF);

         if (rval > 0) {
            bool wakeup = true;

            if (!strncmp (buffer, "exit", 5) )
               g_bRepeat = false;
            else if (!strncmp (buffer, "time", 5) )
               g_bTime = true;
            else if (!strncmp (buffer, "reload", 7) )
               g_bReload = true;
            else if (!strncmp (buffer, "status", 7) ) {
               //g_bStatus = true;
               char *statusmsg = logStatus (config->statistics, true);
               if (statusmsg) {
                  send (sock, statusmsg, strnlen (statusmsg, 4096), 0);
                  free (statusmsg);
               }
            } else if (!strncmp (buffer, "next", 5) )
               g_bNext = true;
            else if (!strncmp (buffer, "current", 8) )
               g_bCurrent = true;
            else
               wakeup = false;

            if (wakeup)
               //alarm (1);
               kill (getpid (), SIGSTKFLT);
         }
      }

      close(sock);
   }//end while

   return NULL;
}//end Fct



//---------------------------Start startIPCServer----------------------------------//
void startIPCServer (struct ServerConfig *config) {
   pthread_t ipcthread;

   pthread_create (&ipcthread, NULL, runIPCServer, (void *) config);

   //pthread_setname_np (&ipcthread, "IPCServer");
}//end Fct



//---------------------------Start sendIPC-----------------------------------------//
char *sendIPC (struct ServerConfig *config, char *message) {
   if (config == NULL) return NULL;

   char  buffer[4096];
   char *result = NULL;

   bzero (buffer, SBUF);
   strncpy (buffer, message, SBUF);

   send (config->sock, buffer, SBUF, 0);

   int size = 0;

   //do {
      //size = recv (config->sock, buffer, 4095, 0);
      size = read (config->sock, buffer, 4095);

      if (size > 0) {
         buffer[size] = 0;

         result = (char*)malloc (4096);
         strncpy (result, buffer, size + 1);
      }
   //} while (size >= 0);

   return result;
}//end Fct



//---------------------------Start closeIPC----------------------------------------//
void closeIPC (struct ServerConfig *config) {
   if (config == NULL) return;

   close (config->sock);
   unlink (NAME);
}//end Fct



//---------------------------Start closeIPCServer----------------------------------//
void closeIPCServer (struct ServerConfig *config) {
   if (config == NULL) return;

   close (config->sock);
   unlink (NAME);
}//end Fct



//---------------------------Start closeIPCClient----------------------------------//
void closeIPCClient (struct ServerConfig *config) {
   if (config == NULL) return;

   close (config->sock);
}//end Fct

#endif //IPCHANDLING_H

