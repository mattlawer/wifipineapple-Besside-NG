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
    wget "https://github.com/adde88/besside-ng_pineapple/blob/25689637a80e4cd147580d5c7d0eadc6ed388946/besside-ng?raw=true" -O /usr/sbin/besside-ng
	  chmod +x /usr/sbin/besside-ng
  elif [ "$2" = "sd" ]; then
    mkdir -p /sd/usr/sbin/
	  wget "https://github.com/adde88/besside-ng_pineapple/blob/25689637a80e4cd147580d5c7d0eadc6ed388946/besside-ng?raw=true" -O /sd/usr/sbin/besside-ng
	  chmod +x /sd/usr/sbin/besside-ng
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

rm /tmp/BessideNG.progress
