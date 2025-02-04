
all: test.img

nyancat: nyancat.asm
	nasm nyancat.asm
test.img: nyancat
	fallocate -l 2M _test.img
	/usr/sbin/parted _test.img mklabel msdos
	dd if=nyancat of=_test.img conv=notrunc
	mv _test.img test.img


run: test.img
	qemu-system-x86_64 -hda test.img -audiodev pa,id=snd0 -machine pcspk-audiodev=snd0
clean:
	rm test.img
	rm nyancat
	
