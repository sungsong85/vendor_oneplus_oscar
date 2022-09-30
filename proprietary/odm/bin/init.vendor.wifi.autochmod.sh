#!/vendor/bin/sh
#***********************************************************
#** Copyright (C), 2019-2029, OPLUS Mobile Comm Corp., Ltd
#** All rights reserved.
#**
#** File: - vendor.wifi.autochmod.sh
#** Description: vendor domain operation
#**
#** Version: 1.1
#** Date : 2020/02/20
#** Author: JiaoBo
#** TAG: CONNECTIVITY.WIFI.BASIC.HARDWARE
#** ---------------------Revision History: ---------------------
#**  <author>    <data>       <version >       <desc>
#**  Jiao.Bo       2020/02/20     1.0     build this module
#****************************************************************/

config="$1"

#ifdef OPLUS_FEATURE_WIFI_DUMP
#JiaoBo@CONNECTIVITY.WIFI.BASIC.LOG.1162003, 2018/7/02
#add for wifi dump related log collection and DCS handle, dynamic enable/disable wifi core dump, offer trigger wifi dump API.
QCOM_DUMP_PATH="/data/vendor/tombstones/rfs/modem/*"
QCOM_ATOLL_DUMP_PATH="/data/vendor/ramdump/ramdump_wlan*"
MTK_DUMP_PATH="/data/vendor/connsyslog/wifi/*"
function clearWifiDumpFile() {
    local platform=`getprop ro.board.platform`
    if [[ $platform == *"mt"* ]] || [[ $platform == *"Mt"*  ]] || [[ $platform == *"MT"*  ]];then
        rm -rf $MTK_DUMP_PATH
    else
        if [ "x${platform}" == "xatoll" ];then
            rm -rf $QCOM_ATOLL_DUMP_PATH
        else
            rm -rf $QCOM_DUMP_PATH
        fi
    fi
}

# suppot: 1. qcom minidump; 2. mtk soc3 coredump; 3. mtk soc2 coredump
function triggerwifidump() {
    platform=`getprop ro.board.platform`
    if [[ $platform == *"mt"* ]] || [[ $platform == *"Mt"*  ]] || [[ $platform == *"MT"*  ]];then
        echo "mtk trigger firmware assert"
        if ["$platform" = 'mt6779'] || ["$platform" = 'mt6853'] || ["$platform" = 'mt6873'] || ["$platform" = 'mt6771'] ; then
            echo DB9DB9 > /proc/driver/wmt_dbg
            echo 4 0 > /proc/driver/wmt_dbg
        elif ["$platform" = 'mt6885'] || ["$platform" = 'mt6889']; then
            /odm/bin/iwpriv_vendor wlan0 driver 'SET_WFSYS_RESET'
        else
            echo "unsupport platform."
        fi
    else
        echo "qcom trigger firmware assert"
            /odm/bin/iwpriv wlan0 crash_inject 1 0
    fi
}
#endif /* OPLUS_FEATURE_WIFI_DUMP */

case "$config" in
    #ifdef OPLUS_FEATURE_WIFI_DUMP
    #JiaoBo@CONNECTIVITY.WIFI.BASIC.LOG.1162003, 2018/7/02
    #add for wifi dump related log collection and DCS handle, dynamic enable/disable wifi core dump, offer trigger wifi dump API.
    "clearWifiDumpFile")
    clearWifiDumpFile
    ;;
    "triggerwifidump")
    triggerwifidump
    ;;
    #endif /* OPLUS_FEATURE_WIFI_DUMP */
esac
