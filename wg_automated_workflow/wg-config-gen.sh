#!/bin/bash

p='wg-srv-peers.conf'
[ -f $p ] && rm -f $p

i='PNGs'
[ -d $i ] && rm -rf $i
mkdir $i

while IFS=, read -r ui ip
do
    echo "$ui and $ip"
    [ -d "$ui" ] && rm -rf $ui
    mkdir $ui && cd $ui
    wg genkey | tee $ui.key | wg pubkey | tee $ui.key.pub > /dev/null
    key=`cat $ui.key`
    pubkey=`cat $ui.key.pub`

echo "[Interface]
PrivateKey = $key
Address = $ip
DNS = 8.8.8.8, 8.8.4.4 
[Peer]
PublicKey = Ccd+Z/JBwktqy3i2wIfb+rwX9h0w4BO/fghOd7AcxFE=
AllowedIPs = 0.0.0.0/0
Endpoint = 11.22.33.44:51820
PersistentKeepalive = 25" >> $ui.conf

    qrencode -o $ui.png -t png < $ui.conf
    cp $ui.png ../$i/
    cd - > /dev/null

echo "[Peer]
# $ui wg
PublicKey = $pubkey
AllowedIPs = $ip/32
" >> $p

done < users-list.csv