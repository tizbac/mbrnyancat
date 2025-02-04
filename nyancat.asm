bits 16
org 0x7c00
counter equ 0x8000
waitticks equ 0x8002
position equ 0x8004 ; Durate
positionbit equ 0x8006
positionn equ 0x8008
positionnbit equ 0x800A
current equ 0x800C
x equ 0x8010
y equ 0x8014
start:

xor ax,ax 
mov ds,ax
mov es,ax 
mov ss,ax
mov sp,0x7000

mov [counter], ax

mov [position], ax
mov [positionn], ax
mov [positionnbit], ax
mov al, [notesint]
mov [waitticks], al

mov ah , 0x00
mov al , 0x13
int 10h

mov al, 0x36
out 0x43, al    ;tell the PIT which channel we're setting
 
mov ax, 11931
out 0040h, al
shr ax,8
out 0040h, al    
mov [y] , dword 0
loop1:
  mov [x], dword 0
  loop2:
    
    
    mov ax, [y]
    mov bl,33
    div bl
    xor ah,ah
    mov si,ax

    mov ah,0x0c
    mov al,[nyancolors+si]
    mov cx, [x]
    mov dx, [y]
    mov bh,1
    int 10h
    inc dword [x]
    cmp dword [x],320
    jnz loop2
  inc dword [y]
  cmp dword [y],198

  
  jnz loop1
  





cli


mov dx, timer
mov [es:0x0020], dx
mov [es:0x0022], ds
sti


loop:
jmp loop

timer:
  pusha
  
  add [counter], dword 1
  mov ax, [counter]
  mov bl,20
  div bl; Usa l'interrupt del timer solo una volta ogni 0.2 secondi
  test ah,ah
  jnz noprint
  
  call printt
 
  noprint:
  mov al,20h; Informa il controller degli interrupt che l'interrupt è stat gestito e quindi è possibile accettarne uno nuovo
  out 20h,al
  popa
  iret
  
  
advance:


  ret
printt:
  
  mov al , [waitticks]
  test al,al
  jnz printtickstend
  ;mov ah,0x0E
  
  ;mov al,byte [current]
  ;add al,'0'
  ;int 10h
  
  

  mov al, 0xb6
  out 43h, al
  mov si, [current]
  add si,si
  mov ax, [freqtable+si]
  out 42h, al
  shr ax,8
  out 42h, al
  in al, 61h
  or al, 3
  out 61h,al
  
  ;Avanza
  add [positionbit], byte 1
  cmp [positionbit], byte 8
  jnz c1
  mov [positionbit], byte 0
  add [position], dword 1

  c1:
  
  ;Avanza NOTE
  add [positionn], dword 1
  cmp [positionn],dword 70
  jnz c3
  xor ax,ax 
  mov [counter], ax

  mov [position], ax
  mov [positionn], ax
  mov [positionnbit], ax
  mov al, [notesint]
  mov [waitticks], al
  c3:
  mov si,[positionn]
  mov dl,byte [notesint+si]
  mov [current], dl
  
  
  
  

  mov bl , 1
  mov cl , [positionbit]
  shr bl , cl
  and bl , 0x01
  ;add bl,bl
  mov [waitticks], bl
  jmp printend
  printtickstend:
  
  sub [waitticks], byte 1
  printend:
  ret


nyancolors db 12,6,14,10,9,1

  
freqtable dw 5, 1918,1810,1612,1207,958,904,1280,1075,3224,2875,4058,3836,12829,4307,4830,6449,5736,3615,7231,7648,5120
; Bit a 1 = lunga , bit a 0 = corta
notesint db 10, 11, 12, 13, 14, 11, 14, 15, 15, 14, 11, 11, 14, 15, 14, 12, 9, 10, 12, 9, 14, 12, 15, 14, 15, 12, 9, 10, 12, 9, 14, 12, 15, 11, 12, 11, 14, 15, 14, 11, 15, 14, 12, 9, 14, 11, 14, 15, 14, 15, 14, 9, 10, 11, 12, 13, 14, 11, 14, 15, 15, 14, 11, 11, 14, 15, 14, 12, 9, 10
;notesint db  249, 255, 255, 253, 243, 195, 255, 207, 255, 251, 7, 63, 252, 255, 252, 191, 127, 216, 255, 252, 191, 253, 239, 127, 236, 127, 254, 223, 254, 247, 63, 252, 240, 255, 243, 255, 254, 193, 15, 255, 63, 255, 239, 31, 246, 63, 255, 111, 255, 251, 31, 251, 159, 255, 183, 255, 253,15
; 5 bit per nota che fanno riferimento ad una tabella
; 'SILENZIO', 'NOTE_DS5', 'NOTE_E5', 'NOTE_FS5','NOTE_B5', 'NOTE_DS6', 'NOTE_E6', 'NOTE_AS5', 'NOTE_CS6', 'NOTE_FS4', 'NOTE_GS4', 'NOTE_D4', 'NOTE_DS4', 'NOTE_FS2', 'NOTE_CS4', 'NOTE_B3', 'NOTE_FS3', 'NOTE_GS3', 'NOTE_E4', 'NOTE_E3', 'NOTE_DS3', 'NOTE_AS3'
