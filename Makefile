obj-m := xpad.o
KVERSION := $(shell uname -r)

# Builds your default xpad.c
all:
	@$(MAKE) -C /lib/modules/$(KVERSION)/build M=$(PWD) modules

# Builds the patched xpad-mainline.c
mainline:
	@( \
		mv xpad.c xpad.c.bak && \
		ln -s xpad-mainline.c xpad.c && \
		$(MAKE) -C /lib/modules/$(KVERSION)/build M=$(PWD) modules; \
		EXIT_CODE=$$?; \
		rm xpad.c && \
		mv xpad.c.bak xpad.c; \
		exit $$EXIT_CODE \
	)

# Installs the last-built xpad.ko
install:
	@if ! [ -f xpad.ko ]; then echo "ERROR: xpad.ko not found. Run 'make' or 'make mainline' first." >&2; exit 1; fi
	install -m 0755 -d /lib/modules/$(KVERSION)/kernel/drivers/input/joystick/
	install -m 0644 xpad.ko /lib/modules/$(KVERSION)/kernel/drivers/input/joystick/
	/sbin/depmod -a

clean:
	@$(MAKE) -C /lib/modules/$(KVERSION)/build M=$(PWD) clean
	@if [ -f xpad.c.bak ]; then rm -f xpad.c && mv xpad.c.bak xpad.c; fi

uninstall:
	rm -f /lib/modules/$(KVERSION)/kernel/drivers/input/joystick/xpad.ko
	/sbin/depmod -a
