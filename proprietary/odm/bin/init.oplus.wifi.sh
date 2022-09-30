#! /vendor/bin/sh

# Copyright (c) 2010-2013, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#     * Neither the name of The Linux Foundation nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
# ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# This script will load and unload the wifi driver to put the wifi in
# in deep sleep mode so that there won't be voltage leakage.
# Loading/Unloading the driver only incase if the Wifi GUI is not going
# to Turn ON the Wifi. In the Script if the wlan driver status is
# ok(GUI loaded the driver) or loading(GUI is loading the driver) then
# the script won't do anything. Otherwise (GUI is not going to Turn On
# the Wifi) the script will load/unload the driver
# This script will get called after post bootup.

target="$1"
serialno="$2"

btsoc=""

if [ -s /odm/etc/wifi/cnss_diag.conf ] ; then
    cp /odm/etc/wifi/cnss_diag.conf /mnt/vendor/persist/wlan/cnss_diag.conf
    chmod 666 /mnt/vendor/persist/wlan/cnss_diag.conf
    sync
fi

#ifdef VENDOR_EDIT
#qiulei@PSW.CN.Wifi.Hardware,1065227 2018/06/18,
#Add for make bin Rom-update.
if [ -s /odm/etc/wifi/bin_version ]; then
    system_version=`cat /odm/etc/wifi/bin_version`
else
    system_version=1
fi

if [ -s /mnt/vendor/persist/bin_version ]; then
    persist_version=`cat /mnt/vendor/persist/bin_version`
else
    persist_version=1
fi

if [ ! -s /mnt/vendor/persist/bdwlan.bin  -o $system_version -gt $persist_version ]; then
    cp /odm/etc/wifi/bdwlan.bin /mnt/vendor/persist/bdwlan.bin
    echo "$system_version" > /mnt/vendor/persist/bin_version
    sync
fi

if [ $system_version -eq $persist_version ] ; then
    persistbdf=`md5sum /mnt/vendor/persist/bdwlan.bin |cut -d" " -f1`
    vendorbdf=`md5sum /odm/etc/wifi/bdwlan.bin |cut -d" " -f1`
    if [ x"$vendorbdf" != x"$persistbdf" ]; then
        cp /odm/etc/wifi/bdwlan.bin /mnt/vendor/persist/bdwlan.bin
        sync
        echo "bdf check"
    fi
fi

#ifdef VENDOR_EDIT
#Zuofa.Liu@PSW.CN.Wifi.Hardware,1065227 2020/06/24,
#Add for realme make bin Rom-update.
if [ -s /odm/etc/wifi/bin_version_realme ]; then
    system_version_realme=`cat /odm/etc/wifi/bin_version_realme`
else
    system_version_realme=1
fi

if [ -s /mnt/vendor/persist/bin_version_realme ]; then
    persist_version_realme=`cat /mnt/vendor/persist/bin_version_realme`
else
    persist_version_realme=1
fi

if [ ! -s /mnt/vendor/persist/bdwlan.bin  -o $system_version_realme -gt $persist_version_realme ]; then
    cp /odm/etc/wifi/bdwlan.bin /mnt/vendor/persist/bdwlan.bin
    echo "$system_version_realme" > /mnt/vendor/persist/bin_version_realme
    sync
fi

if [ $system_version_realme -eq $persist_version_realme ] ; then
    persistbdf=`md5sum /mnt/vendor/persist/bdwlan.bin |cut -d" " -f1`
    vendorbdf=`md5sum /odm/etc/wifi/bdwlan.bin |cut -d" " -f1`
    if [ x"$vendorbdf" != x"$persistbdf" ]; then
        cp /odm/etc/wifi/bdwlan.bin /mnt/vendor/persist/bdwlan.bin
        sync
        echo "bdf check"
    fi
fi
#endif /* VENDOR_EDIT */

chmod 666 /mnt/vendor/persist/bdwlan.bin
chown system:wifi /mnt/vendor/persist/bdwlan.bin

