obj-m       = datapath_switchdev.o
KVERSION    := $(shell uname -r)
PWD         := $(shell pwd)
all:
	make -C /lib/modules/$(KVERSION)/build M=$(PWD) modules 
	#make -C /home/dccom/kernel/linux-4.9 M=$(PWD) modules 
clean:
	make -C /lib/modules/$(KVERSION)/build M=$(PWD) clean

	
	