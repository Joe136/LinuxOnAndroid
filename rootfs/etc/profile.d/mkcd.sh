#!/bin/bash



##---------------------------Start function_checkArguments--------------------##
function mkcd()
{
   local folder_name=""
   local curr_arg=""
   local arg_rest
   unset arg_rest

   #[[ -z "$1" ]] && echo "error: no foldername defined" && exit 1
   local BASH_ARGV_
   unset BASH_ARGV_
   local BASH_ARGC_="$#"
   local i=1
   for curr_arg in "$@"; do
      BASH_ARGV_[$i]="$curr_arg"
      i=$((i + 1))
   done

   ##---------------------------Check Arguments-------------------------------##
   local i=0
   local arg_rest_count=0
   until test "$((i < BASH_ARGC_))" == "0"; do
      i=$((i + 1))
      curr_arg="${BASH_ARGV_[$i]}"

      if [ -z "$curr_arg" ]; then
         :
      elif [ "$curr_arg" == "-h" ] || [ "$curr_arg" == "--help" ]; then
         echo "$(basename "$0") [OPTION]... DIRECTORY"
         echo "make directory and change into it"
         echo ""
         mkdir --help
         arg_help=true
         return 0
         break
      elif [ "$(echo "$curr_arg" | head -c 2)" == "--" ];then
         case "$curr_arg" in
         ##-----------------------Mode----------------------------------------##
         --mode=*)
            arg_rest[$arg_rest_count]="$curr_arg"
            arg_rest_count=$((arg_rest_count + 1))
         ;;
         ##-----------------------Parents-------------------------------------##
         --parents)
            arg_rest[$arg_rest_count]="$curr_arg"
            arg_rest_count=$((arg_rest_count + 1))
         ;;
         ##-----------------------Verbose-------------------------------------##
         --verbose)
            arg_rest[$arg_rest_count]="$curr_arg"
            arg_rest_count=$((arg_rest_count + 1))
         ;;
         ##-----------------------Context-------------------------------------##
         --context=*)
            arg_rest[$arg_rest_count]="$curr_arg"
            arg_rest_count=$((arg_rest_count + 1))
         ;;
         ##-----------------------Unknown Argument----------------------------##
         *)
            echo -e "$(basename "$0"): unknown argument: $curr_arg\n"
            return 2 #TODO set the standard return value for this case
         ;;
         esac
      elif [ "$(echo -"$curr_arg" | head -c 2)" == "--" ];then
         args="$(echo -"$curr_arg" | awk 'BEGIN{FS=""}{ for (i = 3; i <= NF; ++i) print $i; }')"

         for arg in `echo -e "$args"`; do
            case "$arg" in
            ##--------------------Mode----------------------------------------##
            m)
               i=$((i + 1))
               arg_rest[$arg_rest_count]="--mode=${BASH_ARGV_[$i]}"
               arg_rest_count=$((arg_rest_count + 1))
            ;;
            ##--------------------Parents-------------------------------------##
            p)
               arg_rest[$arg_rest_count]="--parents"
               arg_rest_count=$((arg_rest_count + 1))
            ;;
            ##--------------------Verbose-------------------------------------##
            v)
               arg_rest[$arg_rest_count]="-v"
               arg_rest_count=$((arg_rest_count + 1))
            ;;
            ##--------------------Context-------------------------------------##
            Z)
               i=$((i + 1))
               arg_rest[$arg_rest_count]="--context=${BASH_ARGV_[$i]}"
               arg_rest_count=$((arg_rest_count + 1))
            ;;
            ##--------------------Unknown-------------------------------------##
            *)
               echo -e "$(basename "$0"): unknown argument: -$arg\n"
               return 2 #TODO set the standard return value for this case
            ;;
            esac
         done
      else
         if [ "$((i != 0))" == "1" ]; then
            if [ -z "$folder_name" ]; then
               arg_rest[$arg_rest_count]="$curr_arg"
               arg_rest_count=$((arg_rest_count + 1))
               folder_name="$curr_arg"
            else
               echo -e "$(basename "$0"): multiple names defined\n"
            fi
         fi

         ##-----------------------Unknown Argument----------------------------##
         #echo -e "$0: unknown argument: $curr_arg\n"
         #"$0" -h
         #return 2 #TODO set the standard return value for this case
      fi
   done


   [[ -z "$folder_name" ]] && echo "error: no foldername defined" && return 3


   mkdir "${arg_rest[@]}" && cd "$folder_name"
} #end Fct

