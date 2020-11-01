#To be inserted at 80266978
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

.if PAL==1
loc_0x0:
  mflr r14
  bl loc_0x34
  mflr r4
  mtlr r14
  lis r14, 0x35
  ori r14, r14, 0x6A60
  sub r3, r3, r14
  li r5, 0x238
  lis r14, 0x8000
  ori r14, r14, 0x31F4
  mtctr r14
  bctrl
  b loc_0x274

loc_0x34:
  blrl
  .long 0x00000000
  .long 0x00006fff
  .long 0x00007ff1
  .long 0x00007ff0
  .long 0x00007ff0
  .long 0x00007ff0
  .long 0x00007fff
  .long 0x00007ff1
  .long 0x00000000
  .long 0xffc40002
  .long 0x17ff3006
  .long 0x00ef800b
  .long 0x00ef801f
  .long 0x04ff404f
  .long 0xfff7009f
  .long 0x110000ef
  .long 0x00000000
  .long 0xfff8000d
  .long 0xfefd000f
  .long 0xfbff300f
  .long 0xF6DF700F
  .long 0xF3BFC00F
  .long 0xE07FF10F
  .long 0xB14FF60F
  .long 0x00000000
  .long 0xF6000000
  .long 0xF7000000
  .long 0xF7000000
  .long 0xF7000000
  .long 0xF7000000
  .long 0xF7000000
  .long 0xF7000000
  .long 0x04ff9888
  .long 0x00cfb888
  .long 0x009fc888
  .long 0x006fd888
  .long 0x004fe888
  .long 0x002ff888
  .long 0x000ff888
  .long 0x002ff888
  .long 0x88888888
  .long 0x88888888
  .long 0x88888888
  .long 0x88888888
  .long 0x88888888
  .long 0x88888888
  .long 0x88888888
  .long 0x88888888
  .long 0x88888888
  .long 0x88888888
  .long 0x8888888E
  .long 0x888888DF
  .long 0x88888CFF
  .long 0x8888AFF7
  .long 0x8889FFA0
  .long 0x888FFC00
  .long 0x8DFFB100
  .long 0xeff60000
  .long 0xff400000
  .long 0xF3000000
  .long 0x40000000
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0x88888888
  .long 0x88888888
  .long 0x88888888
  .long 0x88888888
  .long 0x88888888
  .long 0x88888888
  .long 0x88888888
  .long 0x88888888
  .long 0x8888EF40
  .long 0x8888DF60
  .long 0x8888CF90
  .long 0x8888BFC0
  .long 0x88889FF4
  .long 0x88888DF9
  .long 0x88888BFE
  .long 0x888888EF
  .long 0x00007ff0
  .long 0x00007ff0
  .long 0x00006fd0
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0x30000000
  .long 0x90000000
  .long 0x000003ff
  .long 0x000008ff
  .long 0x00000bfb
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0xeffffb0f
  .long 0x200AFF1F
  .long 0x0004ff4d
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0xF7000000
  .long 0xF7111100
  .long 0xfffffb00
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0x00000000
  .long 0x004fe888
  .long 0x006fd888
  .long 0x009fc888
  .long 0x00cfb888
  .long 0x04ff9888
  .long 0x09fd8888
  .long 0x3EFB8888

.endif

loc_0x274:
  addi r3, r31, 0x718
