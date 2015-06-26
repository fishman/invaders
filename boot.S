/* boot.S - bootstrap the kernel */
/* Copyright (C) 1999  Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.
 
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
 
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.  */

#define ASM	1
#include <multiboot.h>
LOADBASE            = 0x00100000   
VOFFSET             = 0xf0000000
	
ELF_HEADER_MAGIC	=   0x464c457f
ELF_HEADER_1		=   0x00010101
ELF_HEADER_2		=   0x00000000
ELF_HEADER_3		=   0x00000000
ELF_HEADER_4		=   0x00030002
ELF_HEADER_VERSION	=   0x00000001
ELF_HEADER_ENTRY	=   LOADBASE + multiboot_entry + VOFFSET
ELF_HEADER_PHOFF	=   0x00000034
ELF_HEADER_SHOFF	=   0x00000000
ELF_HEADER_FLAGS	=   0x00000000
ELF_HEADER_EPHSZ	=   0x00200034
ELF_HEADER_NPH		=   0x00000002
ELF_HEADER_NSH		=   0x00000000

ELF_PHTEXT_TYPE		=   0x00000001
ELF_PHTEXT_OFFSET	=   multiboot_entry
ELF_PHTEXT_VADDR	=   LOADBASE + multiboot_entry + VOFFSET
ELF_PHTEXT_PADDR	=   LOADBASE + multiboot_entry
ELF_PHTEXT_SZ		=   0
ELF_PHTEXT_FLAGS	=   0x00000005
ELF_PHTEXT_ALIGN	=   0x00001000

ELF_PHDATA_TYPE		=   0x00000001
ELF_PHDATA_OFFSET	=   _edata
ELF_PHDATA_VADDR	=   LOADBASE + _edata + VOFFSET
ELF_PHDATA_PADDR	=   LOADBASE + _edata
ELF_PHDATA_SZ		=   0
ELF_PHDATA_FLAGS	=   0x00000006
ELF_PHDATA_ALIGN	=   0x00001000


	.text

	.code32
	.globl	start, _start

	/* This entry is not used actually.  */
start:
_start:
    .long ELF_HEADER_MAGIC
    .long ELF_HEADER_1
    .long ELF_HEADER_2
    .long ELF_HEADER_3
    .long ELF_HEADER_4
    .long ELF_HEADER_VERSION
    .long ELF_HEADER_ENTRY
    .long ELF_HEADER_PHOFF
    .long ELF_HEADER_SHOFF
    .long ELF_HEADER_FLAGS
    .long ELF_HEADER_EPHSZ
    .long ELF_HEADER_NPH
    .long ELF_HEADER_NSH

    .long ELF_PHTEXT_TYPE
    .long ELF_PHTEXT_OFFSET
    .long ELF_PHTEXT_VADDR
    .long ELF_PHTEXT_PADDR
    .long ELF_PHTEXT_SZ
    .long ELF_PHTEXT_SZ
    .long ELF_PHTEXT_FLAGS
    .long ELF_PHTEXT_ALIGN
    .long
    .long ELF_PHDATA_TYPE
    .long ELF_PHDATA_OFFSET
    .long ELF_PHDATA_VADDR
    .long ELF_PHDATA_PADDR
    .long ELF_PHDATA_SZ
    .long ELF_PHDATA_SZ
    .long ELF_PHDATA_FLAGS
    .long ELF_PHDATA_ALIGN
        
	
	/* Align 32 bits boundary.  */
	.align	4
	
	/* Multiboot header.  */
multiboot_header:
	/* magic */
	.long	MULTIBOOT_HEADER_MAGIC
	/* flags */
	.long	MULTIBOOT_HEADER_FLAGS
	/* checksum */
	.long	-(MULTIBOOT_HEADER_MAGIC + MULTIBOOT_HEADER_FLAGS)
	/* header_addr */
	.long	multiboot_header
	/* load_addr */
	.long	_start
	/* load_end_addr */
	.long	_edata
	/* bss_end_addr */
	.long	_end
	/* entry_addr */
	.long	multiboot_entry

multiboot_entry:
	/* Initialize the stack pointer.  */
	movl	$(stack + STACK_SIZE), %esp

	/* Reset EFLAGS.  */
	pushl	$0
	popf

	/* Push the pointer to the Multiboot information structure.  */
	pushl	%ebx
	/* Push the magic value.  */
	pushl	%eax

	/* Now enter the C main function...  */
	call	EXT_C(cmain)

loop:	hlt
	jmp	loop

	/* Our stack area.  */
	.comm	stack, STACK_SIZE
