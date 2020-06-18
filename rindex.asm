.model small

.stack 256

.data

msg_1 db 'Please type the text: $'
msg_2 db 'Now type the word: $'
text_str db 100 dup(' ')
word_str db 100 dup(' ')


.code


;arguments => di - text , bp - word

rindex PROC
    
    xor dx,dx
    mov dx, di
    xor ax,ax
    mov al, byte ptr di[1]
    CBW    
    mov cx,ax


 ;setting si - index  end of text_str string
    mov si, cx
    add si, di
    inc si


    xor ax,ax
    xor di,di
    mov di, bp
    mov al, byte ptr di[1]
    CBW

 ;setting bx - index  end of word_str string
    mov bx, ax
    add bx, bp
    inc bx

    mov di,dx
    mov dx, 0FFh


    repeater1:
    
        push cx
        push si
        push bx
        cmp cx, ax
        JB finish
        mov cx, ax

            repeater2:
                    

                    JE continue
                    mov dl, byte ptr[bx]
                    mov dh, byte ptr[si]

                    cmp dl,dh
                    JNE continue


                    dec bx
                    dec si
            loop repeater2

     

            xor dx,dx
            mov dx,si
            sub dx, di
            dec dx
            JMP finish

            continue:

        pop bx
        pop si
        pop cx
        dec cx
        dec si

    loop repeater1
    JMP end_of_proc
    finish:
        pop bx
        pop si 
        pop cx

    end_of_proc:
 ret
rindex ENDP


START:

mov ax, @data
mov ds,ax



;Showing message to user, to type the text

lea dx, msg_1
mov ah,9
int 21h


mov dx, offset text_str
mov ah, 0Ah
int 21h

;New Line
MOV dl, 10
MOV ah, 02h
INT 21h


;Showing message to user, to type the word

lea dx, msg_2
mov ah,9
int 21h


mov dx, offset word_str
mov ah, 0Ah
int 21h

;New Line
MOV dl, 10
MOV ah, 02h
INT 21h


 mov di,offset text_str
 mov bp,offset word_str

CALL rindex





mov ax,4c00h
int 21h




END START