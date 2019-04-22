#!/bin/sh
#2019 - mattlawer & adde88

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/sd/lib:/sd/usr/lib
export PATH=$PATH:/sd/usr/bin:/sd/usr/sbin

if [ "$1" = "start" ]; then
  MYTIME=`date +%s`
  MYINTERFACE=`uci get BessideNG.run.interface`
  RUNFOLDER=/pineapple/modules/BessideNG/log/${MYTIME}
	mkdir -p ${RUNFOLDER}
  LOG=${RUNFOLDER}/infos.log

  if [ -z "$MYINTERFACE" ]; then
    MYINTERFACE=`iwconfig 2> /dev/null | grep "mon*" | awk '{print $1}'`
    if [ -z "$MYINTERFACE" ]; then
      IFACE=`iwconfig 2> /dev/null | grep "wlan*" | grep -v "mon*" | awk '{print $1}'`
      airmon-ng start ${IFACE}
      MYINTERFACE=`iwconfig 2> /dev/null | grep "mon*" | awk '{print $1}' | grep ${IFACE}`
    fi
  else
    MYFLAG=`iwconfig 2> /dev/null | grep "mon*" | awk '{print $1}' | grep ${MYINTERFACE}`
    if [ -z "$MYFLAG" ]; then
      airmon-ng start ${MYINTERFACE}
      MYINTERFACE=`iwconfig 2> /dev/null | grep "mon*" | awk '{print $1}' | grep ${MYINTERFACE}`
    else
      MYINTERFACE=${MYFLAG}
    fi
  fi

  uci set BessideNG.run.interface=`echo ${MYINTERFACE} | sed -e 's/\(mon\)*$//g'`
  uci set BessideNG.run.log=${MYTIME}
  uci commit BessideNG.run.interface
  uci commit BessideNG.run.log
  
  echo -e "$(date +'%d/%m/%y %H:%M:%S') starting manually" >> ${LOG}
  echo -e "interface : ${MYINTERFACE}" >> ${LOG}
  
  cd ${RUNFOLDER}
  besside-ng ${MYINTERFACE} &> /dev/null &
  cd -
  echo -e "running from ${RUNFOLDER}" >> ${LOG}
elif [ "$1" = "stop" ]; then
  MYTIME=`uci get BessideNG.run.log`
	RUNFOLDER=/pineapple/modules/BessideNG/log/${MYTIME}
	LOG=${RUNFOLDER}/infos.log

	if [ -f ${LOG} ]; then
		echo -e " - stopping -" >> ${LOG}
	fi
  killall -9 besside-ng
fi
