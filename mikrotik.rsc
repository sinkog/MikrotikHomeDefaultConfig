# may/23/2015 22:21:52 by RouterOS 6.28
#
/interface bridge
add admin-mac=4C:5E:0C:A7:17:AA auto-mac=no mtu=1500 name=lan
/interface wireless
set [ find default-name=wlan1 ] band=2ghz-b/g/n channel-width=\
    20/40mhz-ht-above disabled=no distance=indoors l2mtu=2290 mode=ap-bridge \
    ssid=Mikrotik_Home wireless-protocol=802.11
/interface ethernet
set [ find default-name=ether1 ] name=wan
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
add address-pool=dhcp disabled=no interface=lan name=default
/interface bridge port
add bridge=lan interface=ether2-master-local
add bridge=lan interface=wlan1
/ip address
add address=192.168.1.1/24 comment="default configuration" interface=\
    lan network=192.168.1.0
/ip dhcp-client
set 0 disabled=yes
add dhcp-options=hostname,clientid interface=wan
/ip dhcp-server network
add address=192.168.1.0/24 comment="default configuration" dns-server=\
    192.168.1.1 gateway=192.168.1.1 netmask=24
add address=192.168.0.0/24 comment="Server section" dns-server=\
    192.168.0.254 gateway=192.168.0.1 netmask=24
/ip dhcp-server lease
add address=192.168.0.1 client-id="server" server=default\
    mac-address=XX:XX:XX:XX:XX:XX
/ip firewall filter
add chain=input disabled=yes
add chain=input in-interface=!wan
add chain=input connection-state=established,related
add chain=input connection-state=new limit=10/1m,5 protocol=icmp
add chain=input connection-state=new dst-port=22 limit=3,5 protocol=tcp
add chain=input connection-state=new dst-port=8291 limit=3,5 protocol=tcp
add chain=input connection-state=new dst-port=1723 limit=3,5 protocol=tcp
add action=jump chain=input  connection-state=new in-interface=wan jump-target=block

add chain=forward disabled=yes
add chain=forward connection-state=established,related
add chain=forward in-interface=lan connection-state=new
add chain=forward connection-state=new dst-port=22 limit=3,5 protocol=tcp
add action=jump chain=forward connection-state=new in-interface=wan jump-target=block

add chain=block address-list-timeout=10m connection-state=new src-address-list=!block\
    action=add-src-to-address-list address-list=block 
add address-list-timeout=1d connection-state=new src-address-list=block\
    chain=block action=add-src-to-address-list address-list=block 
add action=drop chain=block

/ip firewall nat
add action=dst-nat chain=dstnat dst-address=127.0.0.1 to-addresses=192.168.0.1
add action=masquerade chain=srcnat out-interface=wan to-addresses=0.0.0.0
/system clock
set time-zone-name=Europe/Budapest

/system scheduler
add comment="" disabled=yes interval=1m name=checkIP on-event="/system script run checkIP"\
    policy=ftp,reboot,read,write,policy,test,winbox,password,sniff,sensitive

/system script
add name=done policy=\
    ftp,reboot,read,write,policy,test,winbox,password,sniff,sensitive source="\
    :global test\r\
    \n{ :put [:resolve www.google.com]; :set test true;}\r\
    \n:put \$test\r\
    \n"

add name=checkIP policy=\
    ftp,reboot,read,write,policy,test,winbox,password,sniff,sensitive source="\
    :global previousIP\r\
    \n:global test false\r\
    \n/system script run done\r\
    \n\r\
    \n\r\
    \n# get the current IP address from the internet (in case of double-nat)\
    \n/tool fetch mode=http address=\"checkip.dyndns.org\" src-path=\"/\" dst-\
    path=\"/dyndns.checkipx.html\"\
    \n:local result [/file get dyndns.checkipx.html contents]\
    \n\
    \n# parse the current IP result\
    \n:local resultLen [:len \$result]\
    \n:local startLoc [:find \$result \": \" -1]\
    \n:set startLoc (\$startLoc + 2)\
    \n:local endLoc [:find \$result \"</body>\" -1]\
    \n:global currentIP \r\
    \n:if (!\$test) do={:set currentIP \"127.0.0.0\";} else={:set currentIP [:\
    pick \$result \$startLoc \$endLoc];}\
    \n#:log info \"IP actual: \$currentIP\"\r\
    \n\r\
    \nif (\$currentIP != \$previousIP) do={\r\
    \n:if (\$currentIP =\"127.0.0.0\") do={:set previousIP \$currentIP;:put \"drop connection\"} else={\r\
    \n:log info \"Update need\"\r\
    \n/ip firewall nat set 1 dst-address=\$currentIP\r\
    \n} } else={\
    \n;\r\
    \n#:log info \"Previous IP: \$previousIP and current \$currentIP equal, no update need\"\r\
    \n:put  \"Previous IP: \$previousIP and current \$currentIP equal, no update need\"\
    \n}\r\
    \n\r\
    \n\r\
    \n# get the current IP address from the internet (in case of double-nat)\
    \n/tool fetch mode=http address=\"checkip.dyndns.org\" src-path=\"/\" dst-\
    path=\"/dyndns.checkipx.html\"\
    \n:local result [/file get dyndns.checkipx.html contents]\
    \n\
    \n# parse the current IP result\
    \n:local resultLen [:len \$result]\
    \n:local startLoc [:find \$result \": \" -1]\
    \n:set startLoc (\$startLoc + 2)\
    \n:local endLoc [:find \$result \"</body>\" -1]\
    \n:global currentIP \r\
    \n:if (!\$test) do={:set currentIP \"127.0.0.0\";} else={:set currentIP [:\
    pick \$result \$startLoc \$endLoc];}\
    \n#:log info \"IP actual: \$currentIP\"\r\
    \n\r\
    \nif (\$currentIP != \$previousIP) do={\r\
    \n:if (\$currentIP =\"127.0.0.0\") do={:set previousIP \$currentIP;:put \"drop connection\"} else={\r\
    \n:log info \"Update need\"\r\
    \n/ip firewall nat set 0 dst-address=\$currentIP\r\
    \n} } else={\
    \n;\r\
    \n#:log info \"Previous IP: \$previousIP and current: \$currentIP equal, no update need\"\r\
    \n:put  \"Previous IP: \$previousIP and current_ \$currentIP equal, no update need\"\
    \n}\r\
    \n}"


