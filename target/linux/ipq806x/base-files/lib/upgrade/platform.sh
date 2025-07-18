PART_NAME=firmware
REQUIRE_IMAGE_METADATA=1

RAMFS_COPY_BIN='fw_printenv fw_setenv'
RAMFS_COPY_DATA='/etc/fw_env.config /var/lock/fw_printenv.lock'

platform_check_image() {
	return 0;
}

platform_do_upgrade() {
	case "$(board_name)" in
	arris,tr4400-v2 |\
	askey,rt4230w-rev6 |\
	compex,wpq864|\
	fortinet,fap-421e|\
	linksys,e8350-v1|\
	netgear,d7800 |\
	netgear,r7500 |\
	netgear,r7500v2 |\
	netgear,r7800 |\
	netgear,xr450 |\
	netgear,xr500 |\
	nokia,ac400i |\
	qcom,ipq8064-ap148 |\
	qcom,ipq8064-ap161)
		nand_do_upgrade "$1"
		;;
	asrock,g10)
		asrock_upgrade_prepare
		nand_do_upgrade "$1"
		;;
	buffalo,wxr-2533dhp)
		buffalo_upgrade_prepare_ubi
		CI_ROOTPART="ubi_rootfs"
		nand_do_upgrade "$1"
		;;
	edgecore,ecw5410 |\
	ignitenet,ss-w2-ac2600)
		part="$(awk -F 'ubi.mtd=' '{printf $2}' /proc/cmdline | sed -e 's/ .*$//')"
		if [ "$part" = "rootfs1" ]; then
			fw_setenv active 2 || exit 1
			CI_UBIPART="rootfs2"
		else
			fw_setenv active 1 || exit 1
			CI_UBIPART="rootfs1"
		fi
		nand_do_upgrade "$1"
		;;
	extreme,ap3935)
		CI_ROOTPART="nand_flash"
		CI_KERNPART="PriImg"
		nand_do_upgrade "$1"
		;;
	linksys,ea7500-v1 |\
	linksys,ea8500)
		platform_do_upgrade_linksys "$1"
		;;
	meraki,mr42 |\
	meraki,mr52)
		CI_KERNPART="bootkernel2"
		nand_do_upgrade "$1"
		;;
	ruijie,rg-mtfi-m520)
		ruijie_do_upgrade "$1"
		;;
	tplink,ad7200 |\
	tplink,c2600)
		PART_NAME="os-image:rootfs"
		MTD_CONFIG_ARGS="-s 0x200000"
		default_do_upgrade "$1"
		;;
	asus,onhub |\
	tplink,onhub)
		export_bootdevice
		export_partdevice CI_ROOTDEV 0
		CI_KERNPART="kernel"
		CI_ROOTPART="rootfs"
		CI_DATAPART="rootfs_data"
		emmc_do_upgrade "$1"
		;;
	tplink,vr2600v)
		MTD_CONFIG_ARGS="-s 0x200000"
		default_do_upgrade "$1"
		;;
	xiaomi,mi-router-hd)
		platform_do_upgrade_xiaomi "$1" 0x2800000
		;;
	zyxel,nbg6817)
		zyxel_do_upgrade "$1"
		;;
	*)
		default_do_upgrade "$1"
		;;
	esac
}

platform_copy_config() {
	case "$(board_name)" in
	asus,onhub |\
	tplink,onhub)
		emmc_copy_config
		;;
	esac
	return 0
}
