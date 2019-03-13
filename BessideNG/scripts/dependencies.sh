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
    curl https://raw.githubusercontent.com/adde88/besside-ng_pineapple/master/besside-ng -o /usr/bin/besside-ng
	  chmod +x /usr/bin/besside-ng
  elif [ "$2" = "sd" ]; then
	  curl https://raw.githubusercontent.com/adde88/besside-ng_pineapple/master/besside-ng -o /sd/usr/bin/besside-ng
	  chmod +x /sd/usr/bin/besside-ng
  fi

  touch /etc/config/BessideNG
  echo "config BessideNG 'module'" > /etc/config/BessideNG
  echo "config BessideNG 'run'" >> /etc/config/BessideNG
  echo "config BessideNG 'autostart'" >> /etc/config/BessideNG

  uci set BessideNG.module.installed=1
  uci commit BessideNG.module.installed

elif [ "$1" = "remove" ]; then
  rm -rf /usr/bin/besside-ng
	rm -rf /sd/usr/bin/besside-ng
  rm -rf /etc/config/BessideNG
fi

rm -rf /tmp/BessideNG