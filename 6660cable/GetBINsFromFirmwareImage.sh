#!/bin/bash

# This script is given to the word under the concept of "Public domain software".
# You can do whatever you want with it because is "really free",
# not "free with terms and conditions", like GNU license and other similar crap.
# If you talk all day about freedom, show it and make your code "really free".
# You don´t have to accept any kind of license nor terms and conditions to use it,
# cause it has no CopyRight or CopyLeft.   Enjoy!

# -----------------------------------------------------------------------------------
# The abelow commands downloads a firmware update for the Fritz!Box 6660 cablerouter.
# extract the .ubin file from it, and then extracts from the .ubin file all the
# .bin files needed to update the router via the FTP server of the EVA bootloader.
#
# Must be run in a Debian GNU/Linux distro with a bash shell
# -----------------------------------------------------------------------------------

ColorRed='\033[1;31m'
ColorGreen='\033[1;32m'
ColorEnd='\033[0m'

apt-get -y update > /dev/null
apt-get -y install dialog > /dev/null

menu=(dialog --timeout 5 --checklist "FritzBox 6660 cable, firmware selection (SpaceBar to mark, Enter to proceed):" 22 86 16)
  options=(1 "7.23 Deustchland" off
           2 "7.23 International" off)
  choices=$("${menu[@]}" "${options[@]}" 2>&1 >/dev/tty)
  clear

  for choice in $choices
    do
      case $choice in

        1)

          URL723d="http://download.avm.de/firmware/6660/8741253231/"
          File723d="FRITZ.Box_6660_Cable-07.23.image"

          echo ""
          echo -e "${ColorGreen}Downloading 7.23 firmware, Deustchland version...${ColorEnd}"
          echo ""

          echo ""
          echo "Installing some mandatory packages from the distro repository..."
          echo ""
          apt-get -y install wget tar git build-essential > /dev/null

          echo ""
          echo "Downloading the firmware update image file..."
          echo ""
          mkdir -p /root/FritzBox/6660cable/firmware/7.23/Deustchland/Image/ > /dev/null
          cd /root/FritzBox/6660cable/firmware/7.23/Deustchland/Image/
          wget --no-check-certificate $URL723d$File723d

          echo ""
          echo "Extracting the image file..."
          echo ""
          mkdir -p /root/FritzBox/6660cable/firmware/7.23/Deustchland/ImageExtracted/ > /dev/null
          cd /root/FritzBox/6660cable/firmware/7.23/Deustchland/ImageExtracted/
          tar xf /root/FritzBox/6660cable/firmware/7.23/Deustchland/Image/$File723d

          echo ""
          echo "Downloading uimg-tool source code..."
          echo ""
          rm -rf  /root/SourceCode/uimg-tool/ > /dev/null
          mkdir   /root/SourceCode/ > /dev/null
          cd      /root/SourceCode/
          git clone --depth=1 http://bitbucket.org/fesc2000/uimg-tool/

          echo ""
          echo "Compiling uimg-tool..."
          echo ""
          cd /root/SourceCode/uimg-tool/
          make

          echo ""
          echo "Extracting .bin files from .uimg file..."
          echo ""
          mkdir /root/FritzBox/6660cable/firmware/7.23/Deustchland/ImageExtractedBINs/ > /dev/null
          cd /root/FritzBox/6660cable/firmware/7.23/Deustchland/ImageExtractedBINs/
          /root/SourceCode/uimg-tool/uimg -u -n part /root/FritzBox/6660cable/firmware/7.23/Deustchland/ImageExtracted/var/firmware-update.uimg > /root/FritzBox/6660cable/firmware/7.23/Deustchland/ImageExtractedBINs/Extraction.log
          echo ""
          echo "Result:"
          echo ""
          cat /root/FritzBox/6660cable/firmware/7.23/Deustchland/ImageExtractedBINs/Extraction.log

          echo ""
          echo "Renaming .bin files for a better understanting of the flashing process..."
          echo ""
          mv /root/FritzBox/6660cable/firmware/7.23/Deustchland/ImageExtractedBINs/part_03_ATOM_ROOTFS.bin /root/FritzBox/6660cable/firmware/7.23/Deustchland/ImageExtractedBINs/mtd0-Atom-RootFileSystem.bin
          mv /root/FritzBox/6660cable/firmware/7.23/Deustchland/ImageExtractedBINs/part_02_ATOM_KERNEL.bin /root/FritzBox/6660cable/firmware/7.23/Deustchland/ImageExtractedBINs/mtd1-Atom-Kernel.bin
          mv /root/FritzBox/6660cable/firmware/7.23/Deustchland/ImageExtractedBINs/part_09_ARM_ROOTFS.bin  /root/FritzBox/6660cable/firmware/7.23/Deustchland/ImageExtractedBINs/mtd6-ARM-RootFileSystem.bin
          mv /root/FritzBox/6660cable/firmware/7.23/Deustchland/ImageExtractedBINs/part_08_ARM_KERNEL.bin  /root/FritzBox/6660cable/firmware/7.23/Deustchland/ImageExtractedBINs/mtd7-ARM-Kernel.bin
          echo ""
          echo "--------------------------------------------------------------------------"
          echo "Process finished. All .bin files stored in:"
          echo ""
          echo "/root/FritzBox/6660cable/firmware/7.23/Deustchland/ImageExtractedBINs/"
          cd /root/FritzBox/6660cable/firmware/7.23/Deustchland/ImageExtractedBINs/
          echo ""
          ls -al --color | grep .bin |  sed 's/.* //'
          echo "--------------------------------------------------------------------------"
          echo ""
        ;;

        2)

          URL723i="http://download.avm.de/firmware/6660/8741253231/"
          File723i="FRITZ.Box_6660_Cable-07.23.image"

          echo ""
          echo -e "${ColorGreen}Downloading 7.23 firmware, International version...${ColorEnd}"
          echo ""

          echo ""
          echo "Installing some mandatory packages from the distro repository..."
          echo ""
          apt-get -y install wget tar git build-essential > /dev/null

          echo ""
          echo "Downloading the firmware update image file..."
          echo ""
          mkdir -p /root/FritzBox/6660cable/firmware/7.23/International/Image/ > /dev/null
          cd /root/FritzBox/6660cable/firmware/7.23/International/Image/
          wget --no-check-certificate $URL723i$File723i

          echo ""
          echo "Extracting the image file..."
          echo ""
          mkdir -p /root/FritzBox/6660cable/firmware/7.23/International/ImageExtracted/ > /dev/null
          cd /root/FritzBox/6660cable/firmware/7.23/International/ImageExtracted/
          tar xf /root/FritzBox/6660cable/firmware/7.23/International/Image/$File723i

          echo ""
          echo "Downloading uimg-tool source code..."
          echo ""
          rm -rf  /root/SourceCode/uimg-tool/ > /dev/null
          mkdir   /root/SourceCode/ > /dev/null
          cd      /root/SourceCode/
          git clone --depth=1 http://bitbucket.org/fesc2000/uimg-tool/

          echo ""
          echo "Compiling uimg-tool..."
          echo ""
          cd /root/SourceCode/uimg-tool/
          make

          echo ""
          echo "Extracting .bin files from .uimg file..."
          echo ""
          mkdir /root/FritzBox/6660cable/firmware/7.23/International/ImageExtractedBINs/ > /dev/null
          cd /root/FritzBox/6660cable/firmware/7.23/International/ImageExtractedBINs/
          /root/SourceCode/uimg-tool/uimg -u -n part /root/FritzBox/6660cable/firmware/7.23/International/ImageExtracted/var/firmware-update.uimg > /root/FritzBox/6660cable/firmware/7.23/International/ImageExtractedBINs/Extraction.log
          echo ""
          echo "Result:"
          echo ""
          cat /root/FritzBox/6660cable/firmware/7.23/International/ImageExtractedBINs/Extraction.log

          echo ""
          echo "Renaming .bin files for a better understanting of the flashing process..."
          echo ""
          mv /root/FritzBox/6660cable/firmware/7.23/International/ImageExtractedBINs/part_03_ATOM_ROOTFS.bin /root/FritzBox/6660cable/firmware/7.23/International/ImageExtractedBINs/mtd0-Atom-RootFileSystem.bin
          mv /root/FritzBox/6660cable/firmware/7.23/International/ImageExtractedBINs/part_02_ATOM_KERNEL.bin /root/FritzBox/6660cable/firmware/7.23/International/ImageExtractedBINs/mtd1-Atom-Kernel.bin
          mv /root/FritzBox/6660cable/firmware/7.23/International/ImageExtractedBINs/part_09_ARM_ROOTFS.bin  /root/FritzBox/6660cable/firmware/7.23/International/ImageExtractedBINs/mtd6-ARM-RootFileSystem.bin
          mv /root/FritzBox/6660cable/firmware/7.23/International/ImageExtractedBINs/part_08_ARM_KERNEL.bin  /root/FritzBox/6660cable/firmware/7.23/International/ImageExtractedBINs/mtd7-ARM-Kernel.bin
          echo ""
          echo "--------------------------------------------------------------------------"
          echo "Process finished. All .bin files stored in:"
          echo ""
          echo "/root/FritzBox/6660cable/firmware/7.23/International/ImageExtractedBINs/"
          cd /root/FritzBox/6660cable/firmware/7.23/International/ImageExtractedBINs/
          echo ""
          ls -al --color | grep .bin |  sed 's/.* //'
          echo "--------------------------------------------------------------------------"
          echo ""

        ;;

      esac

    done

