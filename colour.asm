;  EGA low res 16 colour graphics mode with 64 colour palette.
.model 	tiny
.code

org 32768

_black equ 000000b
_r equ 000100b
_g equ 000010b
_b equ 000001b
_dr equ 100000b
_dg equ 010000b
_db equ 001000b
_white equ 111111b
horizon_colours db  _black,
            _dr,
            _r,
            _dr + _r,
            _dr + _r + _dg,
            _dr + _r + _g,
            _dr + _r + _g + _dg,
            _white,
            _db + _b + _dg + _g + _r,
            _db + _b + _dg + _g,
            _db + _b + _dg + _g + _dr,
            _db + _b + _g + _dr,
            _db + _b + _dg + _dr,
            _db + _b + _dg,
            _db + _b,
            _b,
            _db
            
            
icon:            
;logo dd 00BBBBBB0h,
;       0BBBBBBBBh,
;        0BBBBBBBBh,
;        0BBBBBBBBh,
;        0B979B77Bh,
;        0B7B7A97Bh,
;        0B7B78B7Bh,
;        0B7B78B7Bh,
;        0B7B78B7Bh,
;        0B7B78B7Bh,
;        0B7B7A97Bh,
;        0B979B77Bh,
;        0BBBBBBBBh,        
;        0BBBBBBBBh,
;        0BBBBBBBBh,
;        00BBBBBB0h

INCLUDE image.inc
INCLUDE ega.inc

org 100h

start:
  mov ax, 0003h
  int 10h
  
  mov cx, 0b800h
  push cx
  pop es
  mov di, 0
  mov cx, 80*175     ; Entire screen at 2 scalines per character
  
writechar:
  mov al, 0DDh       ; ASCII 2 half block to give us to "pixels"
  stosb
  mov al, 0
  stosb
  dec cx
  jnz writechar

setrowheight:
  mov dx, 03D4h
  mov al, 09h
  out dx, al
  
  mov dx, 03D5h
  mov al, 1
  out dx, al
  
disableblink:
  mov dx, 03DAh
  in  al, dx
  mov dx, 03C0h
  mov al, 10h
  out dx,al
  mov al, 00000000b
  out dx, al

@SetPalette 0, 16, OFFSET palette


drawgradient:

  mov cx, 0b800h
  push cx
  pop es
  mov di, 1
  mov ch, 0

rowloop:
  mov cl, 160
  mov dl, ch
  and dl, 0Fh
  
  mov al, dl
  shl dl, 1
  shl dl, 1
  shl dl, 1
  shl dl, 1
  or al, dl

rowcharloop:
  stosb
  inc di      ; skip the character
  dec cl
  jnz rowcharloop

  inc ch
  cmp ch, 87
  jb rowloop

  @DrawSprite icon

mainloop:
  mov dx, 03DAh
  in  al, dx                ; reset flip-flop

  @WaitForVerticalSync
    @SetPalette 0, 1, OFFSET horizon_colours
  @WaitForNoVerticalSync
  
  @WaitForDisplayDisable
    @SetPalette 0, 1, OFFSET horizon_colours+1
  @WaitForDisplayEnable
  @WaitForDisplayDisable
    @SetPalette 0, 1, OFFSET horizon_colours+2
  @WaitForDisplayEnable
  @WaitForDisplayDisable
    @SetPalette 0, 1, OFFSET horizon_colours+3
  @WaitForDisplayEnable
  @WaitForDisplayDisable
    @SetPalette 0, 1, OFFSET horizon_colours+4
  @WaitForDisplayEnable
  @WaitForDisplayDisable
    @SetPalette 0, 1, OFFSET horizon_colours+5
  @WaitForDisplayEnable
  @WaitForDisplayDisable
    @SetPalette 0, 1, OFFSET horizon_colours+6
  @WaitForDisplayEnable
  @WaitForDisplayDisable
    @SetPalette 0, 1, OFFSET horizon_colours+7
  @WaitForDisplayEnable
  
  
  @JumpIfKeyPress exit
  jmp mainloop
  
exit:
  @ResetDisplay 
  mov ah, 0
  int 21h
  end start