#shirong.han@PSW.CN.Wifi.Basic.configuration, bugid:2575427 2019/11/21
#change Russia b3 disable 100-128 channel
if [ -s /odm/etc/wifi/regdb_version ]; then
    system_regdbversion=`cat /odm/etc/wifi/regdb_version`
else
    system_regdbversion=1
fi

if [ -s /mnt/vendor/persist/regdb_version ]; then
    persist_regdbversion=`cat /mnt/vendor/persist/regdb_version`
else
    persist_regdbversion=1
fi

if [ ! -s /mnt/vendor/persist/regdb.bin  -o $system_regdbversion -gt $persist_regdbversion ]; then
    cp /odm/etc/wifi/regdb.bin /mnt/vendor/persist/regdb.bin
    echo "$system_regdbversion" > /mnt/vendor/persist/regdb_version
    sync
fi
chmod 666 /mnt/vendor/persist/regdb.bin
chown system:wifi /mnt/vendor/persist/regdb.bin

vendorRegdb=`md5sum /odm/etc/wifi/regdb.bin |cut -d" " -f1`
persistRegdb=`md5sum /mnt/vendor/persist/regdb.bin |cut -d" " -f1`
if [ x"$vendorRegdb" != x"$persistRegdb" ]; then
    cp /odm/etc/wifi/regdb.bin /mnt/vendor/persist/regdb.bin
    echo "$system_regBinversion" > /mnt/vendor/persist/regBin_version
    sync
    chmod 666 /mnt/vendor/persist/regdb.bin
    chown system:wifi /mnt/vendor/persist/regdb.bin
    echo "regdb check"
fi

#LiJunlong@CONNECTIVITY.WIFI.NETWORK.1065227,2020/08/07
mkdir /mnt/vendor/persist/wlan 0777 system system

reg_info=`getprop ro.vendor.oplus.euex.country`
if [ "w${reg_info}" = "wUA" ]; then
    sourceFile=/odm/vendor/etc/wifi/WCNSS_qcom_cfg_ua.ini
    echo "export UA file dir config"
else
    sourceFile=/odm/vendor/etc/wifi/WCNSS_qcom_cfg.ini
fi
targetFile=/mnt/vendor/persist/wlan/WCNSS_qcom_cfg.ini
#Yuan.Huang@PSW.CN.Wifi.Network.internet.1065227, 2016/11/09,
#Add for make WCNSS_qcom_cfg.ini Rom-update.
if [ -s "$sourceFile" ]; then
	system_version=`head -1 "$sourceFile" | grep OplusVersion | cut -d= -f2`
	if [ "${system_version}x" = "x" ]; then
		system_version=1
	fi
else
	system_version=1
fi

#LiJunlong@CONNECTIVITY.WIFI.NETWORK,1065227,2020/07/29,Add for rus ini
if [ -s /mnt/vendor/persist/wlan/qca_cld/WCNSS_qcom_cfg.ini ]; then
    cp  /mnt/vendor/persist/wlan/qca_cld/WCNSS_qcom_cfg.ini \
        $targetFile
    sync
    chown system:wifi $targetFile
    chmod 666 $targetFile
    rm -rf /mnt/vendor/persist/wlan/qca_cld
fi

if [ -s "$targetFile" ]; then
	persist_version=`head -1 "$targetFile" | grep OplusVersion | cut -d= -f2`
	if [ "${persist_version}x" = "x" ]; then
		persist_version=0
	fi
else
	persist_version=0
fi


if [ ! -s "$targetFile" -o $system_version -gt $persist_version ] || [ "w${reg_info}" = "wUA" ]; then
    cp $sourceFile  $targetFile
    sync
    chown system:wifi $targetFile
    chmod 666 $targetFile
fi

persistini=`cat "$targetFile" | grep -v "#" | grep -wc "END"`
if [ x"$persistini" = x"0" ]; then
    cp $sourceFile  $targetFile
    sync
    chown system:wifi $targetFile
    chmod 666 $targetFile
    echo "ini check"
fi
#endif /* VENDOR_EDIT */