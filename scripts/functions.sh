#!/system/bin/mksh
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



# arg1: image path
checkImage()
{
  local size="$(du -m $1 2>/dev/null | awk '{print $1}')"
  [[ -n "$size" ]] && [[ "$(($size > 20))" == "1" ]] && return 0
  return 1
}



# arg1: search-path, arg2: system directory, arg3: possible part of filename
searchImageCurrentPath()
{
  if [ -e "$1/$2.img" ]; then
    $(checkImage "$1/$2.img") && echo "$1/$2.img" && return
  fi
  if [ -e "$1/$2/$3.img" ]; then
    $(checkImage "$1/$2/$3.img") && echo "$1/$2/$3.img" && return
  fi

  if [ -d "$1/$2" ]; then
    # count="$(ls -A $1/$2/*.img | awk 'BEGIN{ORS="\t"}{print $0}' | awk -F "\t" '{print NF}')"
    count="$(ls $1/$2/*.img 2>/dev/null | awk 'BEGIN{ORS="\t"}{print $0}' | awk -F "\t" '{print NF - 1}')"
    # echo "point8: " $(ls $1/$2/*.img) 1>&2
    if [ "$(($count == 1))" == "1" ]; then
      $(checkImage "$1/$2/*.img") && echo "$(ls $1/$2/*.img)" && return
    elif [ "$(($count > 1))" == "1"  ]; then
      count="$(ls $1/$2/$3.*.img $1/$2/$3_*.img 2>/dev/null | awk 'BEGIN{ORS="\t"}{print $0}' | awk -F "\t" '{print NF - 1}')"
      if [ "$(($count == 1))" == "1" ]; then
         $(checkImage "$1/$2/$3.*.img") && echo "$(ls $1/$2/$3.*.img)" && return
         $(checkImage "$1/$2/$3_*.img") && echo "$(ls $1/$2/$3_*.img)" && return
      elif [ "$(($count > 1))" == "1" ]; then
        :
      fi

      #echo "$(ls $1/$2/*.img)"
      return

      # echo "Is one of these images your System?" 1>&2
      # echo "0: No" 1>&2
      # ls -A $1/$2/*.img | awk '{print NR ": " $1}' 1>&2
      # unset var
      # read var
      # if [ "$(($var <= $count))" == "1" ] && [ "$(($var > 0))" == "1" ]; then
      #   # echo "$(ls -A $1/$2/*.img | awk 'BEGIN{ORS="\t"}{print $0}' | awk -F "\t" '{print $'$count'}')"
      #   echo "$(ls $1/$2/*.img | awk 'BEGIN{ORS="\t"}{print $0}' | awk -F "\t" '{print $'$count'}')"
      #   return
      # fi
    fi
  fi
}



