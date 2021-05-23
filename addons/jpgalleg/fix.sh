#!/bin/sh
#
# Converts line breaks to Unix format and configures JPGalleg to be built
# under specified platform. Derived from the Allegro version of this same
# script.

proc_help()
{
   echo
   echo "Usage: ./fix.sh <platform> [--quick|--dtou|--utod]"
   echo
   echo "Where platform is one of: djgpp, mingw32, msvc, beos, unix, macosx,"
   echo "macosx-universal"
   echo "The --quick parameter turns off text file conversion, --dtou converts from"
   echo "DOS/Win32 format to Unix and --utod converts from Unix to DOS/Win32 format."
   echo "If no parameter is specified --dtou is assumed."
   echo

   NOCONV="1"
}

proc_fix()
{
   echo "Configuring JPGalleg for $1..."

   echo "# generated by fix.sh" > makefile
   echo "MAKEFILE_INC = $2" >> makefile
   echo "include makefile.all" >> makefile
}

proc_fix_osx_ub()
{
   echo "Configuring JPGalleg for Mac OSX Universal Binary ..."

   echo "# generated by fix.sh"        > makefile
   echo "UB = 1"                      >> makefile
   echo "MAKEFILE_INC = makefile.osx" >> makefile
   echo "include makefile.all"        >> makefile
}

proc_filelist()
{
   # common files.
   FILELIST=`find . -type f -not -path "*.svn*" "(" \
      -name "*.c" -o -name "*.h" -o -name "*.s" -o -name "*.txt" -o \
      -name "*.inc" -o -name "*.scm" -o -name "*.scr" -o -name "*.scu" -o \
      -name "makefile*" \
   ")"`

   # touch unix shell scripts?
   if [ "$1" != "omit_sh" ]; then
      FILELIST="$FILELIST `find . -type f -name '*.sh'`"
   fi

   # touch DOS batch files?
   if [ "$1" != "omit_bat" ]; then
      FILELIST="$FILELIST `find . -type f -name '*.bat'`"
   fi
}

proc_utod()
{
   echo "Converting files from Unix to DOS/Win32..."
   proc_filelist "omit_sh"
   /bin/sh ../../misc/utod.sh $FILELIST
}

proc_dtou()
{
   echo "Converting files from DOS/Win32 to Unix..."
   proc_filelist "omit_bat"
   /bin/sh ../../misc/dtou.sh $FILELIST
}

# prepare JPGalleg for the given platform.

if [ -z "$1" ]; then
   proc_help
   exit 0
fi

case "$1" in
   "djgpp"   ) proc_fix "DJGPP" "makefile.dj";;
   "mingw32" ) proc_fix "MinGW32" "makefile.mgw";;
   "mingw"   ) proc_fix "MinGW32" "makefile.mgw";;
   "msvc"    ) proc_fix "MSVC" "makefile.vc";;
   "beos"    ) proc_fix "BeOS" "makefile.be";;
   "haiku"   ) proc_fix "Haiku" "makefile.be";;
   "unix"    ) proc_fix "Unix" "makefile.uni";;
   "macosx"  ) proc_fix "MacOS X" "makefile.osx";;
   "macosx-universal" ) proc_fix_osx_ub ;;
   "help"    ) proc_help; exit 0;;
   *         ) echo "Platform not supported by JPGalleg."; exit 0;;
esac

# convert all text-file line endings.

if [ "$NOCONV" != "1" ]; then
   case "$2" in
      "--utod"  ) proc_utod "$1";;
      "--dtou"  ) proc_dtou "$1";;
   esac
fi

# set execute permissions just in case.

chmod +x *.sh misc/*.sh