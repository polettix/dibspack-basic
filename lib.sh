#!/bin/sh

# logging & die-ing
__log() {
   local LEVEL="$1"
   [ "$LEVEL" -le "${LOGLEVEL:=4}" ] || return 0
   LEVEL="$2"
   shift 2
   printf >&2 '[%s] [%-5s] %s\n' \
      "$(date +'%Y-%m-%d %H:%M:%S')" "$LEVEL" "$*"
}
LOGLEVEL() {
   case "$1" in
      (NONE)  LOGLEVEL=0 ;;
      (FATAL) LOGLEVEL=1 ;;
      (ERROR) LOGLEVEL=2 ;;
      (WARN)  LOGLEVEL=3 ;;
      (INFO)  LOGLEVEL=4 ;;
      (DEBUG) LOGLEVEL=5 ;;
      (TRACE) LOGLEVEL=6 ;;
   esac
}
ALWAYS() { __log 0 '*****' "$*" ; }
FATAL()  { __log 1 'FATAL' "$*" ; }
ERROR()  { __log 2 'ERROR' "$*" ; }
WARN()   { __log 2 'WARN'  "$*" ; }
INFO()   { __log 4 'INFO'  "$*" ; }
DEBUG()  { __log 5 'DEBUG' "$*" ; }
TRACE()  { __log 6 'TRACE' "$*" ; }
LOGDIE() { FATAL "$*" ;  exit 1 ; }

architecture() { sed -n 's/^ID=//p' /etc/os-release ; }

escape_var_value() {
   local value=$1
   printf '%s' "'"
   while : ; do
      case "$value" in
         (*\'*)
            printf '%s%s' "${value%%\'*}" "'\\''"
            value=${value#*\'}
            ;;
         (*)
            printf '%s' "$value"
            break
            ;;
      esac
   done
   printf '%s' "'"
}

dump_env() {
   while [ "$#" -gt 0 ] ; do
      local name=$1 value
      shift 1
      eval "value=\$$name"
      printf '%s=' "$name"
      escape_var_value "$value"
      printf '\n'
   done
}

encode_array() {
   local i
   for i do
      escape_var_value "$i"
      printf ' \\\n'
   done
   printf ' \n'
}

encode_array_sed() {
   for i do
      printf %s\\n "$i" | sed "s/'/'\\\\''/g;1s/^/'/;\$s/\$/' \\\\/"
   done
   echo " "
}

if grep ff5ea532388b803964a75cf9ec1b57e338bd -- "$0" >/dev/null 2>&1 ; then
   "$@"
fi