# arg1: kit-path, arg2: given system
searchImage()
{
  local bname="$(basename $2)"

  if [ "$bname" == "$2" ]; then
    local systempath="$1"
  else
    local len1="${#bname}"
    local len2="${#2}"
    local systempath="${2:0:$((len2 - len1))}"
    [[ -d "$(realpath "$systempath")" ]] && local systempath="$(realpath "$systempath")"
  fi

  if [ "$(($(echo $bname | awk 'BEGIN{FS="."}{print NF}') > 1))" == "1" ]; then
    # If bname has a suffix
    if [ "$(echo $bname | awk 'BEGIN{FS="."}{print $NF}')" == "img" ]; then
      # If suffix is 'img'
      local systembase="$(echo $bname | awk 'BEGIN{FS=".";ORS=""}{rec = 0; for (i = 1; i < NF; i++) { if (rec == 1) print "."; rec = 1; print $i; } }')"
      local systemsubbase="$(echo $bname | awk 'BEGIN{FS="."}{print $1}')"
    elif [ "$bname" == "$2" ]; then
      # If the clean system-name with suffix is given
      local systembase="$bname"
      local systemsubbase="$(echo $bname | awk 'BEGIN{FS="."}{print $1}')"
    else
      #If path is set and suffix is unknown
      local systembase="$bname"
      local systemsubbase="$(echo $bname | awk 'BEGIN{FS="."}{print $1}')"
    fi
  elif [ "$(($(echo $bname | awk 'BEGIN{FS="_"}{print NF}') > 1))" == "1" ]; then
    # If bname has a suffix
    if [ "$(echo $2 | awk 'BEGIN{FS="."}{print $NF}')" == "img" ]; then
      # If suffix is 'img'
      local systembase="$(echo $bname | awk 'BEGIN{FS="_";ORS=""}{rec = 0; for (i = 1; i < NF; i++) { if (rec == 1) print "_"; rec = 1; print $i; } }')"
      local systemsubbase="$(echo $bname | awk 'BEGIN{FS="_"}{print $1}')"
    elif [ "$bname" == "$2" ]; then
      # If the clean system-name with suffix is given
      local systembase="$bname"
      local systemsubbase="$(echo $bname | awk 'BEGIN{FS="_"}{print $1}')"
    else
      #If path is set and suffix is unknown
      local systembase="$bname"
      local systemsubbase="$(echo $bname | awk 'BEGIN{FS="_"}{print $1}')"
    fi
  elif [ "$bname" == "$2" ]; then
    # If the clean system-name is given
    local systembase="$bname"
  else
    # If path but no suffix is given
    local systembase="$bname"
  fi

  #echo "p1: " $bname
  #echo "p1: " $systembase
  #echo "p1: " $systemsubbase
  #echo "p1: " $systempath

  [[ -e "$systempath/$systembase.img" ]] && $(checkImage "$systempath/$systembase.img") && img="$systempath/$systembase.img" && return
  [[ -e "$systempath/$bname.img" ]] && $(checkImage "$systempath/$bname.img") && img="$systempath/$bname.img" && return
  [[ -e "$systempath/$bname" ]] && $(checkImage "$systempath/$bname") && img="$systempath/$bname" && return

  [[ -e "$1/$systembase.img" ]] && $(checkImage "$1/$systembase.img") && img="$1/$systembase.img" && return
  [[ -e "$1/$bname.img" ]] && $(checkImage "$1/$bname.img") && img="$1/$bname.img" && return
  [[ -e "$1/$bname" ]] && $(checkImage "$1/$bname") && img="$1/$bname" && return

  local l_img="$(searchImageCurrentPath $sdcard $systembase $systemsubbase)"
  [[ -n "$l_img" ]] && img="$l_img" && return

  local l_img="$(searchImageCurrentPath $sdcard $systemsubbase $systemsubbase)"
  [[ -n "$l_img" ]] && img="$l_img" && return

  if [ ! -z "$intern" ]; then
    local l_img="$(searchImageCurrentPath $intern $systembase $systemsubbase)"
    [[ -n "$l_img" ]] && img="$l_img" && return
    local l_img="$(searchImageCurrentPath $intern $systemsubbase $systemsubbase)"
    [[ -n "$l_img" ]] && img="$l_img" && return
  fi

  if [ -d "$sdcard/linux" ]; then
    local l_img="$(searchImageCurrentPath $sdcard/linux $systembase $systemsubbase)"
    [[ -n "$l_img" ]] && img="$l_img" && return
    local l_img="$(searchImageCurrentPath $sdcard/linux $systemsubbase $systemsubbase)"
    [[ -n "$l_img" ]] && img="$l_img" && return
  fi

  if [ -d "$intern/linux" ]; then
    local l_img="$(searchImageCurrentPath $intern/linux $systembase $systemsubbase)"
    [[ -n "$l_img" ]] && img="$l_img" && return
    local l_img="$(searchImageCurrentPath $intern/linux $systemsubbase $systemsubbase)"
    [[ -n "$l_img" ]] && img="$l_img" && return
  fi

  if [ -d "$sdcard/linuxonandroid" ]; then
    local l_img="$(searchImageCurrentPath $sdcard/linuxonandroid $systembase $systemsubbase)"
    [[ -n "$l_img" ]] && img="$l_img" && return
    local l_img="$(searchImageCurrentPath $sdcard/linuxonandroid $systemsubbase $systemsubbase)"
    [[ -n "$l_img" ]] && img="$l_img" && return
  fi

  if [ -d "$intern/linuxonandroid" ]; then
    local l_img="$(searchImageCurrentPath $intern/linuxonandroid $systembase $systemsubbase)"
    [[ -n "$l_img" ]] && img="$l_img" && return
    local l_img="$(searchImageCurrentPath $intern/linuxonandroid $systemsubbase $systemsubbase)"
    [[ -n "$l_img" ]] && img="$l_img" && return
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


