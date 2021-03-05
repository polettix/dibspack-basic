#!/bin/sh
exec 1>&2
set -e

script="$(readlink -f "$0")"
scriptdir="$(dirname "$script")"
basedir="$(dirname "$scriptdir")"

. "$basedir/lib.sh"
export_all_enviles

# This must be already provided in the environment
update_package_database

# Cope with "virtual" pacakges from dibspack-basic
modules_list=''
while [ $# -gt 0 ] ; do
   case "$1" in
      (--suexec|--dockexec|--profilexec)
         name="${1#--}"
         $SUDO cp "$basedir/wrapexec/$name" /
         $SUDO chmod +x "/$name"
         shift
         ;;
      (-f|--from)
         [ $# -gt 1 ] || LOGDIE "cannot honor $1"
         shift
         modules_list="$modules_list $(encode_array $(cat "$1"))"
         shift
         ;;
      (--)
         shift
         break
         ;;
      (*)
         break
         ;;
   esac
done

[ $# -eq 0 ] || modules_list="$modules_list $(encode_array "$@")"
eval "set -- $modules_list"

# This must be already provided in the environment
install_packages "$@"
