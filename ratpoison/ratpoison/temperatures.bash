#!/bin/bash

function sens {
    sensors |grep "fan2\|temp1\|temp2\|temp3\|Core" \
	|tr -d ' ' |cut -d '(' -f1  \
	|sed s/fan2:/fan-----/ \
  	|sed s/temp1:/MB-----/ \
	|sed s/temp2:/CPU----/ \
	|sed s/temp3:/alim---/ \
	|sed s/Core0:/Core0--/ \
	|sed s/Core1:/Core1--/ \
	|sed s/RPM// \
	|sed s/°C// ;

    aticonfig --odgt |grep Sensor |tr -d ' ' \
	|sed s/Sensor0:Temperature-/ATI----+/ \
	|sed s/0C// ;	
}

ratpoison -c "echo `sens`" ;