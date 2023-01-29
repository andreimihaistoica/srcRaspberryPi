/*
 * Copyright (C) 2018 bzt (bztsrc@github)
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 */

.section ".text.boot"

.global _start

_start:

2:
//set top of stack just before our code
	ldr r1, = __bss start
	ldr r2, = __bss size
	cmp r2, #0
	beq 4f
3:
	str r0, [r1], #8
	sub r2, r2, #1
	cmp r2, #0
	bne 3b
4:
	// jump to C code, should not return
	bl 	main
	// remove all lines from (and including) .text onward in link.ld and replace
	// it with the following
	.text : { KEEP(*(.text.boot)) *(.text .text.* .gnu.linkonce.t*) }
	.rodata : { *(.rodata .rodata.* .gnu.linkonce.r*) }
	PROVIDE( data = .);
	.data : { *(.data .data.* .gnu.linkonce.d*) }
	.bss (NOLOAD) : {
		. = ALIGN(16);
		__bss start = .;
		*(.bss .bss.*)
		*(COMMON)
		__bss end = .;
	}
	end = .;
	/DISCARD/ : { *(.comment) *(.gnu*) *(.note*) *(.eh frame*) } }
__bss_size = (__bss end - __bss start)>>3;

1:  wfe
    b       1b
