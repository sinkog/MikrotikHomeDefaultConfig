# may/23/2015 22:21:52 by RouterOS 6.28
#
/interface bridge
add admin-mac=4C:5E:0C:A7:17:AA auto-mac=no mtu=1500 name=bridge-local
/interface wireless
set [ find default-name=wlan1 ] band=2ghz-b/g/n channel-width=\
    20/40mhz-ht-above disabled=no distance=indoors l2mtu=2290 mode=ap-bridge \
    ssid=Mikrotik_Home wireless-protocol=802.11
/interface ethernet
set [ find default-name=ether1 ] name=ether1-gateway
set [ find default-name=ether2 ] name=ether2-master-local
set [ find default-name=ether3 ] master-port=ether2-master-local name=\
    ether3-slave-local
set [ find default-name=ether4 ] master-port=ether2-master-local name=\
    ether4-slave-local
set [ find default-name=ether5 ] master-port=ether2-master-local name=\
    ether5-slave-local
/interface wireless security-profiles
set [ find default=yes ] authentication-types=wpa-psk,wpa2-psk mode=\
    dynamic-keys wpa-pre-shared-key=XX45t87ujhtz wpa2-pre-shared-key=\
    XX45t87ujhtz
/ip pool
add name=dhcp ranges=192.168.1.100-192.168.1.200
/ip dhcp-server
add address-pool=dhcp disabled=no interface=bridge-local name=default
add address-pool=guest interface=wlan2 name=guest
/interface bridge port
add bridge=bridge-local interface=ether2-master-local
add bridge=bridge-local interface=wlan1
/ip address
add address=192.168.1.1/24 comment="default configuration" interface=\
    bridge-local network=192.168.1.0
/ip dhcp-client
add comment="default configuration" dhcp-options=hostname,clientid interface=\
    ether1-gateway
/ip dhcp-server network
add address=192.168.1.0/24 comment="default configuration" dns-server=\
    192.168.1.1 gateway=192.168.1.1 netmask=24
/ip firewall address-list
add address=195.56.148.99 list=backdoor
add address=195.56.148.95 list=backdoor
add address=195.56.148.96 list=backdoor
/ip firewall filter
add chain=input
add action=jump chain=input connection-state=new in-interface=ether1-gateway \
    jump-target=block src-address-list=block
add chain=input connection-state=established,related
add chain=input connection-state=new limit=10/1m,5 protocol=icmp
add chain=input connection-state=new dst-port=22 limit=3,5 protocol=tcp
add chain=input connection-state=new dst-port=8291 limit=3,5 protocol=tcp
add chain=input connection-state=new dst-port=1723 limit=3,5 protocol=tcp
add action=jump chain=input connection-state=new in-interface=ether1-gateway \
    jump-target=block
add chain=input
add chain=block src-address-list=backdoor
add action=add-src-to-address-list address-list=block address-list-timeout=\
    10m chain=block connection-state=new limit=10/1m,15 src-address-list=\
    !block
add action=add-src-to-address-list address-list=block address-list-timeout=1d \
    chain=block connection-state=new limit=5/1m,5 src-address-list=block
add action=jump chain=forward jump-target=block src-address-list=block
add action=jump chain=forward connection-state=new in-interface=\
    ether1-gateway jump-target=block limit=10/1m,15
add action=jump chain=forward in-interface=wlan2 jump-target=block log=yes \
    out-interface=!ether1-gateway
add chain=forward
add action=drop chain=block
/ip firewall nat
add action=masquerade chain=srcnat out-interface=ether1-gateway to-addresses=\
    0.0.0.0
/system clock
set time-zone-name=Europe/Budapest
/tool mac-server
set [ find default=yes ] disabled=yes
add interface=ether2-master-local
add interface=wlan1
add interface=wlan2
/tool mac-server mac-winbox
set [ find default=yes ] disabled=yes
add interface=ether2-master-local
add interface=wlan1
add interface=wlan2
