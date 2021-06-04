%include "linux64.inc"

section .data
color_img times 786486 db 0   ; Allocating space to store RGB image
gray_img times 786486 db 0    ; Allocating space to store GRAY image
bw_img times 786486 db 0      ; Allocating space to store BW image
imgPath_color db "/home/lrvnc/git-repos/micmic/trabalho4/lena_color.bmp", 0
output_img_gray db  "/home/lrvnc/git-repos/micmic/trabalho4/grayscale.bmp", 0
output_img_bw db  "/home/lrvnc/git-repos/micmic/trabalho4/bw.bmp", 0

section .text
    global _start

_start:
    ; Open RGB image
    mov rax, SYS_OPEN
    mov rdi, imgPath_color
    mov rsi, O_RDONLY
    mov rdx, 0644o
    syscall

    ; Read RGB image and store on color_img
    mov rdi, rax
    mov rax, SYS_READ
    mov rsi, color_img
    mov rdx, 786486
    syscall

    ; Close RGB image
    mov rax, SYS_CLOSE
    syscall

    ; Copy bpm header of color_img to bw_img and gray_img (first 54 bytes)
    mov rax, color_img
    mov rbx, bw_img
    mov rcx, gray_img
    mov r9, 0

_loopHeader:
    mov r8, [rax]
    mov [rbx], r8
    mov [rcx], r8
    inc rax
    inc rbx
    inc rcx
    inc r9
    cmp r9, 47
    jne _loopHeader

    ; Convert RGB to gray scale
    mov rax, color_img+54
    mov rcx, gray_img+54

_loopGray:
    mov r10b, [rax]     ; r10 <= Blue
    shr r10b, 2         ; r10 <= Blue/4

    mov r11b, [rax+1]   ; r11 <= Green
    shr r11b, 1         ; r11 <= Green/2

    mov r12b, [rax+2]   ; r12 <= Red
    shr r12b, 2         ; r12 <= Red/4

    add r10b, r11b
    add r10b, r12b

    mov [rcx], r10b
    mov [rcx+1], r10b
    mov [rcx+2], r10b

    add rax, 3
    add rcx, 3

    cmp rax, gray_img
    jne _loopGray

; Convert gray to BW
    mov rax, gray_img+54
    mov rbx, bw_img+54

_loopBW:
    mov r10b, [rax] ; r10b <= intensidade de cinza
    cmp r10, 95     ; threshold
    jge _pixelWhite
    jl  _pixelBlack
_backLoopBW:
    add rax, 3
    add rbx, 3

    cmp rax, bw_img
    jne _loopBW

    ; Create new GRAY image
    mov rax, SYS_OPEN
    mov rdi, output_img_gray
    mov rsi, O_CREAT+O_WRONLY
    mov rdx, 0644o
    syscall

    ; Writing the GRAY image
    mov rdi, rax
    mov rax, SYS_WRITE
    mov rsi, gray_img
    mov rdx, 786486
    syscall

    ; Close GRAY image
    mov rax, SYS_CLOSE
    syscall

    ; Create new BW image
    mov rax, SYS_OPEN
    mov rdi, output_img_bw
    mov rsi, O_CREAT+O_WRONLY
    mov rdx, 0644o
    syscall

    ; Writing the BW image
    mov rdi, rax
    mov rax, SYS_WRITE
    mov rsi, bw_img
    mov rdx, 786486
    syscall

    ; Close BW image
    mov rax, SYS_CLOSE
    syscall

_exit:
    mov rax, SYS_EXIT
    mov rdi, 0
    syscall

_pixelWhite:
    mov r10b, 255
    mov [rbx], r10b
    mov [rbx+1], r10b
    mov [rbx+2], r10b
    jmp _backLoopBW

_pixelBlack:
    mov r10b, 0
    mov [rbx], r10b
    mov [rbx+1], r10b
    mov [rbx+2], r10b
    jmp _backLoopBW