.MODEL SMALL

.STACK 256

.DATA

	msg_1 DB 'Please type the text: $'
	msg_2 DB 'Now type the word: $'
	text_str DB 200 dup(' ')
	word_str DB 100 dup(' ')


.CODE


;arguments ax->text_str(eff adress) bx->word_str(eff adress)
;RINDEX PROCEDURE IMPLEMENTATION

rindex PROC

push ax bx cx di bp si

;||||||||||||||||||||||DATA SETTING PROCESS\\\\\\\\\\\\\\\\\\\\\\\\

;di <- ax ||| bp <- bx
	XOR bp,bp
	XOR di,di

	MOV di,ax
	MOV bp,bx

;Saving offset of text_str in dx 
	XOR dx,dx 
	MOV dx, di
;Second element in string is string length, setting cx -> text_str.length
	XOR ax,ax
	MOV al,byte ptr di[1]
	CBW
	MOV cx,ax

;Saving end index of text_str in si   

	MOV si,cx
	ADD si,di
	INC si

;di <- word_str offset, for working with ponters 
	PUSH di
	XOR ax,ax 
	XOR di,di
	MOV di,bp
	MOV al,byte ptr di[1]
	CBW

;Saving end index of word_str in bx 
	XOR bx,bx
	MOV bx,ax
	ADD bx,bp
	INC bx
	

;Saving initial result in dx /// dx=-1
	MOV di,dx
	MOV dx,0FFh
;BP-> text_str  offset,so bp[2] -> start bp[1] -> length
	POP BP



;||||||||||||||||||||||FINDING INDEX\\\\\\\\\\\\\\\\\\\\\\\\

;Reverse iterating on text_str   

	text_str_iter:
		
;Savving cx,si,bx in stack for reverse iterating on word_str
		PUSH cx
		PUSH si
		PUSH bx

;if word.length>text.length => Process ends with -1 result
		CMP cx,ax
		JB finish
;else start checking
;setting cx <- word_str.length for iteration
		mov cx,ax

		CMP byte ptr[si+1],0Dh
		JMP jump

		CMP byte ptr[si+1] ,' '
		JNE continue

		jump:

;Reverse iterating on word_str		
		word_str_iter:


; comparing characters
			push dx
			XOR dx,dx
			MOV dl, byte ptr[bx]
            MOV dh, byte ptr[si]


			CMP dl,dh
			pop dx
			JNE continue
;checking space seporator, or string start
			CMP cx,1
			JNE etc
			PUSH dx
				mov dx, bp
				add dx,2
				CMP si,dx
				pop dx
				JE etc 
				CMP byte ptr [si-1],' '
				JNE continue
			etc:
			DEC bx
			DEC si
		LOOP word_str_iter
;True case, saving index of first letter of finded word
		XOR dx,dx
		MOV dx,si
		SUB dx,di
		DEC dx
		JMP finish

		continue:

			POP bx
	        POP si
		    POP cx
			DEC si

	LOOP text_str_iter

	JMP end_of_proc


	finish:
        pop bx
        pop si 
        pop cx

    end_of_proc:


POP  si bp di cx bx ax
;Near Call returning
	RET
rindex ENDP



START: 

	MOV ax, @data
	MOV ds, ax


	
;Showing message to user, to type the text

	lea dx, msg_1
	mov ah,9
	int 21h

;Text input

	MOV dx, offset text_str
	MOV ah, 0Ah
	INT 21h




;New Line
	MOV dl, 10
	MOV ah, 02h
	INT 21h

;Showing message to user, to type the word

	LEA dx, msg_2
	MOV ah,9
	INT 21h

;Word input
	MOV dx, offset word_str
	MOV ah, 0Ah
	INT 21h

;New Line
	MOV dl, 10
	MOV ah, 02h
	INT 21h


;Setting arguments for rindex procedure

	MOV ax, offset text_str
	MOV bx, offset word_str

;Calling rindex procedure
	
	CALL rindex

;Giving control to the OS
MOV ax,4c00h
INT 21h


END START
