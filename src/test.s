[BITS 16]
[ORG 0x7C00]
start:
   cli
   xor ax, ax
   mov ds, ax
   mov es, ax
   mov ss, ax
   mov sp, 0x7C00
   sti

   mov ax, 0x0C04
   xor cx, cx
   int 0x10

   mov cx, 5
   call fibonacci

   mov dx, ax
   mov cl, 2
   call print_hex
   jmp exit

fibonacci:
   sub sp, 2
   mov bp, sp
   mov [bp], cx
   
   cmp cx, 2
   jb .else

   mov cx, [bp]
   sub cx, 1
   call fibonacci
   
   mov cx, [bp]
   mov [bp], ax
   sub cx, 2
   call fibonacci

   add [bp], ax

.else:
   call dump_stack
   
   mov ax, [bp]
   add sp, 2
   mov bp, sp
   ret

print_hex:
   shl cl, 3
   mov bp, sp

.loop:
   sub cl, 4

   mov bx, dx
   shr bx, cl
   and bx, 0xF
   mov al, [hexchar + bx]
   mov ah, 0x0E
   int 0x10
   
   cmp cl, 0
   jne .loop
   ret

dump_stack:
   mov si, 0x7C00

.loop:
   mov ah, 0
   int 0x16
   
   cmp si, sp
   jbe .exit

   sub si, 4

   mov dx, [si]
   mov cl, 2
   call print_hex

   jmp .loop
   
.exit:
   mov ah, 0x0E
   mov al, 0x0A
   int 0x10
   mov al, 0x0D
   int 0x10
   ret
exit:
   mov ax, 0x0E58
   int 0x10

   ;mov ah, 0
   ;int 0x16

   cli
   hlt

hexchar db '0123456789ABCDEF'

times 510 - ($ - $$) db 0
dw 0xAA55