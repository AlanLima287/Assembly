[BITS 16]
[ORG 0x7C00]

DISK_LOAD_SEG equ 0x7E00
DISK_SECT_COUNT equ 1

global_start:
   cli
   xor ax, ax
   mov ds, ax
   mov es, ax
   mov ss, ax
   mov sp, 0x7C00
   sti

   mov [DISK], dl

   mov cx, 0x0002
   mov bx, DISK_LOAD_SEG
   mov ah, 0x02
   mov al, DISK_SECT_COUNT
   int 0x13

   jc catch
   jmp 0x7E00

catch:
   mov si, .error_msg
   call print

   cli
   hlt

.error_msg db "Something went wrong :(", 0

print:
   lodsb
   cmp al, 0
   je .exit

   mov ah, 0x0E
   int 0x10

   jmp print

.exit:
   ret

print_bin:
   mov ch, cl
   sub cl, 0x10
   neg cl
   shl dx, cl

.loop:
   mov al, 0x30
   
   test dx, 0x8000
   jz .l0
   mov al, 0x31

.l0:
   mov ah, 0x0E
   int 0x10
   
   shl dx, 1
   dec ch
   jne .loop
   ret

print_hex:
   shl cl, 3

.loop:
   sub cl, 4
   mov bx, dx
   shr bx, cl
   and bx, 0xF
   mov al, [.hexchar + bx]
   mov ah, 0x0E
   int 0x10
   
   cmp cl, 0
   jne .loop
   ret

.hexchar db '0123456789ABCDEF'

print_dec:
   mov eax, 0
   mov cl, 0

.loop:
   cmp cl, 0x10
   jnb .exit

   mov ebx, eax
   and ebx, 0xF
   cmp ebx, 0x5
   jb .c0
   add eax, 0x3
.c0:
   mov ebx, eax
   and ebx, 0xF0
   cmp ebx, 0x50
   jb .c1
   add eax, 0x30
.c1:
   mov ebx, eax
   and ebx, 0xF00
   cmp ebx, 0x500
   jb .c2
   add eax, 0x300
.c2:
   mov ebx, eax
   and ebx, 0xF000
   cmp ebx, 0x5000
   jb .c3
   add eax, 0x3000
.c3:
   mov ebx, eax
   and ebx, 0xF0000
   cmp ebx, 0x50000
   jb .c4
   add eax, 0x30000
.c4:

   shl eax, 1
   test dx, 0x8000
   jz .l0

   or eax, 1
.l0:
   shl dx, 1
   inc cl
   jmp .loop

.exit:
   mov ch, 5
   mov cl, al
   mov ebx, eax
   shr ebx, 4

   jmp .l1
.padzeros:
   shl bx, 4
.l1:
   dec ch
   jz .finish

   test bh, 0xF0
   jz .padzeros

   inc ch

.iloop:
   dec ch
   jz .finish

   mov al, bh
   shr al, 4
   add al, 0x30
   mov ah, 0x0E
   int 0x10
   
   shl bx, 4
   jmp .iloop

.finish:
   mov al, cl
   and al, 0xF
   or al, 0x30
   mov ah, 0x0E
   int 0x10

   ret

endl: db 0xA, 0xD, 0
DISK: db 0

times 510 - ($ - $$) db 0
dw 0xAA55

start:
   mov dx, 28
   call print_dec
   
   cli
   hlt

.msg db "My favorite number is ", 0
.success_msg db "Everything might've gone fine :>", 0

times (DISK_SECT_COUNT + 1) * 512 - ($ - $$) db 0