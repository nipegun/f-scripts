#!/bin/bash

# This script is given to the word under the concept of "Public domain software".
# You can do whatever you want with it because is "really free",
# not "free with terms and conditions", like GNU license and other similar crap.
# If you talk all day about freedom, show it and make your code "really free".
# You don´t have to accept any kind of license nor terms and conditions to use it,
# cause it has no CopyRight or CopyLeft.
# Enjoy!

# -----------------------------------------------------------------------------------
# The below commands downloads a firmware update for the Fritz!Box 6660 cablerouter.
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

          URL722d="http://download.avm.de/firmware/6660/8741253231/"
          File722d="FRITZ.Box_6660_Cable-07.23.image"

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
          wget --no-check-certificate $URL722d$File722d

          echo ""
          echo "Extracting the image file..."
          echo ""
          mkdir -p /root/FritzBox/6660cable/firmware/7.23/Deustchland/ImageExtracted/ > /dev/null
          cd /root/FritzBox/6660cable/firmware/7.23/Deustchland/ImageExtracted/
          tar xf /root/FritzBox/6660cable/firmware/7.23/Deustchland/Image/$File722d

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
          echo "Moving files to windows folders..."
          echo ""
          mkdir -p /mnt/c/FritzBox/6660cable/BinsToFlash/7.23Deustchland/ > /dev/null
          mv /root/FritzBox/6660cable/firmware/7.23/Deustchland/ImageExtractedBINs/mtd0-Atom-RootFileSystem.bin /mnt/c/FritzBox/6660cable/BinsToFlash/7.23Deustchland/mtd0.bin
          mv /root/FritzBox/6660cable/firmware/7.23/Deustchland/ImageExtractedBINs/mtd1-Atom-Kernel.bin         /mnt/c/FritzBox/6660cable/BinsToFlash/7.23Deustchland/mtd1.bin
          mv /root/FritzBox/6660cable/firmware/7.23/Deustchland/ImageExtractedBINs/mtd6-ARM-RootFileSystem.bin  /mnt/c/FritzBox/6660cable/BinsToFlash/7.23Deustchland/mtd6.bin
          mv /root/FritzBox/6660cable/firmware/7.23/Deustchland/ImageExtractedBINs/mtd7-ARM-Kernel.bin          /mnt/c/FritzBox/6660cable/BinsToFlash/7.23Deustchland/mtd7.bin
          wget --no-check-certificate https://raw.githubusercontent.com/PeterPawn/YourFritz/master/eva_tools/EVA-Discover.ps1   -O /mnt/c/FritzBox/6660cable/BinsToFlash/7.23Deustchland/EVA-Discover.ps1
          wget --no-check-certificate https://raw.githubusercontent.com/PeterPawn/YourFritz/master/eva_tools/EVA-FTP-Client.ps1 -O /mnt/c/FritzBox/6660cable/BinsToFlash/7.23Deustchland/EVA-FTP-Client.ps1
          echo ""
          echo "c:\FritzBox\6660cable\BinsToFlash\7.23Deustchland\EVA-Discover.ps1" > /mnt/c/FritzBox/6660cable/BinsToFlash/7.23Deustchland/Flash.ps1
          echo "c:\FritzBox\6660cable\BinsToFlash\7.23Deustchland\EVA-FTP-Client.ps1 -Verbose -Debug -ScriptBlock { GetEnvironmentFile env }" >> /mnt/c/FritzBox/6660cable/BinsToFlash/7.23Deustchland/Flash.ps1
          echo "c:\FritzBox\6660cable\BinsToFlash\7.23Deustchland\EVA-FTP-Client.ps1 -Verbose -Debug -ScriptBlock { UploadFlashFile c:\FritzBox\6660cable\BinsToFlash\7.23Deustchland\mtd0.bin mtd0 }" >> /mnt/c/FritzBox/6660cable/BinsToFlash/7.23Deustchland/Flash.ps1
          echo "c:\FritzBox\6660cable\BinsToFlash\7.23Deustchland\EVA-FTP-Client.ps1 -Verbose -Debug -ScriptBlock { UploadFlashFile c:\FritzBox\6660cable\BinsToFlash\7.23Deustchland\mtd1.bin mtd1 }" >> /mnt/c/FritzBox/6660cable/BinsToFlash/7.23Deustchland/Flash.ps1
          echo "c:\FritzBox\6660cable\BinsToFlash\7.23Deustchland\EVA-FTP-Client.ps1 -Verbose -Debug -ScriptBlock { UploadFlashFile c:\FritzBox\6660cable\BinsToFlash\7.23Deustchland\mtd6.bin mtd6 }" >> /mnt/c/FritzBox/6660cable/BinsToFlash/7.23Deustchland/Flash.ps1
          echo "c:\FritzBox\6660cable\BinsToFlash\7.23Deustchland\EVA-FTP-Client.ps1 -Verbose -Debug -ScriptBlock { UploadFlashFile c:\FritzBox\6660cable\BinsToFlash\7.23Deustchland\mtd7.bin mtd7 }" >> /mnt/c/FritzBox/6660cable/BinsToFlash/7.23Ddeustchland/Flash.ps1
          echo "c:\FritzBox\6660cable\BinsToFlash\7.23Deustchland\EVA-FTP-Client.ps1 -Verbose -Debug -ScriptBlock { RebootTheDevice }" >> /mnt/c/FritzBox/6660cable/BinsToFlash/7.23Deustchland/Flash.ps1
          echo ""
          echo "--------------------------------------------------------------------------"
          echo "All files copied to c:\FritzBox\6660cable\BinsToFlash\7.23Deustchland\ "
          echo ""
          echo "Open PowerShell as Administrator and run:"
          echo "c:\FritzBox\6660cable\BinsToFlash\7.23Deustchland\Flash.ps1"
          echo "--------------------------------------------------------------------------"
          echo ""

          exit

        ;;

        2)
          URL722i="http://download.avm.de/firmware/6660/8741253231/"
          File722i="FRITZ.Box_6660_Cable-07.23.image"

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
          wget --no-check-certificate $URL722i$File722i

          echo ""
          echo "Extracting the image file..."
          echo ""
          mkdir -p /root/FritzBox/6660cable/firmware/7.23/International/ImageExtracted/ > /dev/null
          cd /root/FritzBox/6660cable/firmware/7.23/International/ImageExtracted/
          tar xf /root/FritzBox/6660cable/firmware/7.23/International/Image/$File722i

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
          echo "Moving files to windows folders..."
          echo ""
          mkdir -p /mnt/c/FritzBox/6660cable/BinsToFlash/7.23International/ > /dev/null
          mv /root/FritzBox/6660cable/firmware/7.23/International/ImageExtractedBINs/mtd0-Atom-RootFileSystem.bin /mnt/c/FritzBox/6660cable/BinsToFlash/7.23International/mtd0.bin
          mv /root/FritzBox/6660cable/firmware/7.23/International/ImageExtractedBINs/mtd1-Atom-Kernel.bin         /mnt/c/FritzBox/6660cable/BinsToFlash/7.23International/mtd1.bin
          mv /root/FritzBox/6660cable/firmware/7.23/International/ImageExtractedBINs/mtd6-ARM-RootFileSystem.bin  /mnt/c/FritzBox/6660cable/BinsToFlash/7.23International/mtd6.bin
          mv /root/FritzBox/6660cable/firmware/7.23/International/ImageExtractedBINs/mtd7-ARM-Kernel.bin          /mnt/c/FritzBox/6660cable/BinsToFlash/7.23International/mtd7.bin
          wget --no-check-certificate https://raw.githubusercontent.com/PeterPawn/YourFritz/master/eva_tools/EVA-Discover.ps1   -O /mnt/c/FritzBox/6660cable/BinsToFlash/7.23International/EVA-Discover.ps1
          wget --no-check-certificate https://raw.githubusercontent.com/PeterPawn/YourFritz/master/eva_tools/EVA-FTP-Client.ps1 -O /mnt/c/FritzBox/6660cable/BinsToFlash/7.23International/EVA-FTP-Client.ps1
          echo ""
          echo "c:\FritzBox\6660cable\BinsToFlash\7.23International\EVA-Discover.ps1" > /mnt/c/FritzBox/6660cable/BinsToFlash/7.23International/Flash.ps1
          echo "c:\FritzBox\6660cable\BinsToFlash\7.23International\EVA-FTP-Client.ps1 -Verbose -Debug -ScriptBlock { GetEnvironmentFile env }" >> /mnt/c/FritzBox/6660cable/BinsToFlash/7.23International/Flash.ps1
          echo "c:\FritzBox\6660cable\BinsToFlash\7.23International\EVA-FTP-Client.ps1 -Verbose -Debug -ScriptBlock { UploadFlashFile c:\FritzBox\6660cable\BinsToFlash\7.23International\mtd0.bin mtd0 }" >> /mnt/c/FritzBox/6660cable/BinsToFlash/7.23International/Flash.ps1
          echo "c:\FritzBox\6660cable\BinsToFlash\7.23International\EVA-FTP-Client.ps1 -Verbose -Debug -ScriptBlock { UploadFlashFile c:\FritzBox\6660cable\BinsToFlash\7.23International\mtd1.bin mtd1 }" >> /mnt/c/FritzBox/6660cable/BinsToFlash/7.23International/Flash.ps1
          echo "c:\FritzBox\6660cable\BinsToFlash\7.23International\EVA-FTP-Client.ps1 -Verbose -Debug -ScriptBlock { UploadFlashFile c:\FritzBox\6660cable\BinsToFlash\7.23International\mtd6.bin mtd6 }" >> /mnt/c/FritzBox/6660cable/BinsToFlash/7.23International/Flash.ps1
          echo "c:\FritzBox\6660cable\BinsToFlash\7.23International\EVA-FTP-Client.ps1 -Verbose -Debug -ScriptBlock { UploadFlashFile c:\FritzBox\6660cable\BinsToFlash\7.23International\mtd7.bin mtd7 }" >> /mnt/c/FritzBox/6660cable/BinsToFlash/7.23International/Flash.ps1
          echo "c:\FritzBox\6660cable\BinsToFlash\7.23International\EVA-FTP-Client.ps1 -Verbose -Debug -ScriptBlock { RebootTheDevice }" >> /mnt/c/FritzBox/6660cable/BinsToFlash/7.23International/Flash.ps1
          echo ""
          echo "--------------------------------------------------------------------------"
          echo "All files copied to c:\FritzBox\6660cable\BinsToFlash\7.23International\ "
          echo ""
          echo "Open PowerShell as Administrator and run:"
          echo "c:\FritzBox\6660cable\BinsToFlash\7.23International\Flash.ps1"
          echo "--------------------------------------------------------------------------"
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

