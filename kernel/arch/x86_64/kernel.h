#ifndef _ARCH_X86_64_KERNEL_H_
#define _ARCH_X86_64_KERNEL_H_

#include <arch/x86_64/control_register.h>

// START macros must have the same value in the kernel linker script
#define KERNEL_PHYSICAL_START 0x0000000000400000
#define KERNEL_VIRTUAL_START  0xFFFFFFFF80400000

#define KERNEL_GDT_ENTRY 1

#define KERNEL_CR0                                                             \
  (                                                                            \
   CONTROL_REGISTER0_PAGE |                                                    \
   CONTROL_REGISTER0_PROTECTED_MODE_ENABLED |                                  \
   CONTROL_REGISTER0_EXTENSION_TYPE                                            \
  )
#define KERNEL_CR4 (CONTROL_REGISTER4_PHYSICAL_ADDRESS_EXTENSION)

#endif // _ARCH_X86_64_KERNEL_H_
