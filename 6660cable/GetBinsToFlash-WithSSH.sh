#!/bin/bash

# This script is given to the word under the concept of "Public domain software".
# You can do whatever you want with it because is "really free",
# not "free with terms and conditions", like GNU license and other similar crap.
# If you talk all day about freedom, show it and make your code "really free".
# You don´t have to accept any kind of license nor terms and conditions to use it,
# cause it has no CopyRight or CopyLeft.
# Enjoy!

ColorRed='\033[1;31m'
ColorGreen='\033[1;32m'
ColorEnd='\033[0m'

apt-get -y update > /dev/null
apt-get -y install dialog rsync squashfs-tools > /dev/null

menu=(dialog --timeout 5 --checklist "FritzBox 6660 cable, SSH injection (SpaceBar to mark, Enter to proceed):" 22 86 16)
  options=(1 "Get Bins to flash 7.23 Firmware with SSH, Deustchland version" off
           2 "Get Bins to flash 7.23 Firmware with SSH, International version" off)
  choices=$("${menu[@]}" "${options[@]}" 2>&1 >/dev/tty)
  clear

  for choice in $choices
    do
      case $choice in

        1)
          echo ""
          echo "Downloading ffritz source code..."
          echo ""
          rm -rf  /root/SourceCode/ffritz/ > /dev/null
          mkdir   /root/SourceCode/ 2> /dev/null
          cd      /root/SourceCode/
          git clone --branch 6591 https://fesc2000@bitbucket.org/fesc2000/ffritz.git

          echo ""
          echo "Compiling..."
          echo ""
          echo "URL=http://download.avm.de/firmware/6660/8741253231/FRITZ.Box_6660_Cable-07.23.image" > /root/SourceCode/ffritz/conf.mk
          echo "KEEP_ORIG = 1" >> /root/SourceCode/ffritz/conf.mk
          echo "SDK_DOWNLOAD=1" >> /root/SourceCode/ffritz/conf.mk
          cd /root/SourceCode/ffritz/
          make
          ModImage=$(find /root/SourceCode/ffritz/images/ -type f -name *.tar)
          mkdir /root/SourceCode/ffritz/images/UBinWithSSH/ > /dev/null
          tar -C /root/SourceCode/ffritz/images/UBinWithSSH/ -xvf $ModImage
          mkdir /root/SourceCode/ffritz/images/BinsWithSSH/ > /dev/null
          cd /root/SourceCode/ffritz/images/BinsWithSSH/
          /root/SourceCode/uimg-tool/uimg -u -n part /root/SourceCode/ffritz/images/UBinWithSSH/var/firmware-update.uimg > /root/SourceCode/ffritz/images/BinsWithSSH/Extraction.log
          mv /root/SourceCode/ffritz/images/BinsWithSSH/part_03_ATOM_ROOTFS.bin /root/SourceCode/ffritz/images/BinsWithSSH/mtd0-Atom-RootFileSystem.bin
          mv /root/SourceCode/ffritz/images/BinsWithSSH/part_02_ATOM_KERNEL.bin /root/SourceCode/ffritz/images/BinsWithSSH/mtd1-Atom-Kernel.bin
          mv /root/SourceCode/ffritz/images/BinsWithSSH/part_09_ARM_ROOTFS.bin  /root/SourceCode/ffritz/images/BinsWithSSH/mtd6-ARM-RootFileSystem.bin
          mv /root/SourceCode/ffritz/images/BinsWithSSH/part_08_ARM_KERNEL.bin  /root/SourceCode/ffritz/images/BinsWithSSH/mtd7-ARM-Kernel.bin

          echo ""
          echo "Moving files to windows folders..."
          echo ""
          mkdir -p /mnt/c/FritzBox/6660cable/BinsToFlash/7.23deustchland/WithSSH/ > /dev/null
          mv /root/SourceCode/ffritz/images/BinsWithSSH/mtd0-Atom-RootFileSystem.bin /mnt/c/FritzBox/6660cable/BinsToFlash/7.23deustchland/WithSSH/mtd0.bin
          mv /root/SourceCode/ffritz/images/BinsWithSSH/mtd1-Atom-Kernel.bin         /mnt/c/FritzBox/6660cable/BinsToFlash/7.23deustchland/WithSSH/mtd1.bin
          mv /root/SourceCode/ffritz/images/BinsWithSSH/mtd6-ARM-RootFileSystem.bin  /mnt/c/FritzBox/6660cable/BinsToFlash/7.23deustchland/WithSSH/mtd6.bin
          mv /root/SourceCode/ffritz/images/BinsWithSSH/mtd7-ARM-Kernel.bin          /mnt/c/FritzBox/6660cable/BinsToFlash/7.23deustchland/WithSSH/mtd7.bin
          wget --no-check-certificate https://raw.githubusercontent.com/PeterPawn/YourFritz/master/eva_tools/EVA-Discover.ps1   -O /mnt/c/FritzBox/6660cable/BinsToFlash/7.23deustchland/EVA-Discover.ps1
          wget --no-check-certificate https://raw.githubusercontent.com/PeterPawn/YourFritz/master/eva_tools/EVA-FTP-Client.ps1 -O /mnt/c/FritzBox/6660cable/BinsToFlash/7.23deustchland/EVA-FTP-Client.ps1
          echo ""
          echo "c:\FritzBox\6660cable\BinsToFlash\7.23deustchland\EVA-Discover.ps1" > /mnt/c/FritzBox/6660cable/BinsToFlash/7.23deustchland/FlashWithSSH.ps1
          echo "c:\FritzBox\6660cable\BinsToFlash\7.23deustchland\EVA-FTP-Client.ps1 -Verbose -Debug -ScriptBlock { GetEnvironmentFile env }" >> /mnt/c/FritzBox/6660cable/BinsToFlash/7.23deustchland/FlashWithSSH.ps1
          echo "c:\FritzBox\6660cable\BinsToFlash\7.23deustchland\EVA-FTP-Client.ps1 -Verbose -Debug -ScriptBlock { UploadFlashFile c:\FritzBox\6660cable\BinsToFlash\7.23deustchland\WithSSH\mtd0.bin mtd0 }" >> /mnt/c/FritzBox/6660cable/BinsToFlash/7.23deustchland/FlashWithSSH.ps1
          echo "c:\FritzBox\6660cable\BinsToFlash\7.23deustchland\EVA-FTP-Client.ps1 -Verbose -Debug -ScriptBlock { UploadFlashFile c:\FritzBox\6660cable\BinsToFlash\7.23deustchland\WithSSH\mtd1.bin mtd1 }" >> /mnt/c/FritzBox/6660cable/BinsToFlash/7.23deustchland/FlashWithSSH.ps1
          echo "c:\FritzBox\6660cable\BinsToFlash\7.23deustchland\EVA-FTP-Client.ps1 -Verbose -Debug -ScriptBlock { UploadFlashFile c:\FritzBox\6660cable\BinsToFlash\7.23deustchland\WithSSH\mtd6.bin mtd6 }" >> /mnt/c/FritzBox/6660cable/BinsToFlash/7.23deustchland/FlashWithSSH.ps1
          echo "c:\FritzBox\6660cable\BinsToFlash\7.23deustchland\EVA-FTP-Client.ps1 -Verbose -Debug -ScriptBlock { UploadFlashFile c:\FritzBox\6660cable\BinsToFlash\7.23deustchland\WithSSH\mtd7.bin mtd7 }" >> /mnt/c/FritzBox/6660cable/BinsToFlash/7.23deustchland/FlashWithSSH.ps1
          echo "c:\FritzBox\6660cable\BinsToFlash\7.23deustchland\EVA-FTP-Client.ps1 -Verbose -Debug -ScriptBlock { RebootTheDevice }" >> /mnt/c/FritzBox/6660cable/BinsToFlash/7.23deustchland/FlashWithSSH.ps1
          echo ""
          echo "All files copied to c:\FritzBox\6660cable\BinsToFlash\7.23deustchland\ "
          echo ""
          echo "Open PowerShell as Administrator and run:"
          echo "c:\FritzBox\6660cable\BinsToFlash\7.23deustchland\FlashWithSSH.ps1"
          echo ""
          exit

        ;;

        2)


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

