#/bin/sh
rm -f /etc/opkg/nvpnc-feed.conf

killall python
killswitch=""
if [ -f /usr/lib/enigma2/python/Plugins/Extensions/NordVPNConnector/configs/killswitch ]; then
	killswitch=$(cat /usr/lib/enigma2/python/Plugins/Extensions/NordVPNConnector/configs/killswitch)
fi
if [ -d /usr/lib/enigma2/python/Plugins/Extensions/NordVPNConnector ]; then
	if [[ $killswitch == "route" ]]; then
		/usr/lib/enigma2/python/Plugins/Extensions/NordVPNConnector/configs/route_off
	fi
	/etc/init.d/openvpn stop
	killall openvpn
	if [ $(grep -c "config.plugins.nordvpn.standardDNS" /etc/enigma2/settings) -gt 0 ]; then
		dns=$(cat /etc/enigma2/settings|grep "config.plugins.nordvpn.standardDNS"|cut -d"=" -f2)
		echo "nameserver "$dns"\n"
	fi
	#if [[ $killswitch == "route" ]]; then
		#/usr/lib/enigma2/python/Plugins/Extensions/NordVPNConnector/configs/route_off
	#fi
	if [[ $killswitch == "iptables" ]]; then
		/usr/lib/enigma2/python/Plugins/Extensions/NordVPNConnector/configs/iptables_off
	fi
	rm -f /etc/openvpn/*
fi


if [ -f /usr/lib/enigma2/python/Plugins/Extensions/NordVPNConnector/configs/iptables_off ]; then
	/usr/lib/enigma2/python/Plugins/Extensions/NordVPNConnector/configs/iptables_off
	nvpnc=1
fi
#if [ -f /usr/lib/enigma2/python/Plugins/Extensions/NordVPNConnector/configs/route_off ]; then
	#/usr/lib/enigma2/python/Plugins/Extensions/NordVPNConnector/configs/route_off
#fi
#opkg update
echo "... remove nordvpnconnector"
opkg remove enigma2-plugin-extensions-nordvpnconnector
rm /var/lib/opkg/info/enigma2-plugin-extensions-nordvpnconnector*
if [ -d /usr/lib/enigma2/python/Plugins/Extensions/NordVPNConnector ]; then
	rm -rf /usr/lib/enigma2/python/Plugins/Extensions/NordVPNConnector
fi
opkg update
opkg install openvpn python-requests bash curl

if [ -f /etc/image-version ]; then
	reseller=$(cat /etc/image-version | grep creator | cut -d"=" -f2)
	reseller=${reseller,,}
	if [[ $reseller == *"vti"* ]] || [[ $reseller == *"newnigma2"* ]]; then
		vti=1
		echo "... Image is VTI or Newnigma2"
	else
		vti=0
		echo "... Image is not VTI or Newnigma2"
	fi
else
	vti=0
	echo "... Image is not VTI"
fi
if [[ "$vti" == 1 ]]; then
	echo "src/gz nvpnc http://nordvpnconnector.dd-dns.de/vti" > /etc/opkg/nvpnc-feed.conf
else
	echo "src/gz nvpnc http://nordvpnconnector.dd-dns.de/ipk" > /etc/opkg/nvpnc-feed.conf
fi
opkg update
opkg install enigma2-plugin-extensions-nordvpnconnector --force-depends
echo "" > /tmp/log.txt
sleep 3
if [[ $killswitch == "iptables" ]]; then
	echo "iptables" > /usr/lib/enigma2/python/Plugins/Extensions/NordVPNConnector/configs/killswitch
fi
if [[ $killswitch == "route" ]]; then
	echo "route" > /usr/lib/enigma2/python/Plugins/Extensions/NordVPNConnector/configs/killswitch
fi
if [ -f /etc/openvpn/update-resolv-conf ]; then
	rm -f /etc/openvpn/update-resolv-conf
	if [ -f /usr/lib/enigma2/python/Plugins/Extensions/NordVPNConnector/configs/update-resolv-conf ]; then
		cp /usr/lib/enigma2/python/Plugins/Extensions/NordVPNConnector/configs/update-resolv-conf /etc/openvpn
	fi
fi
sleep 3
#echo "... reboot receiver"
init 4
sleep 5
#init 6
init 3

