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

LOG()  { printf >&2 '%s\n' "$*" ; }

os_id() { sed -n 's/^ID=//p' /etc/os-release ; }

is_detect() { [ "${1:-"$DIBSPACK_DETECT"}" = 'xdetect' ] ; }

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

export_envile() {
   local name="$(basename "$1")"
   local value="$(escape_var_value "$(cat "$1"; printf x)")"
   eval "export $name=${value%??}'"
}

export_enviles_from() {
   local base="${1%/}" file f
   shift
   for f in "$@" ; do
      file="$base/$f"
      [ -e "$file" ] && export_envile "$file"
   done
}

export_all_enviles_from() {
   local base="${1%/}" file varname
   for file in "$base"/* ; do
      varname="$(basename "$file")"
      if [ "${varname#*.}" = "$varname" ] && [ -f "$file" ] ; then
         export_envile "$file"
      fi
   done
}

export_all_enviles() {
   export_all_enviles_from "${DIBS_DIR_ENVILE:-"."}"
}

indent() { sed -e 's/^/       /' ; }

cleanup_dir() {
   (
      [ -n "$1" ] || LOGDIE "cleanup_dir: MUST receive directory as input"
      cd "$1"     || LOGDIE "cleanup_dir: cannot chdir into $1"
      chmod -R +w . || LOGDIE "cleanup_dir: cannot set write bit in $1"
      find -H . \! -name . -prune -exec rm -rf '{}' \;
   )
}

rm_forced() { [ -e "$1" ] && chmod -R +w "$1" ; rm -rf "$1" ; }

stubborn_rm_rf() {
   [ -e "$1" ] && chmod -R +w "$1"
   rm -rf "$1"
}

copy_to() {
   dst_root="$1"
   shift

   for src in "$@" ; do
      dst="$dst_root/$src"
      dst_dir="$(dirname "$dst")"
      [ -d "$dst_dir" ] || mkdir -p "$dst_dir"
      cp -pP "$src" "$dst"
   done
}

restore_permissions_from() {
   src_root="$1"
   shift

   for dir in "$@" ; do
      src="$src_root/$dir"
      chmod "$(stat -c '%a'    "$src")" "$dir"
      chown "$(stat -c '%u:%g' "$src")" "$dir"
   done
}

if grep ff5ea532388b803964a75cf9ec1b57e338bd -- "$0" >/dev/null 2>&1 ; then
   "$@"
fi
