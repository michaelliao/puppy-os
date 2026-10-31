#include <stdint.h>

/********************************************************************************

VGA text mode: https://en.wikipedia.org/wiki/VGA_text_mode

文本缓冲区 / Text Buffer

模式：640 x 480，字符大小：8 x 16 pixels，行数：25，列数：80

缓冲区大小: 80 x 25 x 2 = 4000 bytes

一个字符由 2 bytes 表示，低位是 ascii 码，高位是 背景色/前景色

 15    12 11     8 7               0
┌────────┬────────┬─────────────────┐
│bg color│fg color│   code point    │
└────────┴────────┴─────────────────┘

背景色和前景色都是索引色:

Indexed color: https://en.wikipedia.org/wiki/Color_Graphics_Adapter

0x0 = #000000 = black
0x1 = #0000AA = blue
0x2 = #00AA00 = green
0x3 = #00AAAA = cyan
0x4 = #AA0000 = red
0x5 = #AA00AA = magenta
0x6 = #AA5500 = brown
0x7 = #AAAAAA = light gray
0x8 = #555555 = dark gray
0x9 = #5555FF = light blue
0xA = #55FF55 = light green
0xB = #55FFFF = light cyan
0xC = #FF5555 = light red
0xD = #FF55FF = light magenta
0xE = #FFFF55 = yellow
0xF = #FFFFFF = white

********************************************************************************/

// VGA-Text地址
#define VGA_TEXT 0x10010000

#define VGA_TEXT_COLS 80
#define VGA_TEXT_ROWS 25

#define VGA_BUFFER_SIZE (VGA_TEXT_ROWS * VGA_TEXT_COLS)

#define VGA_REG_RESET        0x10    /* 重置 */
#define VGA_REG_FB_ADDR_LO   0x18    /* frame buffer低地址 */
#define VGA_REG_FB_ADDR_HI   0x1C    /* Frame buffer高地址 */

#define VGA_WRITE(reg, v) (*((volatile uint32_t *)(VGA_TEXT + (reg))) = (uint32_t)(v))

// 帧缓冲区: 静态分配在 BSS 中 (64字节对齐):
static uint16_t frame_buffer[VGA_BUFFER_SIZE] __attribute__((aligned(64)));

union vga_char {
	char data[2];
	uint16_t value;
};

void init()
{
    VGA_WRITE(VGA_REG_RESET, 1);
    VGA_WRITE(VGA_REG_FB_ADDR_LO, (uint32_t)frame_buffer);
    VGA_WRITE(VGA_REG_FB_ADDR_HI, 0);
	char *s = "Hello, Puppy OS!";
	char *sp = s;
	uint16_t *fp = frame_buffer;
	union vga_char ch;
	// 设置颜色:
	ch.data[1] = 0x0f;
	while ((ch.data[0] = *sp++) != '\0') {
		// 设置字符:
		*fp++ = ch.value;
	}
}
