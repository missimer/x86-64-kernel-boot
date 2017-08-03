#include "arch/x86_64/gdt.h"
#include "arch/x86_64/mmu.h"
#include "kernel.h"
#include "sizes.h"
#include "multiboot2.h"
#include "arch/x86_64/msr.h"

.SET HEADER_LENGTH, header_end - header_start
.SET CHECKSUM, -(MULTIBOOT2_HEADER_MAGIC + MULTIBOOT_ARCHITECTURE_I386 + HEADER_LENGTH)
.section .multiboot
header_start:
    .long MULTIBOOT2_HEADER_MAGIC
    .long MULTIBOOT_ARCHITECTURE_I386
    .long HEADER_LENGTH
    .long CHECKSUM

    // multiboot tags go here

    .short MULTIBOOT_HEADER_TAG_END
    .short 0    // flags, none set
    .long 8     // size, including itself (short + short + long)
header_end:

.code32

.section .bss
.comm pml4, PML4_SIZE, PML4_ALIGNMENT
.comm low_pdpt, PDPT_SIZE, PDPT_ALIGNMENT
.comm high_pdpt, PDPT_SIZE, PDPT_ALIGNMENT
.comm low_page_directory_table, PAGE_DIRECTORY_SIZE, PAGE_DIRECTORY_ALIGNMENT
.comm high_page_directory_table, PAGE_DIRECTORY_SIZE, PAGE_DIRECTORY_ALIGNMENT
.comm tmp_stack, KERNEL_BOOT_STACK_SIZE, KERNEL_BOOT_STACK_ALIGNMENT

.data
.align GDT_TABLE_ALIGNMENT
gdt_table:
        .8byte GDT_FIRST_ENTRY
        .8byte GDT_KERNEL_ENTRY

gdt_table_end:
        .skip (GDT_TABLE_SIZE - (gdt_table_end - gdt_table))

gdt_ptr:
         .short GDT_TABLE_SIZE - 1
         .long gdt_table


.section .text
.global _start
.type _start, @function
_start:
        movl $tmp_stack + KERNEL_BOOT_STACK_SIZE, %esp

        movl $low_pdpt, %eax
        or $(MMU_PRESENT | MMU_WRITABLE), %eax
        movl %eax, pml4 + (PML4_ADDR_TO_ENTRY_INDEX(KERNEL_PHYSICAL_START) * PML4_ENTRY_SIZE)

        movl $high_pdpt, %eax
        or $(MMU_PRESENT | MMU_WRITABLE), %eax
        movl %eax, pml4 + (PML4_ADDR_TO_ENTRY_INDEX(KERNEL_VIRTUAL_START) * PML4_ENTRY_SIZE)

        movl $low_page_directory_table, %eax
        or $(MMU_PRESENT | MMU_WRITABLE), %eax
        movl %eax, low_pdpt + (PDPT_ADDR_TO_ENTRY_INDEX(KERNEL_PHYSICAL_START) * PDPT_ENTRY_SIZE)

        movl $high_page_directory_table, %eax
        or $(MMU_PRESENT | MMU_WRITABLE), %eax
        movl %eax, high_pdpt + (PDPT_ADDR_TO_ENTRY_INDEX(KERNEL_VIRTUAL_START) * PDPT_ENTRY_SIZE)

        mov $0, %ecx

        movl $_kernel_physical_end, %esi
        shrl $TWO_MEGABYTES_SHIFT, %esi
        addl $1, %esi

page_directory_table_loop:
        movl $TWO_MEGABYTES, %eax
        mul %ecx
        or $(MMU_PRESENT | MMU_WRITABLE | MMU_PDE_TWO_MB), %eax
        movl %eax, low_page_directory_table(, %ecx, PAGE_DIRECTORY_ENTRY_SIZE)
        movl %eax, high_page_directory_table(, %ecx, PAGE_DIRECTORY_ENTRY_SIZE)

        inc %ecx
        cmp %esi, %ecx
        jne page_directory_table_loop  // if not equal redo loop

        movl $pml4, %eax
        movl %eax, %cr3

        movl $KERNEL_CR4, %eax
        movl %eax, %cr4

        movl $MSR_EFER, %ecx
        rdmsr
        or $MSR_EFER_LME, %eax
        wrmsr

        movl $KERNEL_CR0, %eax
        movl %eax, %cr0

        lgdt gdt_ptr

        ljmp $(KERNEL_GDT_ENTRY * GDT_ENTRY_SIZE), $_start64

        cli
        hlt

.code64

.global _start64
.type _start64, @function
_start64:
        // Setup segment selectors
        movw $0, %ax
        movw %ax, %ds
        movw %ax, %es
        movw %ax, %fs
        movw %ax, %gs
        movw %ax, %ss

        call Kernel_Main

        // Should never reach here
        cli
        hlt
1:
        jmp 1b
