TITLE Project 6     (Proj6_burtschj.asm)

; Author: John Burtsche
; Last Modified:	3/19/23
; OSU email address: burtschj@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number:   6              Due Date:3/19/23
; Description: (I got stuck on WriteVal) This file requires the user to enter 10 integers and then displays the list of integers, there sum, and there average. All must be displayed using display string and readdec,readint, writeint, and writedec are not allowed. 

INCLUDE Irvine32.inc


;constants

ARRAYSIZE = 10
register = 32



;getstring macro loads prompt into edx and writes the string then reads the string using the using usernumber and loading the register(max string 32) into ecx

mGetString MACRO prompt, input									;get string macro
	push	edx
	push	ecx
This is my portfolio project for Co

	mov		edx,prompt
	call	WriteString
	mov		edx, input
	mov		ecx, register
	call	ReadString

	pop		ecx
	pop		edx

ENDM

;display string macro loads the string into edx and uses writestring to write it
mDisplayString MACRO string										;displaystring macro
	push	edx
	mov		edx, string
	call	WriteString

	pop		edx

ENDM




.data


blank				BYTE	" ",0																;blank space for format purposes
space				BYTE	" ",0

ProgramIntro		BYTE	"        Project 6: Low-Level I/O procedures by John Burtsche        ",0			;intro stuff
ProgramExplanation	BYTE	"Please Provide 10 signed decimal integers.",0	
ProgramExplanation2	BYTE	"Each number needs to be small enough to fit inside a 32 bit register.",0				
ProgramExplanation3 BYTE	"Once you are finished I will display the list of integers, there sum, and their average.", 0

numberprompt		BYTE	"Please enter a signed number: ", 0													;readval prompts
errorprompt			BYTE	"The number you entered is not a signed number. Please Try again: ",0

listofnumbers		BYTE	"The following numbers are:  ",0
sumexplanation		BYTE	"The sum of the numbers are: ",0
averageexplanation	BYTE	"The average of the numbers is: ",0

myArray				SDWORD	ARRAYSIZE DUP(?)													;Hold place for SDWORD
wordArray			BYTE	register DUP(?)														;outnumber from SDWORD to BYTE
usernumber			BYTE	register DUP(?)														;usernumber input


goodbye				BYTE	"That's all folks. ",0												;goodbye





.code
main PROC



;introduction
	PUSH		OFFSET	ProgramIntro								;pushes intros into Introduction procedure
	PUSH		OFFSET	ProgramExplanation
	PUSH		OFFSET	ProgramExplanation2
	PUSH		OFFSET	ProgramExplanation3
	call		Introduction



;ReadVal loop

;ReadVal gets the users numbers and then uses them to fill an array with SDWORDS
	mov			ecx, ARRAYSIZE										;sets ecx to 10
	mov			edi, OFFSET myArray									;loads SDWORD to EDI
_readval:
	PUSH		OFFSET	numberprompt								;pushes prompts
	PUSH		OFFSET	errorprompt
	PUSH		OFFSET	usernumber									;pushes correct EDI and ESI(user input)
	PUSH		edi													
	call		ReadVal

	add			edi,4												;next location in array
	loop		_readval





;Prints the listofnumbers explanation
	call		Crlf
	call		Crlf
mDisplayString	OFFSET listofnumbers
	call		Crlf




;WriteVal loop

;gets numbers using the filled array and turns them into strings with writeval. Then displays the string
	mov			ecx, ARRAYSIZE									;puts ecx, esi, and edi in the correct location
	mov			esi, OFFSET myArray									
	mov			edi, OFFSET	wordArray
_writeval:
	PUSH		esi												;puts arrays inside loop
	PUSH		edi
	call		WriteVal
mDisplayString	 OFFSET wordArray								;displays the string
	add			esi, 4
	add			edi, 4
	loop		_writeval






;display sum explanation
	call		Crlf
mDisplayString	OFFSET sumexplanation
	call		Crlf



;displays average explanation
	call		Crlf
mDisplayString	OFFSET averageexplanation
	call		Crlf
	call		Crlf



;display goodbye
	PUSH		OFFSET	goodbye										;says goodbye
	call		adios


	Invoke ExitProcess,0	; exit to operating system
main ENDP



;Introduction Procedure!
Introduction	PROC
	
	push			ebp												;push ebp and mov ebp,esp
	mov				ebp,esp
	mDisplayString	[ebp+20]  									    ;mov first intro and write string with display string
	call			Crlf	
	call			Crlf
	mDisplayString  [ebp+16]										;mov second intro and write string with display string								
	call			Crlf
	mDisplayString	[ebp+12]										;mov third intro and write string with display string
	call			Crlf
	mDisplayString	[ebp+8]										    ;mov fourth intro and write string with display string
	call			Crlf												    ;spacing
	call			Crlf

	pop				ebp
	ret				16													;4x4

Introduction	ENDP







;ReadVal Procedure

ReadVal			PROC

	push			ebp												;stores the stack
	mov				ebp, esp
	push			eax
	push			ecx
	push			esi
	push			edi

_getnumber:
	mGetString		[ebp+20], [ebp+12]								;uses get string to get usernumber

_validatelength:
	cmp				eax, register									;validates length using eax from getstring and the constant register(32)
	jg				_error



	mov				edi, [ebp+8]									;moves edi and esi into place for lodsb
	mov				esi, [ebp+12]
	mov				ecx, eax										;uses length of string as ecx
_validatenum:
	lodsb															;lodsb and clear the direction flag
	Cld
	cmp				al,44											;compares the data to ascii to make sure they are valid numbers
	je				_error
	cmp				al,46
	je				_error
	cmp				al,47
	je				_error
	cmp				al,43
	jl				_error
	cmp				al,57
	jg				_error

	sub				eax, 48											;subtracts 48 from eax(al as int) to get the SDWORD value
	mov				edx, [edi]										;movs the total into edx and multiplies by 10
	imul			edx, 10

	add				eax, edx										;adds the total to the number the loop is on

	mov				[edi], eax										;stores the new value into the array slot then loops
	loop			_validatenum									

	jmp				_finish

_error:
	mGetString		[ebp+16], [ebp+12]								;error message and gets new usernumber
	jmp				_validatelength
	call			Crlf
	
_finish:
	pop				edi													;pops the stack
	pop				esi
	pop				ecx
	pop				eax
	pop				ebp
	RET				20
ReadVal			ENDP






;WriteVal Procedure

WriteVal		PROC
	push			ebp												;pushes the stack
	mov				ebp, esp
	push			eax
	push			ecx
	push			esi
	push			edi

	mov				esi, [ebp+12]								    ;edi and esi loaded, moves 1 into ecx
	mov				edi, [ebp+8]
	mov				ecx,1
_writeval:	
	lodsd															;lodsd value
_math:
	CBW																;divides al and gets the remainder into the edi location
	mov				bl, 10
	idiv			bl
	mov				[edi], ah
	cmp				al, 0											;if the number is evenly divided by 10 go to finish
	je				_finish
	std																;decrements the edi to load the next number in front
	stosb

	add				ecx,1											;if number is not divisible by 10 add 1 to ecx and loop

	loop			_math

_finish:
	pop				edi												;pops stack
	pop				esi
	pop				ecx
	pop				eax
	pop				ebp

	ret				12
WriteVal		ENDP






;Goodbye Procedure

adios			PROC

	push			ebp											;standard stack start
	mov				ebp, esp
	mDisplayString	[ebp+8]										;movs goodbye into edx and writes the string
	pop				EBP
	RET				4											;4x1

adios			ENDP





END main
