#!/bin/sh
#2019 - mattlawer & adde88

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/sd/lib:/sd/usr/lib
export PATH=$PATH:/sd/usr/bin:/sd/usr/sbin

[[ -f /tmp/BessideNG.progress ]] && {
  exit 0
}

touch /tmp/BessideNG.progress
mkdir -p /tmp/BessideNG
wget https://github.com/adde88/aircrack-ng-openwrt/tree/master/bin/ar71xx/packages/base -P /tmp/BessideNG
AIRMON=`grep -F "airmon-ng_" /tmp/BessideNG/base | awk {'print $5'} | awk -F'"' {'print $2'}`
AIRCRACK=`grep -F "aircrack-ng_" /tmp/BessideNG/base | awk {'print $5'} | awk -F'"' {'print $2'}`

if [ "$1" = "install" ]; then
  if [ "$2" = "internal" ]; then
	wget https://github.com/adde88/aircrack-ng-openwrt/raw/master/bin/ar71xx/packages/base/"$AIRMON" -P /tmp/BessideNG
	wget https://github.com/adde88/aircrack-ng-openwrt/raw/master/bin/ar71xx/packages/base/"$AIRCRACK" -P /tmp/BessideNG
	opkg update
	opkg install /tmp/BessideNG/*.ipk --force-overwrite
  elif [ "$2" = "sd" ]; then
	wget https://github.com/adde88/aircrack-ng-openwrt/raw/master/bin/ar71xx/packages/base/"$AIRMON" -P /tmp/BessideNG
	wget https://github.com/adde88/aircrack-ng-openwrt/raw/master/bin/ar71xx/packages/base/"$AIRCRACK" -P /tmp/BessideNG
	opkg update
	opkg install /tmp/BessideNG/*.ipk --force-overwrite --dest sd
  fi

  touch /etc/config/BessideNG
  echo "config BessideNG 'module'" > /etc/config/BessideNG
  echo "config BessideNG 'run'" >> /etc/config/BessideNG
  echo "config BessideNG 'autostart'" >> /etc/config/BessideNG

  uci set BessideNG.module.installed=1
  uci commit BessideNG.module.installed

elif [ "$1" = "remove" ]; then
  rm -rf /etc/config/BessideNG
fi

rm /tmp/BessideNG.progress
rm -rf /tmp/BessideNG
