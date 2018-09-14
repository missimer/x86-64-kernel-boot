ENTRY(_start)

SECTIONS
{
  . = 4M;
  _kernel_physical_start = .;

  .boottext :
    {
      boot.o (.multiboot)
      boot.o (.text)
    }
  .bootrodata :
    {
      boot.o (.rodata)
    }
  .bootdata :
    {
      boot.o (.data)
    }
  .bootbss :
    {
      boot.o (.bss)
      boot.o (COMMON)
    }

  . = ALIGN(0x1000);
  _boot_end = .;

  . += 0xFFFFFFFF80000000;
  _kernel_virtual_start = .;
  .text : AT(_boot_end)
  {
    *(.multiboot)
    *(.text)
  }

  . = ALIGN(0x1000);

  .rodata : AT ( (LOADADDR (.text) + SIZEOF (.text) + 0xFFF) & 0xFFFFFFFFFFFFF000 )
  {
    *(.rodata)
  }

  . = ALIGN(0x1000);

  .data : AT ( (LOADADDR (.rodata) + SIZEOF (.rodata) + 0xFFF) & 0xFFFFFFFFFFFFF000 )
  {
    *(.data)
  }

  . = ALIGN(0x1000);

  .bss : AT ( (LOADADDR (.data) + SIZEOF (.data) + 0xFFF) & 0xFFFFFFFFFFFFF000 )
  {
    *(COMMON)
    *(.bss)
  }

  _kernel_virtual_end = .;

  _kernel_physical_end = (LOADADDR (.bss) + SIZEOF (.bss) + 0xFFF) & 0xFFFFFFFFFFFFF000;
}
