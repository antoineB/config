#!/bin/bash

ratpoison -c "windows %s%a"|grep -q "*$1"

if [ $? -eq 0 ] ; then
    true
else
    false
fi
