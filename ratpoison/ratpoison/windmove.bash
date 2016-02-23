#!/bin/bash

ratpoison -c "windows %s%a"|grep -q "*emacs"

if [ $? -eq 0 ] ; then
    case $1 in
	"left") emacsclient -e "(go-window-left)";;
	"right") emacsclient -e "(go-window-right)";;
	"up") emacsclient -e "(go-window-up)";;
	"down") emacsclient -e "(go-window-down)";;
	*) ;;
    esac 
else
    case $1 in
	"left") ratpoison -c "focusleft" ;;
	"right") ratpoison -c "focusright" ;; 
	"up") ratpoison -c "focusup" ;;
	"down") ratpoison -c "focusdown" ;;
	*) ;;
    esac
fi
