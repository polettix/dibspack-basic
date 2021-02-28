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
while [ $# -gt 0 ] ; do
   case "$1" in
      (--suexec|--dockexec|--profilexec)
         name="${1#--}"
         $SUDO cp "$basedir/wrapexec/$name" /
         $SUDO chmod +x "/$name"
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

# This must be already provided in the environment
install_packages "$@"
