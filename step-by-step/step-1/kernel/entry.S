###############################################################################
# kernel入口
###############################################################################

.section .text.entry
.global _entry

_entry:
    # 仅启用 CPU 0, 如果有多个 CPU , 则其他 CPU 直接进入 HALT 状态
    # 读取 hart id -> t0 寄存器:
    csrr t0, mhartid
    # 如果 hart id != 0, 则跳转至 _halt:
    bne t0, zero, _halt

    # bss 段清零:
    la t0, bss_start
    la t1, bss_end
_bss_loop:
    bge t0, t1, _bss_done
    sw zero, 0(t0)
    addi t0, t0, 4
    j _bss_loop
_bss_done:

    # stack_bottom ~ stack_top 是定义在 kernel.ld 的内核栈空间
    # 设置 sp 为栈顶地址 (RISC-V的栈方向是从高地址向低地址增长):
    la sp, stack_top

    # 调用 main.c / init() 函数:
    call init

_halt:
    wfi
	j _halt
