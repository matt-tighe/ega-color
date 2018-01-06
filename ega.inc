@WaitForDisplayEnable macro
LOCAL waitForDisplayEnable
  waitForDisplayEnable:
    mov dx, 03DAh
    in al,dx                       ; 1 1 2
    test al,1                      ; 2 0 2
    jnz waitForDisplayEnable     ; 2 0 2
endm

@WaitForDisplayDisable macro
LOCAL waitForDisplayDisable
  waitForDisplayDisable:
    mov dx, 03DAh
    in al,dx                       ; 1 1 2
    test al,1                      ; 2 0 2
    jz waitForDisplayDisable     ; 2 0 2
endm

@WaitForVerticalSync macro
LOCAL waitForVerticalSync
  waitForVerticalSync:
    mov dx, 03DAh
    in al,dx
    test al,8
    jz waitForVerticalSync
endm

@waitForNoVerticalSync macro
LOCAL waitForNoVerticalSync
  waitForNoVerticalSync:
    mov dx, 03DAh
    in al,dx
    test al,8
    jnz waitForNoVerticalSync
endm

@DrawSprite macro buffer
LOCAL logorowloop, logocharloop
  mov cx, cs
  push cx
  pop ds        ; Make sure DS points to code
  mov si, OFFSET buffer
  mov di, 1
  mov dx, logo_height

logorowloop:
  mov cx, logo_width
logocharloop:
  movsb
  inc di
  dec cx
  jnz logocharloop
  
  add di, 160-(logo_width*2)     ; 80 columns * 2 bytes - sprite width
  dec dx
  jnz logorowloop
endm

@SetPalette macro index, count, palette
LOCAL entry
  mov dx, 03DAh
  in  al, dx                ; reset flip-flop
  mov dx, 03C0h             ; port for palette writes
  mov cl, index             ; starting colour index 
  mov di, palette    ;buffer

entry:
  mov al, cl
  out dx,al                 ; set index

  mov al, [di]
  out dx, al                ; write value

  inc di
  inc cl
  cmp cl, count             ; loop until count colours
  jbe entry                 

  mov dx, 03DAh
  in  al, dx                ; clear flip-flop
  mov dx, 03C0h
  mov al, 32
  out dx,al                 ; Turn off writing of pallete (so it will display)

endm

@WaitForKeyPress macro
  mov ah, 08
  int 21h
endm

@JumpIfKeyPress macro label
  mov ah, 0Bh
  int 21h
  cmp al, 0
  jnz label
endm


@ResetDisplay macro  
  mov ax, 0002h
  int 10h
endm