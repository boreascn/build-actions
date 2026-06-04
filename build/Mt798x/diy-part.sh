#!/bin/bash
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
# DIY扩展二合一了，在此处可以增加插件

# 添加插件源
echo 'src-git lucky https://github.com/gdy666/luci-app-lucky.git' >> feeds.conf.default
echo 'src-git nikki https://github.com/nikkinikki-org/OpenWrt-nikki.git;main' >> feeds.conf.default
echo 'src-git momo https://github.com/nikkinikki-org/OpenWrt-momo.git;main' >> feeds.conf.default

# 后台IP设置
export Ipv4_ipaddr="192.168.16.1"            # 修改openwrt后台地址(填0为关闭)
export Netmask_netm="255.255.255.0"         # IPv4 子网掩码（默认：255.255.255.0）(填0为不作修改)
export Op_name="ImmortalWrt"                # 修改主机名称为OpenWrt-123(填0为不作修改)

# 内核和系统分区大小(不是每个机型都可用)
export Kernel_partition_size="0"            # 内核分区大小
export Rootfs_partition_size="0"            # 系统分区大小

# 默认主题设置
export Mandatory_theme="argon"              # 将bootstrap替换您需要的主题为必选主题
export Default_theme="argon"                # 多主题时,选择某主题为默认第一主题

# 旁路由选项
export Gateway_Settings="0"
export DNS_Settings="0"
export Broadcast_Ipv4="0"
export Disable_DHCP="0"
export Disable_Bridge="0"
export Create_Ipv6_Lan="0"

# IPV6、IPV4 选择
export Enable_IPV6_function="0"
export Enable_IPV4_function="0"

# 替换OpenClash的源码(默认master分支)
export OpenClash_branch="0"

# 个性签名
export Customized_Information="$(TZ=UTC-8 date "+%Y.%m.%d")"

# 更换固件内核
export Replace_Kernel="0"

# 设置免密码登录
export Password_free_login="1"

# 增加AdGuardHome插件和核心
export AdGuardHome_Core="0"

# 开启NTFS格式盘挂载
export Automatic_Mount_Settings="0"

# 去除网络共享(autosamba)
export Disable_autosamba="1"

# 其他
export Ttyd_account_free_login="0"
export Delete_unnecessary_items="1"
export Disable_53_redirection="0"
export Cancel_running="0"

# 晶晨CPU系列打包固件设置
export amlogic_model="s905d"
export amlogic_kernel="6.1.120_6.12.15"
export auto_kernel="true"
export rootfs_size="512/2560"
export kernel_usage="stable"

# 修改插件名字
grep -rl '"终端"' . | xargs -r sed -i 's?"终端"?"TTYD"?g'
grep -rl '"TTYD 终端"' . | xargs -r sed -i 's?"TTYD 终端"?"TTYD"?g'
grep -rl '"网络存储"' . | xargs -r sed -i 's?"网络存储"?"NAS"?g'
grep -rl '"实时流量监测"' . | xargs -r sed -i 's?"实时流量监测"?"流量"?g'
grep -rl '"KMS 服务器"' . | xargs -r sed -i 's?"KMS 服务器"?"KMS激活"?g'
grep -rl '"USB 打印服务器"' . | xargs -r sed -i 's?"USB 打印服务器"?"打印服务"?g'
grep -rl '"Web 管理"' . | xargs -r sed -i 's?"Web 管理"?"Web管理"?g'
grep -rl '"管理权"' . | xargs -r sed -i 's?"管理权"?"改密码"?g'
grep -rl '"带宽监控"' . | xargs -r sed -i 's?"带宽监控"?"监控"?g'


# =========================================================
# 终极拦截：彻底关闭 U-Boot 和相关组件的编译，防止驱动报错卡死
# =========================================================

# 1. 强行在最终生成的 .config 中将其彻底关闭并设置为不编译
echo "CONFIG_PACKAGE_uboot-mediatek=n" >> .config
echo "CONFIG_PACKAGE_luci-app-u-boot-envtools=n" >> .config
echo "CONFIG_PACKAGE_uboot-envtools=n" >> .config

# 2. 空壳替换法（彻底移除了网页复制带来的异常隐藏空格）
if [ -f "package/boot/uboot-mediatek/Makefile" ]; then
    echo "发现 Target U-Boot Makefile，正在强行清空其编译内容以跳过错误..."
    cat << 'EOF' > package/boot/uboot-mediatek/Makefile
include $(TOPDIR)/rules.mk
PKG_NAME:=uboot-mediatek
PKG_VERSION:=empty
include $(INCLUDE_DIR)/package.mk
define Package/uboot-mediatek
  SECTION:=boot
  CATEGORY:=Boot Loaders
  TITLE:=Empty package to bypass compile error
endef
define Build/Compile
	@echo "U-Boot compilation bypassed successfully."
endef
$(eval $(call BuildPackage,uboot-mediatek))
EOF
fi


# 整理固件包时候,删除您不想要的固件或者文件,让它不需要上传到Actions空间
cat >"$CLEAR_PATH" <<-EOF
packages
config.buildinfo
feeds.buildinfo
sha256sums
version.buildinfo
profiles.json
openwrt-x86-64-generic-kernel.bin
openwrt-x86-64-generic.manifest
openwrt-x86-64-generic-squashfs-rootfs.img.gz
ipk.tar.gz
openwrt-mediatek-mt7986-xiaomi_redmi-router-ax6000-initramfs-kernel.bin
openwrt-mediatek-mt7986-xiaomi_redmi-router-ax6000-squashfs-factory.bin
mediatek-filogic-xiaomi_redmi-router-ax6000-ubootmod-initramfs-factory.ubi
mediatek-filogic-xiaomi_redmi-router-ax6000-ubootmod-initramfs-recovery.itb
mt7988-ram-comb-bl2.bin
mt7986-ram-ddr4-bl2.bin
mt7986-ram-ddr3-bl2.bin
mt7981-ram-ddr4-bl2.bin
mt7981-ram-ddr3-bl2.bin
EOF

# 在线更新时，删除不想保留固件的某个文件
cat >>$DELETE <<-EOF
EOF
