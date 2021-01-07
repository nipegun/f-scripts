#!/bin/bash

# This script is given to the word under the concept of "Public domain software".
# You can do whatever you want with it because is "really free",
# not "free with terms and conditions", like GNU license and other similar crap.
# If you talk all day about freedom, show it and make your code "really free".
# You don´t have to accept any kind of license nor terms and conditions to use it,
# cause it has no CopyRight or CopyLeft.
# Enjoy!

# -----------------------------------------------------------------------------------
# The below commands downloads a firmware update for the Fritz!Box 6591 cablerouter.
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

menu=(dialog --timeout 5 --checklist "FritzBox 6591 cable, firmware selection (SpaceBar to mark, Enter to proceed):" 22 86 16)
  options=(1 "7.22 Deustchland" off
           2 "7.22 International" off)
  choices=$("${menu[@]}" "${options[@]}" 2>&1 >/dev/tty)
  clear

  for choice in $choices
    do
      case $choice in

        1)

          echo ""
          echo -e "${ColorGreen}-------------------------------------------------${ColorEnd}"
          echo -e "${ColorGreen}Downloading 7.22 firmware, Deustchland version...${ColorEnd}"
          echo -e "${ColorGreen}-------------------------------------------------${ColorEnd}"
          echo ""

          URL722d="http://download.avm.de/firmware/6591/8548751392/"
          File722d="FRITZ.Box_6591_Cable-07.22.image"

          echo ""
          echo -e "${ColorGreen}Installing some mandatory packages from the distro repository...${ColorEnd}"
          echo ""
          apt-get -y install wget tar git build-essential > /dev/null

          echo ""
          echo -e "${ColorGreen}Downloading the firmware update image file...${ColorEnd}"
          echo ""
          rm -rf /root/FritzBox/6591cable/firmware/7.22/Deustchland/Image/
          mkdir -p /root/FritzBox/6591cable/firmware/7.22/Deustchland/Image/ > /dev/null
          cd /root/FritzBox/6591cable/firmware/7.22/Deustchland/Image/
          wget --no-check-certificate $URL722d$File722d

          echo ""
          echo -e "${ColorGreen}Extracting the image file...${ColorEnd}"
          echo ""
          mkdir -p /root/FritzBox/6591cable/firmware/7.22/Deustchland/ImageExtracted/ > /dev/null
          cd /root/FritzBox/6591cable/firmware/7.22/Deustchland/ImageExtracted/
          tar xf /root/FritzBox/6591cable/firmware/7.22/Deustchland/Image/$File722d

          echo ""
          echo -e "${ColorGreen}Downloading uimg-tool source code...${ColorEnd}"
          echo ""
          rm -rf  /root/SourceCode/uimg-tool/ > /dev/null
          mkdir   /root/SourceCode/ > /dev/null
          cd      /root/SourceCode/
          git clone --depth=1 http://bitbucket.org/fesc2000/uimg-tool/

          echo ""
          echo -e "${ColorGreen}Compiling uimg-tool...${ColorEnd}"
          echo ""
          cd /root/SourceCode/uimg-tool/
          make

          echo ""
          echo -e "${ColorGreen}Extracting .bin files from .uimg file...${ColorEnd}"
          echo ""
          mkdir /root/FritzBox/6591cable/firmware/7.22/Deustchland/ImageExtractedBINs/ > /dev/null
          cd /root/FritzBox/6591cable/firmware/7.22/Deustchland/ImageExtractedBINs/
          /root/SourceCode/uimg-tool/uimg -u -n part /root/FritzBox/6591cable/firmware/7.22/Deustchland/ImageExtracted/var/firmware-update.uimg > /root/FritzBox/6591cable/firmware/7.22/Deustchland/ImageExtractedBINs/Extraction.log
          echo ""
          echo -e "${ColorGreen}Result:${ColorEnd}"
          echo ""
          cat /root/FritzBox/6591cable/firmware/7.22/Deustchland/ImageExtractedBINs/Extraction.log

          echo ""
          echo -e "${ColorGreen}Renaming .bin files for a better understanting of the flashing process...${ColorEnd}"
          echo ""
          mv /root/FritzBox/6591cable/firmware/7.22/Deustchland/ImageExtractedBINs/part_03_ATOM_ROOTFS.bin /root/FritzBox/6591cable/firmware/7.22/Deustchland/ImageExtractedBINs/mtd0-Atom-RootFileSystem.bin
          mv /root/FritzBox/6591cable/firmware/7.22/Deustchland/ImageExtractedBINs/part_02_ATOM_KERNEL.bin /root/FritzBox/6591cable/firmware/7.22/Deustchland/ImageExtractedBINs/mtd1-Atom-Kernel.bin
          mv /root/FritzBox/6591cable/firmware/7.22/Deustchland/ImageExtractedBINs/part_09_ARM_ROOTFS.bin  /root/FritzBox/6591cable/firmware/7.22/Deustchland/ImageExtractedBINs/mtd6-ARM-RootFileSystem.bin
          mv /root/FritzBox/6591cable/firmware/7.22/Deustchland/ImageExtractedBINs/part_08_ARM_KERNEL.bin  /root/FritzBox/6591cable/firmware/7.22/Deustchland/ImageExtractedBINs/mtd7-ARM-Kernel.bin

          echo ""
          echo -e "${ColorGreen}Moving files to windows folders...${ColorEnd}"
          echo ""
          mkdir -p /mnt/c/FritzBox/6591cable/BinsToFlash/7.22-Deustchland/ > /dev/null
          mv /root/FritzBox/6591cable/firmware/7.22/Deustchland/ImageExtractedBINs/mtd0-Atom-RootFileSystem.bin /mnt/c/FritzBox/6591cable/BinsToFlash/7.22-Deustchland/mtd0.bin
          mv /root/FritzBox/6591cable/firmware/7.22/Deustchland/ImageExtractedBINs/mtd1-Atom-Kernel.bin         /mnt/c/FritzBox/6591cable/BinsToFlash/7.22-Deustchland/mtd1.bin
          mv /root/FritzBox/6591cable/firmware/7.22/Deustchland/ImageExtractedBINs/mtd6-ARM-RootFileSystem.bin  /mnt/c/FritzBox/6591cable/BinsToFlash/7.22-Deustchland/mtd6.bin
          mv /root/FritzBox/6591cable/firmware/7.22/Deustchland/ImageExtractedBINs/mtd7-ARM-Kernel.bin          /mnt/c/FritzBox/6591cable/BinsToFlash/7.22-Deustchland/mtd7.bin
          wget --no-check-certificate https://raw.githubusercontent.com/PeterPawn/YourFritz/master/eva_tools/EVA-Discover.ps1   -O /mnt/c/FritzBox/6591cable/BinsToFlash/7.22-Deustchland/EVA-Discover.ps1
          wget --no-check-certificate https://raw.githubusercontent.com/PeterPawn/YourFritz/master/eva_tools/EVA-FTP-Client.ps1 -O /mnt/c/FritzBox/6591cable/BinsToFlash/7.22-Deustchland/EVA-FTP-Client.ps1
          echo ""
          echo "c:\FritzBox\6591cable\BinsToFlash\7.22-Deustchland\EVA-Discover.ps1" > /mnt/c/FritzBox/6591cable/BinsToFlash/7.22-Deustchland/Flash.ps1
          echo "c:\FritzBox\6591cable\BinsToFlash\7.22-Deustchland\EVA-FTP-Client.ps1 -Verbose -Debug -ScriptBlock { GetEnvironmentFile env }" >> /mnt/c/FritzBox/6591cable/BinsToFlash/7.22-Deustchland/Flash.ps1
          echo "c:\FritzBox\6591cable\BinsToFlash\7.22-Deustchland\EVA-FTP-Client.ps1 -Verbose -Debug -ScriptBlock { UploadFlashFile c:\FritzBox\6591cable\BinsToFlash\7.22-Deustchland\mtd0.bin mtd0 }" >> /mnt/c/FritzBox/6591cable/BinsToFlash/7.22-Deustchland/Flash.ps1
          echo "c:\FritzBox\6591cable\BinsToFlash\7.22-Deustchland\EVA-FTP-Client.ps1 -Verbose -Debug -ScriptBlock { UploadFlashFile c:\FritzBox\6591cable\BinsToFlash\7.22-Deustchland\mtd1.bin mtd1 }" >> /mnt/c/FritzBox/6591cable/BinsToFlash/7.22-Deustchland/Flash.ps1
          echo "c:\FritzBox\6591cable\BinsToFlash\7.22-Deustchland\EVA-FTP-Client.ps1 -Verbose -Debug -ScriptBlock { UploadFlashFile c:\FritzBox\6591cable\BinsToFlash\7.22-Deustchland\mtd6.bin mtd6 }" >> /mnt/c/FritzBox/6591cable/BinsToFlash/7.22-Deustchland/Flash.ps1
          echo "c:\FritzBox\6591cable\BinsToFlash\7.22-Deustchland\EVA-FTP-Client.ps1 -Verbose -Debug -ScriptBlock { UploadFlashFile c:\FritzBox\6591cable\BinsToFlash\7.22-Deustchland\mtd7.bin mtd7 }" >> /mnt/c/FritzBox/6591cable/BinsToFlash/7.22-Deustchland/Flash.ps1
          echo "c:\FritzBox\6591cable\BinsToFlash\7.22-Deustchland\EVA-FTP-Client.ps1 -Verbose -Debug -ScriptBlock { RebootTheDevice }" >> /mnt/c/FritzBox/6591cable/BinsToFlash/7.22-Deustchland/Flash.ps1
          echo ""

          echo -e "${ColorGreen}--------------------------------------------------------------------------${ColorEnd}"
          echo -e "${ColorGreen}All files copied to c:\FritzBox\6591cable\BinsToFlash\7.22-Deustchland\ ${ColorEnd}"
          echo ""
          echo -e "${ColorGreen}Open PowerShell as Administrator and run:${ColorEnd}"
          echo -e "${ColorGreen}c:\FritzBox\6591cable\BinsToFlash\7.22-Deustchland\Flash.ps1${ColorEnd}"
          echo -e "${ColorGreen}--------------------------------------------------------------------------${ColorEnd}"
          echo ""

          exit

        ;;

        2)

          echo ""
          echo -e "${ColorGreen}---------------------------------------------------${ColorEnd}"
          echo -e "${ColorGreen}Downloading 7.22 firmware, International version...${ColorEnd}"
          echo -e "${ColorGreen}---------------------------------------------------${ColorEnd}"
          echo ""

          URL722i="http://download.avm.de/firmware/6591/8548751392/"
          File722i="FRITZ.Box_6591_Cable-07.22.image"

          echo ""
          echo -e "${ColorGreen}Installing some mandatory packages from the distro repository...${ColorEnd}"
          echo ""
          apt-get -y install wget tar git build-essential > /dev/null

          echo ""
          echo -e "${ColorGreen}Downloading the firmware update image file...${ColorEnd}"
          echo ""
          rm -rf /root/FritzBox/6591cable/firmware/7.22/International/Image/
          mkdir -p /root/FritzBox/6591cable/firmware/7.22/International/Image/ > /dev/null
          cd /root/FritzBox/6591cable/firmware/7.22/International/Image/
          wget --no-check-certificate $URL722i$File722i

          echo ""
          echo -e "${ColorGreen}Extracting the image file...${ColorEnd}"
          echo ""
          mkdir -p /root/FritzBox/6591cable/firmware/7.22/International/ImageExtracted/ > /dev/null
          cd /root/FritzBox/6591cable/firmware/7.22/International/ImageExtracted/
          tar xf /root/FritzBox/6591cable/firmware/7.22/International/Image/$File722i

          echo ""
          echo -e "${ColorGreen}Downloading uimg-tool source code...${ColorEnd}"
          echo ""
          rm -rf  /root/SourceCode/uimg-tool/ > /dev/null
          mkdir   /root/SourceCode/ > /dev/null
          cd      /root/SourceCode/
          git clone --depth=1 http://bitbucket.org/fesc2000/uimg-tool/

          echo ""
          echo -e "${ColorGreen}Compiling uimg-tool...${ColorEnd}"
          echo ""
          cd /root/SourceCode/uimg-tool/
          make

          echo ""
          echo -e "${ColorGreen}Extracting .bin files from .uimg file...${ColorEnd}"
          echo ""
          mkdir /root/FritzBox/6591cable/firmware/7.22/International/ImageExtractedBINs/ > /dev/null
          cd /root/FritzBox/6591cable/firmware/7.22/International/ImageExtractedBINs/
          /root/SourceCode/uimg-tool/uimg -u -n part /root/FritzBox/6591cable/firmware/7.22/International/ImageExtracted/var/firmware-update.uimg > /root/FritzBox/6591cable/firmware/7.22/International/ImageExtractedBINs/Extraction.log
          echo ""
          echo -e "${ColorGreen}Result:${ColorEnd}"
          echo ""
          cat /root/FritzBox/6591cable/firmware/7.22/International/ImageExtractedBINs/Extraction.log

          echo ""
          echo -e "${ColorGreen}Renaming .bin files for a better understanting of the flashing process...${ColorEnd}"
          echo ""
          mv /root/FritzBox/6591cable/firmware/7.22/International/ImageExtractedBINs/part_03_ATOM_ROOTFS.bin /root/FritzBox/6591cable/firmware/7.22/International/ImageExtractedBINs/mtd0-Atom-RootFileSystem.bin
          mv /root/FritzBox/6591cable/firmware/7.22/International/ImageExtractedBINs/part_02_ATOM_KERNEL.bin /root/FritzBox/6591cable/firmware/7.22/International/ImageExtractedBINs/mtd1-Atom-Kernel.bin
          mv /root/FritzBox/6591cable/firmware/7.22/International/ImageExtractedBINs/part_09_ARM_ROOTFS.bin  /root/FritzBox/6591cable/firmware/7.22/International/ImageExtractedBINs/mtd6-ARM-RootFileSystem.bin
          mv /root/FritzBox/6591cable/firmware/7.22/International/ImageExtractedBINs/part_08_ARM_KERNEL.bin  /root/FritzBox/6591cable/firmware/7.22/International/ImageExtractedBINs/mtd7-ARM-Kernel.bin

          echo ""
          echo -e "${ColorGreen}Moving files to windows folders...${ColorEnd}"
          echo ""
          mkdir -p /mnt/c/FritzBox/6591cable/BinsToFlash/7.22-International/ > /dev/null
          mv /root/FritzBox/6591cable/firmware/7.22/International/ImageExtractedBINs/mtd0-Atom-RootFileSystem.bin /mnt/c/FritzBox/6591cable/BinsToFlash/7.22-International/mtd0.bin
          mv /root/FritzBox/6591cable/firmware/7.22/International/ImageExtractedBINs/mtd1-Atom-Kernel.bin         /mnt/c/FritzBox/6591cable/BinsToFlash/7.22-International/mtd1.bin
          mv /root/FritzBox/6591cable/firmware/7.22/International/ImageExtractedBINs/mtd6-ARM-RootFileSystem.bin  /mnt/c/FritzBox/6591cable/BinsToFlash/7.22-International/mtd6.bin
          mv /root/FritzBox/6591cable/firmware/7.22/International/ImageExtractedBINs/mtd7-ARM-Kernel.bin          /mnt/c/FritzBox/6591cable/BinsToFlash/7.22-International/mtd7.bin
          wget --no-check-certificate https://raw.githubusercontent.com/PeterPawn/YourFritz/master/eva_tools/EVA-Discover.ps1   -O /mnt/c/FritzBox/6591cable/BinsToFlash/7.22-International/EVA-Discover.ps1
          wget --no-check-certificate https://raw.githubusercontent.com/PeterPawn/YourFritz/master/eva_tools/EVA-FTP-Client.ps1 -O /mnt/c/FritzBox/6591cable/BinsToFlash/7.22-International/EVA-FTP-Client.ps1
          echo ""
          echo "c:\FritzBox\6591cable\BinsToFlash\7.22-International\EVA-Discover.ps1" > /mnt/c/FritzBox/6591cable/BinsToFlash/7.22-International/Flash.ps1
          echo "c:\FritzBox\6591cable\BinsToFlash\7.22-International\EVA-FTP-Client.ps1 -Verbose -Debug -ScriptBlock { GetEnvironmentFile env }" >> /mnt/c/FritzBox/6591cable/BinsToFlash/7.22-International/Flash.ps1
          echo "c:\FritzBox\6591cable\BinsToFlash\7.22-International\EVA-FTP-Client.ps1 -Verbose -Debug -ScriptBlock { UploadFlashFile c:\FritzBox\6591cable\BinsToFlash\7.22-International\mtd0.bin mtd0 }" >> /mnt/c/FritzBox/6591cable/BinsToFlash/7.22-International/Flash.ps1
          echo "c:\FritzBox\6591cable\BinsToFlash\7.22-International\EVA-FTP-Client.ps1 -Verbose -Debug -ScriptBlock { UploadFlashFile c:\FritzBox\6591cable\BinsToFlash\7.22-International\mtd1.bin mtd1 }" >> /mnt/c/FritzBox/6591cable/BinsToFlash/7.22-International/Flash.ps1
          echo "c:\FritzBox\6591cable\BinsToFlash\7.22-International\EVA-FTP-Client.ps1 -Verbose -Debug -ScriptBlock { UploadFlashFile c:\FritzBox\6591cable\BinsToFlash\7.22-International\mtd6.bin mtd6 }" >> /mnt/c/FritzBox/6591cable/BinsToFlash/7.22-International/Flash.ps1
          echo "c:\FritzBox\6591cable\BinsToFlash\7.22-International\EVA-FTP-Client.ps1 -Verbose -Debug -ScriptBlock { UploadFlashFile c:\FritzBox\6591cable\BinsToFlash\7.22-International\mtd7.bin mtd7 }" >> /mnt/c/FritzBox/6591cable/BinsToFlash/7.22-International/Flash.ps1
          echo "c:\FritzBox\6591cable\BinsToFlash\7.22-International\EVA-FTP-Client.ps1 -Verbose -Debug -ScriptBlock { RebootTheDevice }" >> /mnt/c/FritzBox/6591cable/BinsToFlash/7.22-International/Flash.ps1
          echo ""

          echo -e "${ColorGreen}--------------------------------------------------------------------------${ColorEnd}"
          echo -e "${ColorGreen}All files copied to c:\FritzBox\6591cable\BinsToFlash\7.22-International\ ${ColorEnd}"
          echo ""
          echo -e "${ColorGreen}Open PowerShell as Administrator and run:${ColorEnd}"
          echo -e "${ColorGreen}c:\FritzBox\6591cable\BinsToFlash\7.22-International\Flash.ps1${ColorEnd}"
          echo -e "${ColorGreen}--------------------------------------------------------------------------${ColorEnd}"
          echo ""

          exit

        ;;

      esac

    done

echo ""
echo "------------------------------------------"
echo ""
echo "Time expired. No selection has been made."
echo ""
echo "Re-run the script to try again"
echo ""
echo "------------------------------------------"
echo ""

