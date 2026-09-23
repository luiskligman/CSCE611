#!/usr/bin/env bash

# Copyright 2019 Charles Daniels

# CSCE611 front-end script

# change to project directory
cd "$(dirname "$0")"

LAB="riu"

# help by default
if [ $# -lt 1 ] ; then
	command="help"
else
	command="$1"
	shift
	parameters="$@"
fi

. ./scripts/csce611.shlib

csce611main

exit $?
