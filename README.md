# wifipineapple-Besside-NG

besside-ng module for the WiFi Pineapple using besside-ng binaries from [github.com/adde88/besside-ng_pineapple](https://github.com/adde88/besside-ng_pineapple).

## How to Install

1) Connect to your WiFi Pineapple Management AP
2) SCP the BessideNG directory in /pineapple/modules/ on the WiFi Pineapple. 

![SCP](https://raw.githubusercontent.com/mattlawer/wifipineapple-Besside-NG/master/screenshots/scp.png)

        scp -r BessideNG root@172.16.42.1:/pineapple/modules/
    
1) SSH into the WiFi Pineapple to change the owner and permissions

![SSH](https://raw.githubusercontent.com/mattlawer/wifipineapple-Besside-NG/master/screenshots/ssh.png)

        # Change owner of the module
        chown -R 100:118 /pineapple/modules/BessideNG/

        # Add execute permission to the scripts
        chmod +x /pineapple/modules/BessideNG/scripts/*

1) Refresh the WiFi Pineapple web interface, go to Modules->Besside-NG and click install.

`You need a wireless interface in monitor mode to launch besside-ng, or just enable 'Start on boot' and reboot, the script will set a wlan interface in monitor mode for you at boot`

![Preview](https://raw.githubusercontent.com/mattlawer/wifipineapple-Besside-NG/master/screenshots/preview.png)