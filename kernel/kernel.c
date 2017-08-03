#define VIDEO_START 0xb8000
#define VGA_LIGHT_GRAY 7

static void PrintString(char *str)
{
  unsigned char *video = ((unsigned char *)VIDEO_START);
  while(*str != '\0') {
    *(video++) = *str++;
    *(video++) = VGA_LIGHT_GRAY;
  }
}

void
Kernel_Main(void)
{
  PrintString("Hello World!");

  while(1);
}
