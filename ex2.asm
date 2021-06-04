%include "linux64.inc"

section .data
color_img times 786486 db 0   ; Allocating space to store RGB image
new_img times 786486 db 0     ; Allocating space to store the new image
imgPath_color db "/home/lrvnc/git-repos/micmic/trabalho4/lena_color.bmp", 0
output_img_new db  "/home/lrvnc/git-repos/micmic/trabalho4/brighter_color.bmp", 0

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

    ; Copy bpm header of color_img to new_img (first 54 bytes)
    mov rax, color_img
    mov rbx, new_img
    mov r9, 0

_loopHeader:
    mov r8, [rax]
    mov [rbx], r8
    inc rax
    inc rbx
    inc r9
    cmp r9, 47
    jne _loopHeader

    ; Increasing brightness: RGB = RGB + 50
    mov rax, color_img+54
    mov rcx, new_img+54

_loopImg:
    mov r10b, [rax]     ; r10 <= intensity of a chanel (R, G or B)
    cmp r10, 205

    jg _setWhitePixel   ; if intensity > 225, then intensity = 255
    add r10b, 50        ; else: intensity = intensity + 30

_backLoopImg:

    mov [rcx], r10b

    inc rax
    inc rcx

    cmp rax, new_img
    jne _loopImg

    ; Create new image
    mov rax, SYS_OPEN
    mov rdi, output_img_new
    mov rsi, O_CREAT+O_WRONLY
    mov rdx, 0644o
    syscall

    ; Writing the new image
    mov rdi, rax
    mov rax, SYS_WRITE
    mov rsi, new_img
    mov rdx, 786486
    syscall

    ; Close new image
    mov rax, SYS_CLOSE
    syscall

_exit:
    mov rax, SYS_EXIT
    mov rdi, 0
    syscall

_setWhitePixel:
    mov r10b, 255
    jmp _backLoopImg