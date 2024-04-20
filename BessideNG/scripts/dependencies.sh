#!/bin/sh
#2019 - mattlawer & adde88

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/sd/lib:/sd/usr/lib
export PATH=$PATH:/sd/usr/bin:/sd/usr/sbin

[[ -f /tmp/BessideNG.progress ]] && {
  exit 0
}

touch /tmp/BessideNG.progress

if [ "$1" = "install" ]; then
  if [ "$2" = "internal" ]; then
    #opkg remove aircrack-ng-hak5
    opkg install pciutils
    opkg install airmon-ng
    opkg install aircrack-ng
  elif [ "$2" = "sd" ]; then
    #opkg remove aircrack-ng-hak5
    opkg --dest sd install pciutils
    opkg --dest sd install airmon-ng
    opkg --dest sd install aircrack-ng
  fi

  touch /etc/config/BessideNG
  echo "config BessideNG 'module'" > /etc/config/BessideNG
  echo "config BessideNG 'run'" >> /etc/config/BessideNG
  echo "config BessideNG 'autostart'" >> /etc/config/BessideNG

  uci set BessideNG.module.installed=1
  uci commit BessideNG.module.installed

elif [ "$1" = "remove" ]; then
  # Would probably break other packages
  #opkg remove airmon-ng
  #opkg remove aircrack-ng
  rm -rf /etc/config/BessideNG
fi

rm -rf /tmp/BessideNG.progress
