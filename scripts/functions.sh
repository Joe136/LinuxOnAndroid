
# See the file "license.terms" for information on usage and redistribution of
# this file, and for a DISCLAIMER OF ALL WARRANTIES.


vercmp()
{
  a1="$(echo "$1" | tr '.' ' ' | awk '{ print $1 }')"
  b1="$(echo "$1" | tr '.' ' ' | awk '{ print $2 }')"
  c1="$(echo "$1" | tr '.' ' ' | awk '{ print $3 }')"
  a2="$(echo "$2" | tr '.' ' ' | awk '{ print $1 }')"
  b2="$(echo "$2" | tr '.' ' ' | awk '{ print $2 }')"
  c2="$(echo "$2" | tr '.' ' ' | awk '{ print $3 }')"

  r1=$((a1 - a2))
  r2=$((b1 - b2))
  r3=$((c1 - c2))

  if [ $r1 -eq 0 ]; then
    if [ $r2 -eq 0 ]; then
      if [ $r3 -eq 0 ]; then
        echo 0
      else
        if [ $r3 -gt 0 ]; then
          echo 1
        else
          echo -1
        fi
      fi
    else
      if [ $r2 -gt 0 ]; then
        echo 1
      else
        echo -1
      fi
    fi
  else
    if [ $r1 -gt 0 ]; then
      echo 1
    else
      echo -1
    fi
  fi
}



getBBver()
{
  echo $($1 | head -n 1 | awk ' /\BusyBox\/* /{ print $2 }' | tr '-' '\n' | head -n 1 | tr -d 'v')
}



searchImageCurrentPath()
{
  if [ -e "$1/$2.img" ]; then echo "$1/$2.img"; return; fi

  if [ -d "$1/$2" ]; then
    count="$(ls -A $1/$2/*.img | awk 'BEGIN{ORS="\t"}{print $0}' | awk -F "\t" '{print NF}')"
    if [ "$(($count == 1))" == "1" ]; then echo "$sdcard/$2/*.img"; return;
    elif [ "$(($count > 1))" == "1"  ]; then
      echo "Is one of these images your System?" 1>&2
      echo "0: No" 1>&2
      ls -A $1/$2/*.img | awk '{print NR ": " $1}' 1>&2
      unset var
      read var
      if [ "$(($var <= $count))" == "1" ] && [ "$(($var > 0))" == "1" ]; then
        echo "$(ls -A $1/$2/*.img | awk 'BEGIN{ORS="\t"}{print $0}' | awk -F "\t" '{print $'$count'}')"
        return
      fi
    fi
  fi
}

searchImage() # arg1: kit-path, arg2: given system
{
  local bname="$(basename $2)"
  if [ "$(($(echo $bname | awk 'BEGIN{FS="."{print NF}}') > 1))" == "1" ]; then
    if [ "$(echo $2 | awk 'BEGIN{FS="."}{print $NF}')" == "img" ]; then
    fi
  elif [ "$bname" == "$2" ]; then
  elif []; then
  fi

  if [ -e "$1/$2.img" ]; then echo "$1/$2.img"; return; fi

  local img="$(searchImageCurrentPath $sdcard $2)"
  if [ ! -z "$img" ]; echo "$img"; return; fi

  if [ ! -z "$intern" ]; then
    local img="$(searchImageCurrentPath $intern $2)"
    if [ ! -z "$img" ]; echo "$img"; return; fi
  fi

  if [ -d "$sdcard/linux" ]; then
    local img="$(searchImageCurrentPath $sdcard/linux $2)"
    if [ ! -z "$img" ]; echo "$img"; return; fi
  fi

  if [ -d "$intern/linux" ]; then
    local img="$(searchImageCurrentPath $intern/linux $2)"
    if [ ! -z "$img" ]; echo "$img"; return; fi
  fi

  if [ -d "$sdcard/linuxonandroid" ]; then
    local img="$(searchImageCurrentPath $sdcard/linuxonandroid $1)"
    if [ ! -z "$img" ]; echo "$img"; return; fi
  fi

  if [ -d "$intern/linuxonandroid" ]; then
    local img="$(searchImageCurrentPath $intern/linuxonandroid $1)"
    if [ ! -z "$img" ]; echo "$img"; return; fi
  fi


}



#currentscriptpath()
#{
#  local fullpath=`echo "$(readlink -f $0)"`
#  local fullpath_length=`echo ${#fullpath}`
#  local scriptname="$(basename "$fullpath")"
#  local scriptname_length=`echo ${#scriptname}`
#  local result_length=`echo $((fullpath_length - $scriptname_length - 1))`
#  local result=`echo "$fullpath" | head -c $result_length`
#  echo "$result"
#}



#checkargs(args,level0,level1)
#{
#  arglenght="?"
#  result=""
#  lineend='
#'
#  i=$((1))
#
#  while [ $(($i <= $arglength)) == "1" ]
#  do
#
#
#  done
#
#  echo "$result"
#}


