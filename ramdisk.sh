#!/bin/bash

_size=
_unit=K

usage() {
  echo """Usage: $0 -s <size> -G -M -K 
  -s size of ramdisk  
  -G - in gigabytes 
  -M - in megabytes
  -K - in kilobytes (default)
""" >&2
}

_options=":s:GMKh"

while getopts $_options _option; do
  case $_option in 
    s )
      _size=$OPTARG
      ;;
    G )
      _unit=G
      ;;
    M )
      _unit=M
      ;;
    K )
      _unit=K
      ;;
    h )
      usage
      exit 0
      ;;
    \? )
      echo "Error. Unknown option: -$OPTARG" >&2
      exit 1
      ;;
    : )
      echo "Error. Missing option argument for -$OPTARG" >&2
      exit 1
      ;;
  esac 
done


if [ -z "$_size" ]; then
  usage
  exit 1
fi 

_sector_size="512"

case $_unit in 
  G )
    _sectors=$(echo "$_size * 1024 * 1024 * 1024 / 512 " | bc)
    ;;
  M ) 
    _sectors=$(echo "$_size * 1024 * 1024 / 512 " | bc)
    ;;
  K ) 
    _sectors=$(echo "$_size * 1024 / 512 " | bc)
    ;;
  : )
    echo "Unknown unit $_unit" >&2
    exit 1
    ;;
esac

#echo $_sectors
_ramdev=$(hdiutil attach -nomount ram://$_sectors)
newfs_hfs -v "RAM-$_size$_unit" $_ramdev 

if [ ! -e "/tmp/${_ramdev##*/}" ]; then
  mkdir /tmp/${_ramdev##*/}
fi 

mount -t hfs $_ramdev /tmp/${_ramdev##*/}
