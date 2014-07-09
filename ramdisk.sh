#!/bin/bash

# Copyright (c) 2014, Franjo Žilić
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
# 
# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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
