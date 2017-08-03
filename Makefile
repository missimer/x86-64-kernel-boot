ISO_FILE=kernel.iso

.PHONY: all
.PHONY: kernel
.PHONY: qemu
.PHONY: iso
.PHONY: clean

all: kernel

kernel:
	make -C kernel all

qemu: $(ISO_FILE)
	qemu-system-x86_64 -cdrom $(ISO_FILE) -serial stdio -m 1024M

clean:
	make -C kernel clean
	rm -rf iso
	rm -rf $(ISO_FILE)

iso: $(ISO_FILE)

$(ISO_FILE): kernel
	mkdir -p iso/boot/grub
	cp grub.cfg iso/boot/grub/
	cp kernel/kernel iso/boot/
	grub2-mkrescue -o $(ISO_FILE) iso
