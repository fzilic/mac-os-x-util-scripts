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

_remote_user=
_remote_server=

_remote_dir=
_remote_pattern=

_local_command=

usage() {
  echo """Usage: $0 -s <remote_server> [-u <remote_user>] -d <remote_dir> [-p <remote_pattern>] [-c <local_command>] -h
  -s <remote_server> - host or ip of remote server
  -u <remote_user> - username to login as - optional
  -d <remote_dir> - directory on remote server to read files from
  -p <remote_pattern> - shell pattern to find files on remote system
  -h - this help
  """ >&2
}

_options=":s:u:d:p:c:h"


while getopts $_options _option; do
  case $_option in 
    s )
      _remote_server=$OPTARG
      ;;
    u )
      _remote_user=$OPTARG
      ;;
    d )
      _remote_dir=$OPTARG
      ;;
    p )
      _remote_pattern=$OPTARG
      ;;
    c )
      _local_command=$OPTARG
      ;;
    h )
      usage
      exit 1
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

if [ -z "$_remote_server" ]; then
  usage
  echo """
    Unable to run without knowing remote server""" >&2
  exit 1
fi

if [ -z "$_remote_dir" ]; then
  usage
  echo """
    Unable to read file from directory if directory not known.""" >&2
  exit 1
fi

if [ -z "$_remote_pattern" ]; then
  _remote_pattern="*"
fi

if [ -z "$(which ssh)" ]; then
  echo """Missing ssh executable, unable to run.""" >&2
  exit 1
fi

_ssh_command="ssh "

if [ -n "$_remote_user" ]; then
  _ssh_command=$_ssh_command" "$_remote_user"@"
fi

_ssh_command=$_ssh_command$_remote_server

_remote_dir=${_remote_dir%/}

_files=$($_ssh_command "ls $_remote_dir/$_remote_pattern")

if [ "$?" -ne "0" ]; then
  echo """Unable to list files on $_remote_server in $_remote_dir with $_remote_pattern""" >&2
  exit 1
fi

for _file in ${_files[@]}; do

  if [[ "$_file" == *.gz ]]; then
    _remote_cat=" zcat " 
  else
    _remote_cat=" cat " 
  fi   
  _remote_cat=$_remote_cat" $_file" 

  if [ -n "$_local_command" ]; then
    $_ssh_command "$_remote_cat" | $_local_command
  else 
    echo $_test
    $_ssh_command "$_remote_cat" 
  fi 
done


