if [ ! -f './hyper.cfg' ]
then
	echo "Can't find hyper.cfg in ."
	exit
fi

if [ ! -f './KRONOS.BIN' ]
then
	echo "Can't find KRONOS.BIN in ."
	exit
fi

nm -n ./KRONOS.BIN | awk '/ T / {print $1,$3} / t / {print $1, $3}' | python3 genkmap.py

dd if=/dev/zero bs=1M count=0 seek=128 of=./KRONOS.IMG

parted -s KRONOS.IMG mklabel msdos
parted -s KRONOS.IMG mkpart primary 1 100%

LOOPDEV=$(sudo losetup -L -P --show -f ./KRONOS.IMG)
LOOPPART=$LOOPDEV"p1"

sudo mkfs.vfat -F 32 $LOOPPART


sudo mkdir -p ./image
sudo mount $LOOPPART --target ./image
sudo mkdir ./image/boot

sudo cp ./kmap.bin  ./image/boot/kmap.bin
sudo cp ./hyper.cfg  ./image/boot/hyper.cfg
sudo cp ./KRONOS.BIN ./image/boot/KRONOS.BIN

sleep 0.5

sudo umount $LOOPPART
sudo rmdir ./image


sudo losetup --detach $LOOPDEV

./hyper_install ./KRONOS.IMG
