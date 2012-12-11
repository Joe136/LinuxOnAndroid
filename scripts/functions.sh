
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



currentscriptpath()
{
  local fullpath=`echo "$(readlink -f $0)"`
  local fullpath_length=`echo ${#fullpath}`
  local scriptname="$(basename "$fullpath")"
  local scriptname_length=`echo ${#scriptname}`
  local result_length=`echo $((fullpath_length - $scriptname_length - 1))`
  local result=`echo "$fullpath" | head -c $result_length`
  echo "$result"
}



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


