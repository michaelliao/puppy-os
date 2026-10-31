###############################################################################
# 编译 Puppy OS 内核
###############################################################################

# riscv工具链前缀:
TOOLPREFIX = riscv64-unknown-elf-

# GCC工具链实际名称:
CC = $(TOOLPREFIX)gcc
AS = $(TOOLPREFIX)as
AR = $(TOOLPREFIX)ar
LD = $(TOOLPREFIX)ld
GDB = $(TOOLPREFIX)gdb
OBJCOPY = $(TOOLPREFIX)objcopy
OBJDUMP = $(TOOLPREFIX)objdump

# GCC编译器参数:
CFLAGS = -std=gnu23 -march=rv32g -mabi=ilp32 -Wall -nostdlib -fno-builtin -fno-pic -fno-pie -fno-common -mno-relax -mcmodel=medany

# 链接器参数:
LDFLAGS = -m elf32lriscv -static -nostdlib -z max-page-size=4096

# QEMU参数:
QEMU = /home/ubuntu/.local/bin/qemu-system-riscv32-vga

QFLAGS = -machine virt -smp 1 -bios none -semihosting
QFLAGS += -m 32M
QFLAGS += -display none
QFLAGS += -chardev file,id=uart0,path=/dev/stdout,input-path=/dev/stdin
QFLAGS += -serial chardev:uart0
QFLAGS += -chardev file,id=vgaterm,path=$$VGA_TARGET

# 编译输出目录:
BUILD_DIR = ./build

# ELF文件:
KERNEL_ELF = $(BUILD_DIR)/kernel.elf

# 链接脚本:
KERNEL_LD = kernel.ld

# BIN文件:
KERNEL_BIN = $(BUILD_DIR)/kernel.bin

SRCS = $(wildcard *.c)
DEPS = $(patsubst %.c, $(BUILD_DIR)/%.d, $(SRCS))

ASMS = $(wildcard *.S)

OBJS = $(patsubst %.S, $(BUILD_DIR)/%.o, $(ASMS))
OBJS += $(patsubst %.c, $(BUILD_DIR)/%.o, $(SRCS))

# default rule:
all: $(KERNEL_BIN)

$(KERNEL_BIN): $(KERNEL_ELF)
	$(OBJCOPY) -O binary $< $@
	@echo "kernel: $$(du -h $@)"

$(KERNEL_ELF): $(OBJS)
	$(LD) $(LDFLAGS) -T $(KERNEL_LD) -o $@ $^
	$(call check_static_link, $@)

$(BUILD_DIR)/%.o: %.S | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c -o $@ $<

$(BUILD_DIR)/%.o: %.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c -o $@ $<
	$(CC) $(CFLAGS) -S -o $@.txt $<

$(BUILD_DIR)/%.d: %.c | $(BUILD_DIR)
	@echo 'generate $@...'
	@rm -f $@; \
	$(CC) $(CFLAGS) -MM $< >$@.tmp; \
	sed 's,\($*\)\.o[ :]*,$(BUILD_DIR)/\1.o $@: ,g' < $@.tmp > $@; \
	rm -f $@.tmp

$(BUILD_DIR):
	mkdir $@

clean:
	rm -rf $(BUILD_DIR) $(KERNEL_BIN)

# 运行qemu:
qemu:
	@if [ ! -f ~/.local/qemu-vga/vga.tty ]; then \
		echo "ERROR: Please run 'script/start-vga.sh' in your display window first!"; \
		exit 1; \
	fi
	@echo 'Press Ctrl-C to exit QEMU.'
	@VGA_TARGET=$$(cat ~/.local/qemu-vga/vga.tty); \
	echo "Launching QEMU... Sending VGA to $$VGA_TARGET"; \
	STTY_SAVED=$$(stty -g); \
	trap 'stty $$STTY_SAVED 2>/dev/null; echo' EXIT INT TERM; \
	stty -icanon -echo min 1 time 0; \
	$(QEMU) $(QFLAGS) -kernel $(KERNEL_BIN) 2>&1 | tee qemu.log
	@exit_code=$$(($$? >> 1)); \
	echo "QEMU exit code: $$?"

-include $(DEPS)
