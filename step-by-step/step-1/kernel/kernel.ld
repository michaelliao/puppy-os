OUTPUT_ARCH( "riscv" )
ENTRY( _entry )

SECTIONS
{
    /* 确保入口地址是 0x80000000 */
    . = 0x80000000;

    /* 代码段 */
    .text : {
        /* 确保 _entry 是入口地址 */
        *(.text.entry);

        *(.text .text.*);

        . = ALIGN(4096);
        text_end = .;
    }

    /* 常量 */
    .rodata : {
        . = ALIGN(4096);
        *(.srodata .srodata.*);
        *(.rodata .rodata.*);
        . = ALIGN(4096);
        rodata_end = .;
    }

    /* 已初始化的全局、静态变量 */
    .data : {
        . = ALIGN(4096);
        *(.sdata .sdata.*);
        *(.data .data.*);
    }

    /* 未初始化的全局、静态变量 */
    .bss : {
        . = ALIGN(4);
        PROVIDE(bss_start = .);
        *(.sbss .sbss.*);
        *(.bss .bss.*);
        PROVIDE(bss_end = .);

        /* 内核栈空间 = 4K */
        . = ALIGN(4096);
        PROVIDE(stack_bottom = .);
        . += 4096;
        PROVIDE(stack_top = .);
    }

    /* kernel 结束地址 */
    . = ALIGN(4096);
    kernel_end = .;
}
