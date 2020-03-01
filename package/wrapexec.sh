#!/bin/sh

while [ $# -gt 0 ] ; do
   case "$1" in
      (--suexec|--dockexec|--profilexec)
         $SUDO cp "$(dirname "$0")/../wrapexec/${1#--}" /
         $SUDO chmod +x "/${1#--}"
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
