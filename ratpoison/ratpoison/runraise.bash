#!/bin/bash


#NB=`ratpoison -c "windows %a" | grep "$1" | wc -l`;
#CURRENT=read file /tmp/ratpoison/switch/$1 creation du fichier avec 0 si il n'existe pas
#si le fichier exists:
#si CURRENT est supérieur ou egal a NB alors le mettre a 0
#incremente CURRENT et le sauvegarde
#SELECT=`ratpoison -c "windows %a %n" | grep "$1" | cut -d ' ' -f2 | tail -n +$CURRENT | head -n 1`;

ratpoison -c "windows %a"|grep -q $1

if [ $? -eq 0 ] ; then
#    echo "Value grep: $? . selecting"
    ratpoison -c "select $1"          
else
#    echo "Value grep: $? . starting"
    $2&                              
fi
