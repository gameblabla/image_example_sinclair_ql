#!/bin/bash

# Check that the target file name is provided as a parameter
if [ $# -ne 1 ]; then
    echo "Usage: $0 <target>"
    exit 1
fi

# https://unix.stackexchange.com/questions/219268/how-to-add-new-lines-when-using-echo
print()
	case    ${IFS- } in
	(\ *)   printf  %b\\n "$*";;
	(*)     IFS=\ $IFS
	printf  %b\\n "$*"
	IFS=${IFS#?}
esac


# Get the target file name from the command line parameter
TARGET=$1

rm -f boot $TARGET 
rm *.o
rm -r GAME

mkdir -p GAME

as68 zx0.s zx0.o
as68 nv.s nv.o
as68 aplib.s aplib.o
as68 slz.s slz.o
as68 lz4w.s lz4w.o

# Compile the C program with qcc and capture the output
OUTPUT=$(qdos-gcc -Os -fomit-frame-pointer -o $TARGET main.c zx0.o lz4w.o nv.o aplib.o slz.o 2>&1)

if ! test -f "$TARGET"; then
    echo $OUTPUT
    echo "Error: target file '$TARGET' not found"
    exit 1
fi

echo $OUTPUT

# Extract the data space size from the qcc output
DATASPACE=$(echo "$OUTPUT" | grep -oP '(?<=dataspace )[0-9a-fA-F]+')

filesize=$(stat -c %s ${TARGET})
DEFAULT_DEVICE="flp1"

echo "30 mem=RESPR($filesize)" >> boot
echo "40 LBYTES \"${DEFAULT_DEVICE}_${TARGET}\",mem" >> boot
echo "60 EXEC_W \"${DEFAULT_DEVICE}_${TARGET}\"" >> boot


# Create a "GAME.QCF" file with the appropriate QPC2 configuration
echo "Ram=128K" > GAME.QCF
echo "MainRom=QL ROMs\QL_ROM_JS" >> GAME.QCF
echo "BackRomActive=No" >> GAME.QCF
echo "ExpRomActive=No" >> GAME.QCF
echo "UseFloppyName=Yes" >> GAME.QCF
echo "FloppyName=flp" >> GAME.QCF
echo "UseHardDiskName=No" >> GAME.QCF
echo "HardDiskName=win" >> GAME.QCF
echo "HasRamDisk=Yes" >> GAME.QCF
echo "RamDiskName=RAM" >> GAME.QCF
echo "HasParPort=No" >> GAME.QCF
echo "Subdirs=Off" >> GAME.QCF
echo "Speed=QL" >> GAME.QCF
echo "FastStartup=Yes" >> GAME.QCF
echo "AutoStartSession=Yes" >> GAME.QCF
echo "FirstKey=None" >> GAME.QCF
echo "AcceleratedGraphics=Yes" >> GAME.QCF
echo "Sound=On" >> GAME.QCF
echo "Slot1=PAK:" >> GAME.QCF
echo "Slot2=Empty" >> GAME.QCF
echo "Slot3=Empty" >> GAME.QCF
echo "Slot4=Empty" >> GAME.QCF
echo "Slot5=Empty" >> GAME.QCF
echo "Slot6=Empty" >> GAME.QCF
echo "Slot7=Empty" >> GAME.QCF
echo "Slot8=Empty" >> GAME.QCF
echo "PakDir1=PAK:" >> GAME.QCF
echo "WindowHeight=376" >> GAME.QCF
echo "PakDir1=" >> GAME.QCF

# Create a ZIP archive containing the game files and QCF file
qlzip -r GAME.qlpak GAME.QCF boot $TARGET IMGZX0 IMGAP IMGSLZ IMGNV IMGLZ4W

cp $TARGET GAME/$TARGET
cp boot GAME/boot
cp *ZX0 GAME
cp *NV GAME
cp *AP GAME
cp *SLZ GAME
cp *LZ4W GAME
