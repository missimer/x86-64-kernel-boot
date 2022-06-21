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

static void ClearVGA()
{
  unsigned char *video = ((unsigned char *)VIDEO_START);
  __builtin_memset(video,0,80*25*2);
}

void
Kernel_Main(void)
{
  ClearVGA();
  PrintString("Hello World!");

  while(1);
}
