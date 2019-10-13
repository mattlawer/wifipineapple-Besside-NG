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
    wget "https://github.com/adde88/besside-ng_pineapple/raw/openwrt-19.07/besside-ng" -O /usr/sbin/besside-ng
    chmod +x /usr/sbin/besside-ng
    opkg install libpciaccess libhwloc
    cp /usr/lib/libhwloc.so.15* /usr/lib/libhwloc.so.15
    cp /usr/lib/libpciaccess.so.0*  /usr/lib/libpciaccess.so.0
  elif [ "$2" = "sd" ]; then
    mkdir -p /sd/usr/sbin/
    wget "https://github.com/adde88/besside-ng_pineapple/raw/openwrt-19.07/besside-ng" -O /sd/usr/sbin/besside-ng
    chmod +x /sd/usr/sbin/besside-ng
    opkg --dest sd install libpciaccess libhwloc
    cp /sd/usr/lib/libhwloc.so.15* /sd/usr/lib/libhwloc.so.15
    cp /sd/usr/lib/libpciaccess.so.0*  /sd/usr/lib/libpciaccess.so.0
  fi

  touch /etc/config/BessideNG
  echo "config BessideNG 'module'" > /etc/config/BessideNG
  echo "config BessideNG 'run'" >> /etc/config/BessideNG
  echo "config BessideNG 'autostart'" >> /etc/config/BessideNG

  uci set BessideNG.module.installed=1
  uci commit BessideNG.module.installed

elif [ "$1" = "remove" ]; then
  rm -rf /usr/sbin/besside-ng
  rm -rf /sd/usr/sbin/besside-ng
  rm -rf /etc/config/BessideNG
fi

rm -rf /tmp/BessideNG.progress
