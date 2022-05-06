#!/bin/bash

#sdcard format
SDCARD=""

echo "Beaglebone Black Build Script"
echo "Author: Dungnt98 (nguyentrongdung0498@gmail.com)"
toolchain_dir="toolchain"
cross_compiler="arm-linux-gnueabihf"
temp_root_dir=$PWD

#uboot=========================================================
u_boot_dir="Beaglebone-u-boot"
u_boot_config_file="am335x_boneblack_vboot_defconfig"
u_boot_boot_cmd_file="uEnv.txt"
uboot_file="u-boot.img"
mlo_file="MLO"
#uboot=========================================================

#linux opt=========================================================
linux_dir="Beaglebone-linux"
linux_config_file="bb.org_defconfig"
dtb_file="am335x-boneblack.dtb"
linux_file="uImage"
#linux opt=========================================================

# rootfs opt=========================================================
rootfs_dir="rootfs"
#linux opt=========================================================

# output Image file
_IMG_FILE=${temp_root_dir}/output/image/beaglebone_black_spi.img

#pull===================================================================
pull_uboot(){

	if [ -d ${temp_root_dir}/${u_boot_dir} ]; then
		echo "u-boot dir is exist"
	else
		# rm -rf ${temp_root_dir}/${u_boot_dir} &&\
		mkdir -p ${temp_root_dir}/${u_boot_dir} &&\
		cd ${temp_root_dir}/${u_boot_dir} &&\
		git clone git://git.denx.de/u-boot.git u-boot/
		if [ ! -d ${temp_root_dir}/${u_boot_dir}/u-boot ]; then
			echo "Error:pull u_boot failed"
				exit 0
		else
			mv ${temp_root_dir}/${u_boot_dir}/u-boot/* ${temp_root_dir}/${u_boot_dir}/
			rm -rf ${temp_root_dir}/${u_boot_dir}/u-boot
			echo "pull u-boot ok"
		fi
	fi
}

pull_linux(){
	if [ -d ${temp_root_dir}/${linux_dir} ]; then
		echo "u-boot dir is exist"
	else
		# rm -rf ${temp_root_dir}/${linux_dir} &&\
		mkdir -p ${temp_root_dir}/${linux_dir} &&\
		cd ${temp_root_dir}/${linux_dir} &&\
		git clone -b 4.14 https://github.com/beagleboard/linux.git

		if [ ! -d ${temp_root_dir}/${linux_dir}/linux ]; then
			echo "Error:pull linux failed"
				exit 0
		else
			mv ${temp_root_dir}/${linux_dir}/linux/* ${temp_root_dir}/${linux_dir}/
			rm -rf ${temp_root_dir}/${linux_dir}/linux
			echo "pull linux ok"
		fi
	fi
}

pull_toolchain(){
	if [ -d ${temp_root_dir}/${toolchain_dir} ]; then
		echo "u-boot dir is exist"
	else
		rm -rf ${temp_root_dir}/${toolchain_dir}
		mkdir -p ${temp_root_dir}/${toolchain_dir}
		cd ${temp_root_dir}/${toolchain_dir}
		ldconfig
		wget http://releases.linaro.org/components/toolchain/binaries/7.4-2019.02/arm-linux-gnueabihf/gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabihf.tar.xz &&\
		tar xvJf gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabihf.tar.xz
		if [ ! -d ${temp_root_dir}/${toolchain_dir}/gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabihf ]; then
			echo "Error:pull toolchain failed"
				exit 0
		else
			echo "pull toolchain ok"
		fi
	fi
}

pull_rootfs(){
	if [ -f ${temp_root_dir}/${rootfs_dir}/rootfs.tar.xz ]; then
		echo "rootfs dir is exist"
		if [ ! -d ${temp_root_dir}/${rootfs_dir}/rootfs ]; then
			cd ${temp_root_dir}/${rootfs_dir}  &&\
			tar xvJf rootfs.tar.xz
		fi
	else
		sudo rm -rf ${temp_root_dir}/${rootfs_dir}
		mkdir -p ${temp_root_dir}/${rootfs_dir}
		cd ${temp_root_dir}/${rootfs_dir}  &&\
		wget -O rootfs.tar.xz https://www.dropbox.com/s/k93doprl261hwn2/rootfs.tar.xz?dl=1 &&\
		tar xvJf rootfs.tar.xz
		if [ ! -d ${temp_root_dir}/${rootfs_dir}/rootfs ]; then
			echo "Error:pull buildroot failed"
			exit 0
		else
			tar cvf rootfs.tar rootfs
			# rm -rf ${temp_root_dir}/${rootfs_dir}/rootfs
				echo "pull buildroot ok"
		fi
	fi
}

pull_all(){
    sudo apt-get update
	sudo apt-get install -y autoconf automake libtool gettext lzop
    sudo apt-get install -y make gcc g++ swig python-dev bc python u-boot-tools bison flex bc libssl-dev libncurses5-dev unzip mtd-utils
	sudo apt-get install -y libc6-i386 lib32stdc++6 lib32z1
	sudo apt-get install -y libc6:i386 libstdc++6:i386 zlib1g:i386
	pull_uboot
	pull_linux
	pull_toolchain
	pull_rootfs
}
#pull===================================================================

#clean===================================================================
clean_log(){
	rm -f ${temp_root_dir}/*.log
}

clean_all(){
	clean_log
	clean_uboot
	clean_linux
}
#clean===================================================================


#env===================================================================
update_env(){
	if [ ! -d ${temp_root_dir}/${toolchain_dir}/gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabihf ]; then
		echo "Error:toolchain no found,Please use ./buid.sh pull_all "
			exit 0
	else
		export PATH="$PWD/${toolchain_dir}/gcc-linaro-7.4.1-2019.02-x86_64_arm-linux-gnueabihf/bin":"$PATH"
	fi

	echo $PATH
}
check_env(){
	if [ ! -d ${temp_root_dir}/${toolchain_dir} ] ||\
	 [ ! -d ${temp_root_dir}/${u_boot_dir} ] ||\
	 [ ! -d ${temp_root_dir}/${rootfs_dir} ] ||\
	 [ ! -d ${temp_root_dir}/${linux_dir} ]; then
		echo "Error:env error,Please use ./buid.sh pull_all"
		exit 0
	fi
}
#env===================================================================

#uboot=========================================================

clean_uboot(){
	cd ${temp_root_dir}/${u_boot_dir}
	make ARCH=arm CROSS_COMPILE=${cross_compiler}- mrproper > /dev/null 2>&1
}

build_uboot(){
	cd ${temp_root_dir}/${u_boot_dir}
	echo "Building uboot ..."
    	echo "--->Configuring ..."
	make ARCH=arm CROSS_COMPILE=${cross_compiler}- ${u_boot_config_file} > /dev/null 2>&1
	if [ $? -ne 0 ] || [ ! -f ${temp_root_dir}/${u_boot_dir}/.config ]; then
		echo "Error: .config file not exist"
		exit 1
	fi
	echo "--->Get cpu info ..."
	proc_processor=$(grep 'processor' /proc/cpuinfo | sort -u | wc -l)
	echo "--->Compiling ..."
  	make ARCH=arm CROSS_COMPILE=${cross_compiler}- -j${proc_processor} > ${temp_root_dir}/build_uboot.log 2>&1

	if [ $? -ne 0 ] || [ ! -f ${temp_root_dir}/${u_boot_dir}/u-boot ]; then
		echo "Error: UBOOT NOT BUILD.Please Get Some Error From build_uboot.log"
		error_msg=$(cat ${temp_root_dir}/build_uboot.log)
		if [[ $(echo $error_msg | grep "ImportError: No module named _libfdt") != "" ]];then
		    echo "Please use Python2.7 as default python interpreter"
		fi
        	exit 1
	fi

	if [ ! -f ${temp_root_dir}/${u_boot_dir}/${uboot_file} ]; then
        	echo "Error: UBOOT NOT BUILD.Please Enable spl option"
        	exit 1
	fi
	# #make boot.src
	# if [ -n "$u_boot_boot_cmd_file" ];then
    #     echo "build uboot.src"
	# 	mkimage -A arm -O linux -T script -C none -a 0 -e 0 -n "Beagleboard boot script" -d ${temp_root_dir}/${u_boot_boot_cmd_file} ${temp_root_dir}/output/boot.scr
	# fi
	echo "Build uboot ok"
}
#uboot=========================================================

#linux=========================================================
clean_linux(){
	cd ${temp_root_dir}/${linux_dir}
	make ARCH=arm CROSS_COMPILE=${cross_compiler}- mrproper > /dev/null 2>&1
}

build_linux(){
	cd ${temp_root_dir}/${linux_dir}
	echo "Building linux ..."
	echo "--->Configuring ..."
	make ARCH=arm CROSS_COMPILE=${cross_compiler}- ${linux_config_file} > /dev/null 2>&1
	if [ $? -ne 0 ] || [ ! -f ${temp_root_dir}/${linux_dir}/.config ]; then
		echo "Error: .config file not exist"
		exit 1
	fi
	echo "--->Get cpu info ..."
	proc_processor=$(grep 'processor' /proc/cpuinfo | sort -u | wc -l)
	echo "--->Compiling ..."
  	make ARCH=arm CROSS_COMPILE=${cross_compiler}- -j${proc_processor} uImage dtbs LOADADDR=0x80008000 -j4 > ${temp_root_dir}/build_linux.log 2>&1

	if [ $? -ne 0 ] || [ ! -f ${temp_root_dir}/${linux_dir}/arch/arm/boot/${linux_file} ]; then
        	echo "Error: LINUX NOT BUILD. Please Get Some Error From build_linux.log"
        	exit 1
	fi

	if [ ! -f ${temp_root_dir}/${linux_dir}/arch/arm/boot/dts/${dtb_file} ]; then
        	echo "Error: Linux NOT BUILD. ${temp_root_dir}/${linux_dir}/arch/arm/boot/dts/${dtb_file} not found"
        	exit 1
	fi

	# # build linux kernel modules
	# make ARCH=arm CROSS_COMPILE=${cross_compiler}- -j${proc_processor} INSTALL_MOD_PATH=${temp_root_dir}/${linux_dir}/out modules > /dev/null 2>&1
	# make ARCH=arm CROSS_COMPILE=${cross_compiler}- -j${proc_processor} INSTALL_MOD_PATH=${temp_root_dir}/${linux_dir}/out modules_install > /dev/null 2>&1

	echo "Build linux ok"
}
#linux=========================================================

#copy=========================================================
copy_uboot(){
	cp ${temp_root_dir}/${u_boot_dir}/${uboot_file} ${temp_root_dir}/output/
	cp ${temp_root_dir}/${u_boot_dir}/${mlo_file} ${temp_root_dir}/output/
}
copy_linux(){
	cp ${temp_root_dir}/${linux_dir}/arch/arm/boot/${linux_file} ${temp_root_dir}/output/
	cp ${temp_root_dir}/${linux_dir}/arch/arm/boot/dts/${dtb_file} ${temp_root_dir}/output/
}
copy_rootfs(){
	cp ${temp_root_dir}/${rootfs_dir}/rootfs.tar ${temp_root_dir}/output/
	gzip -c ${temp_root_dir}/output/rootfs.tar > ${temp_root_dir}/output/rootfs.tar.gz
}
#copy=========================================================

#clean output dir=========================================================
clean_output_dir(){
	sudo rm -rf ${temp_root_dir}/output/*
}
#clean output dir=========================================================

build(){
	check_env
	update_env
	echo "clean log ..."
	clean_log
	echo "clean output dir ..."
	clean_output_dir
	build_uboot
	echo "copy uboot ..."
	copy_uboot
	build_linux
	echo "copy linux ..."
	copy_linux
	echo "copy rootfs ..."
	copy_rootfs
}


#pack=========================================================
pack_tf_normal_size_img(){
	_ROOTFS_FILE=${temp_root_dir}/output/rootfs.tar.gz
	_ROOTFS_SIZE=`gzip -l $_ROOTFS_FILE | sed -n '2p' | awk '{print $2}'`
	_ROOTFS_SIZE=`echo "scale=3;$_ROOTFS_SIZE/1024/1024" | bc`

	_CFG_SIZEKB=0
	_UBOOT_SIZE=1
	_P1_SIZE=500 #MB
	_IMG_SIZE=4000 #MB

	_MIN_SIZE=`echo "scale=3;$_UBOOT_SIZE+$_P1_SIZE+$_ROOTFS_SIZE+$_CFG_SIZEKB/1024" | bc` #+$_OVERLAY_SIZE
	_MIN_SIZE=$(echo "$_MIN_SIZE" | bc)
	echo  "--->min img size = $_MIN_SIZE MB"
	_MIN_SIZE=$(echo "${_MIN_SIZE%.*}+1"|bc)
	_FREE_SIZE=`echo "$_IMG_SIZE-$_MIN_SIZE"|bc`

	mkdir -p ${temp_root_dir}/output/image
	rm $_IMG_FILE

	dd if=/dev/zero of=$_IMG_FILE bs=1M count=$_IMG_SIZE
	if [ $? -ne 0 ]
	then
		echo  "getting error in creating dd img!"
	    	exit
	fi
	_LOOP_DEV=$(sudo losetup -f)
	if [ -z $_LOOP_DEV ]
	then
		echo  "can not find a loop device!"
		exit
	fi
	sudo losetup $_LOOP_DEV $_IMG_FILE
	if [ $? -ne 0 ]
	then
		echo  "dd img --> $_LOOP_DEV error!"
		sudo losetup -d $_LOOP_DEV >/dev/null 2>&1 && exit
	fi

	# create partition for image
	echo  "--->creating partitions for tf image ..."
	cat <<EOT |sudo  sfdisk $_IMG_FILE
1M,${_P1_SIZE}M,c
,,L
EOT
	sleep 2
	sudo partx -u $_LOOP_DEV # update partition table
	sudo mkfs.vfat -F32 ${_LOOP_DEV}p1 ||exit
	sudo mkfs.ext4 -F ${_LOOP_DEV}p2 ||exit
	if [ $? -ne 0 ]
	then
		echo  "error in creating partitions"
		sudo losetup -d $_LOOP_DEV >/dev/null 2>&1 && exit
	fi

	sudo sync
	mkdir -p ${temp_root_dir}/output/p1 >/dev/null 2>&1
	mkdir -p ${temp_root_dir}/output/p2 > /dev/null 2>&1
	sudo mount ${_LOOP_DEV}p1 ${temp_root_dir}/output/p1
	sudo mount ${_LOOP_DEV}p2 ${temp_root_dir}/output/p2

	_KERNEL_FILE=${temp_root_dir}/output/${linux_file}
	_DTB_FILE=${temp_root_dir}/output/${dtb_file}
	_UBOOT_FILE=${temp_root_dir}/output/${uboot_file}
	_MLO_FILE=${temp_root_dir}/output/${mlo_file}

	# do pack image
	echo  "--->copy uboot, linux and rootfs files..."
	sudo rm -rf  ${temp_root_dir}/output/p1/* && sudo rm -rf ${temp_root_dir}/output/p2/*
	sudo cp $_UBOOT_FILE ${temp_root_dir}/output/p1/ &&\
	sudo cp $_MLO_FILE ${temp_root_dir}/output/p1/ &&\
	sudo cp $_KERNEL_FILE ${temp_root_dir}/output/p1/ &&\
	sudo cp $_DTB_FILE ${temp_root_dir}/output/p1/ &&\
	sudo cp ${temp_root_dir}/${u_boot_boot_cmd_file} ${temp_root_dir}/output/p1/ &&\
	echo "--->p1 done~"
	sudo cp -rf ${temp_root_dir}/${rootfs_dir}/rootfs/* ${temp_root_dir}/output/p2/ &&\
	echo "--->p2 done~"

	if [ $? -ne 0 ]
	then
	echo "copy files error! "
	sudo losetup -d $_LOOP_DEV >/dev/null 2>&1
	sudo umount ${_LOOP_DEV}p1  ${_LOOP_DEV}p2 >/dev/null 2>&1
	exit
	fi

	echo "--->The tf card image-packing task done~"
	sudo sync
	sleep 2
	sudo umount ${temp_root_dir}/output/p1 ${temp_root_dir}/output/p2  && sudo losetup -d $_LOOP_DEV
	if [ $? -ne 0 ]
	then
		echo  "umount or losetup -d error!!"
		exit
	fi
}
#pack=========================================================

if [ "${1}" = "" ] && [ ! "${1}" = "build_tf" ] && [ ! "${1}" = "pull_all" ]; then
	echo "Usage: build.sh [build_flash | build_tf | pull_all | clean]"；
	echo "One key build nano fimware";
	echo " ";
	echo "build_tf          Build zero firmware booted from tf";
	echo "pull_all         Pull build env from internet";
	echo "clean            Clean build env";
    exit 0
fi

if [ ! -f ${temp_root_dir}/build.sh ]; then
	echo "Error:Please enter packge root dir"
    	exit 0
fi

if [ "${1}" = "update_env" ]; then
	update_env
	echo "update_env ok"
	exit 0
fi

if [ "${1}" = "clean" ]; then
	clean_all
    clean_output_dir
	echo "clean ok"
	exit 0
fi

if [ "${1}" = "pull_all" ]; then
	pull_all
fi

if [ "${1}" = "pull_linux" ]; then
    pull_linux
fi

if [ "${1}" = "pull_rootfs" ]; then
    pull_rootfs
fi

if [ "${1}" = "build_uboot" ]; then
	u_boot_config_file="am335x_boneblack_vboot_defconfig"
	build_uboot
fi

if [ "${1}" = "build_linux" ]; then
	linux_config_file="bb.org_defconfig"
	build_linux
fi

if [ "${1}" = "build_tf" ]; then
	# cp -f ${temp_root_dir}/linux_tf_sun8i.h ${temp_root_dir}/${u_boot_dir}/include/configs/sun8i.h
	# cp -f ${temp_root_dir}/sun8i-v3s-licheepi-zero.dts ${temp_root_dir}/${linux_dir}/arch/arm/boot/dts/
    # cp -f ${temp_root_dir}/sun8i-v3s.dtsi ${temp_root_dir}/${linux_dir}/arch/arm/boot/dts/

	linux_config_file="bb.org_defconfig"
	u_boot_config_file="am335x_boneblack_vboot_defconfig"

	build
	# pack_tf_normal_size_img
fi

if [ "${1}" = "pack_tf" ]; then
    pack_tf_normal_size_img
fi

umount_all()
{
	set +e

	sudo df | grep ${SDCARD}1 2>&1 1>/dev/null
	if [ $? == 0 ]; then
		sudo umount ${SDCARD}1
	fi

	sudo df | grep ${SDCARD}2 2>&1 1>/dev/null
	if [ $? == 0 ]; then
		sudo umount ${SDCARD}2
	fi

	set -e
}

if [ "${1}" = "burn_tf" ]; then
	echo "umounting sdcard..."
	SDCARD="/dev/sda"
	umount_all

	echo "deleting all partitions..."
	sudo wipefs -a -f $SDCARD
	sudo dd if=/dev/zero of=$SDCARD bs=1M count=1
	
	echo "creating partitions..."
	sudo fdisk $SDCARD < part2.txt
	echo "formating partitions..."
	sudo mkfs.vfat -F32 ${SDCARD}1
	sudo mkfs.ext4 -F ${SDCARD}2

	mkdir -p ${temp_root_dir}/output/p1 >/dev/null 2>&1
	mkdir -p ${temp_root_dir}/output/p2 > /dev/null 2>&1
	sudo mount ${SDCARD}1 ${temp_root_dir}/output/p1
	sudo mount ${SDCARD}2 ${temp_root_dir}/output/p2

	_KERNEL_FILE=${temp_root_dir}/output/${linux_file}
	_DTB_FILE=${temp_root_dir}/output/${dtb_file}
	_UBOOT_FILE=${temp_root_dir}/output/${uboot_file}
	_MLO_FILE=${temp_root_dir}/output/${mlo_file}

	# do pack image
	echo  "--->copy uboot, linux and rootfs files..."
	sudo rm -rf  ${temp_root_dir}/output/p1/* && sudo rm -rf ${temp_root_dir}/output/p2/*
	sudo cp $_UBOOT_FILE ${temp_root_dir}/output/p1/ &&\
	sudo cp $_MLO_FILE ${temp_root_dir}/output/p1/ &&\
	sudo cp $_KERNEL_FILE ${temp_root_dir}/output/p1/ &&\
	sudo cp $_DTB_FILE ${temp_root_dir}/output/p1/ &&\
	sudo cp ${temp_root_dir}/${u_boot_boot_cmd_file} ${temp_root_dir}/output/p1/ &&\
	echo "--->p1 done~"
	sudo cp -rf ${temp_root_dir}/${rootfs_dir}/rootfs/* ${temp_root_dir}/output/p2/ &&\
	echo "--->p2 done~"

	echo "--->The tf card image-packing task done~"
	sudo sync
	sleep 2
	sudo umount ${temp_root_dir}/output/p1 ${temp_root_dir}/output/p2
	if [ $? -ne 0 ]; then
		echo  "umount or losetup -d error!!"
		exit
	fi

sleep 1
echo "Done!"

fi


