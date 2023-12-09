#!/bin/bash

set -e

include=""
if [ -n $2 ]
then
  include="-I ${$2}"
fi

verbosity=""
if [ $3 == "normal" ]
then
  verbosity="-v"
elif [ $3 == "high" ]
  verbosity="-vv"
fi

falco $1 $include $verbosity $4
