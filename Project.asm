	.begin
BASE	.equ	0x3fffc0
COUT	.equ	0x0
COTSTAT .equ	0x4
CIN	.equ 	0x8
CINSTAT .equ	0xc

Oct	.equ	0x7
Hex	.equ	0xf

Selct	.equ	3980
Array	.equ	4000
Menu	.equ	2048
Number	.equ	3800
InfoH	.equ	2500
InfoQ	.equ	2600
Soted	.equ	2700
Upper	.equ	2800
Lower	.equ	2900
InfoOct	.equ	3000
InfoHex	.equ	3100
Greet	.equ	3200

	.org	10000
!####Macro	Program####
!-----------------------------------------------
.macro	pop	r
	ld	%r14,	r
	add	%r14,	4,	%r14
.endmacro

.macro	push	r
	sub	%r14,	4,	%r14
	st	r,	%r14
.endmacro

.macro	pushI	num
	sub	%r14,	4,	%r14
	mov	num,	%r31
	st	%r31,	%r14
.endmacro

.macro	store	r,	num
	sub	r,	4,	r
	st	num,	r
.endmacro

.macro	init
	clr	%r30
	sethi	0x3fffc0,	%r30
	sethi	0x200000,	%r14
.endmacro

.macro	return X
	pop	%r1

.if	X > 0
	push	%rX
.endif

	jmpl	%r1+4,	%r0
.endmacro

.macro	left	r1,	r2
	sll	r1,	1,	r2
	add	r2,	4,	r2
.endmacro

.macro	right	r1,	r2
	sll	r1,	1,	r2
	add	r2,	8,	r2
.endmacro


.macro	swap	r1,	r2,	r3
	ld	[r1+r3],	%r28
	ld	[r2+r3],	%r27
	st	%r27,	[r1+r3]
	st	%r28,	[r2+r3]
.endmacro

.macro	save
	push	%r1
	push	%r2
	push	%r3
	push	%r4
	push	%r5
	push	%r6
	push	%r7
	push	%r8
	push	%r9
.endmacro

.macro	load
	pop	%r9
	pop	%r8
	pop	%r7
	pop	%r6
	pop	%r5
	pop	%r4
	pop	%r3
	pop	%r2
	pop	%r1
.endmacro	
!-----------------------------------------------


!####Main	Function####
!-----------------------------------------------
	init
	
	pushI	Greet
	call	Put

	pushI	Array			!Read data
	call	Read

	call	Select
	
	pushI	Soted			!Sort and select
	call	Put
	pushI	Array
	call	Put

	pushI	Array			!To uppercase
	call	Uppercase
	
	pushI	Upper
	call	Put
	pushI	Array
	call	Put
	
	pushI	Array			!Get summary
	call	Sum
	pop	%r1
	push	%r1
	push	%r1
	
	pushI	Number			!Translate a number to Octal
	call	GetOctal
	pushI	InfoOct
	call	Put
	call	Put

	pushI	Number			!Translate a number to Hexadecimal
	call	GetHex
	pushI	InfoHex
	call	Put
	call	Put

	halt
!-----------------------------------------------


!####Read	Data	Function####
!-----------------------------------------------
Read:	
	clr	%r2
	pop	%r4
	push	%r15
WaitInput:	
	ldub	[%r30+CINSTAT],	%r1
	andcc	%r1,	0x80,	%r1
	be	WaitInput

	ldub	[%r30+CIN],	%r3
	
	st	%r3,	[%r2+%r4]

	cmp	%r3,	27		!If this character is ESC, end input
	be	EndInput

PutChar:
	ldub	[%r30+COTSTAT],	%r1	!if read a character then print to the screen
	andcc	%r1,	0x80,	%r1
	be	PutChar
	stb	%r3,	[%r30+COUT]
	
	add	%r2,	4,	%r2
	ba	WaitInput

EndInput:
	st	%r0,	[%r2+%r4]	!Change the last character to '\0'
	return	2
!-----------------------------------------------


!####Put	Data	Function####
!-----------------------------------------------
Put:	
	pop	%r4
	clr	%r5
	push	%r15

WaitOutput:
	ldub	[%r30+COTSTAT],	%r1
	andcc	%r1,	0x80,	%r1
	be	WaitOutput
	
	ld	[%r4+%r5],	%r3

	cmp	%r3,	%r0		!If the character not is '\0', mean the string is not end
	bne	NotEnd
	mov	0xa,	%r3		!When the character is '\0', then print '\n' to the screen
	stb	%r3,	[%r30+COUT]
	ba	EndPut

NotEnd:
	stb	%r3,	[%r30+COUT]
	add	%r5,	4,	%r5
	ba	WaitOutput

EndPut:
	return 0
!-----------------------------------------------


!####Selection	Function####
!-----------------------------------------------
Select:
	pop	%r4
	push	%r15
	
	save				!Print menu to screen
	pushI	Menu
	call	Put
	load
	
WaitSelect:
	ldub	[%r30+CINSTAT],	%r1
	andcc	%r1,	0x80,	%r1
	be	WaitSelect
	ldub	[%r30+CIN],	%r3

	cmp	%r3,	49
	be	TypeOne
	cmp	%r3,	50
	be	TypeTwo
	ba	WaitSelect

TypeOne:
	save
	pushI	InfoQ
	call	Put
	load	


	add	%r4,	Array,	%r5
	sub	%r5,	4,	%r5
	pushI	Array
	push	%r5
	call	QuickSort
	return	0

TypeTwo:
	save
	pushI	InfoH
	call	Put
	load

	pushI	Array
	push	%r4
	call	HeapSort
	return	0
!-----------------------------------------------


!####Heap	Srot	Function####
!-----------------------------------------------
HeapSort:
	pop	%r8
	pop	%r2
	push	%r15

	save

	push	%r2
	push	%r8
	call	CreateHeap		!To make a heap

	load

MakeSort:
	cmp	%r8,	%r0
	be	EndSort			!When the heap is empty, end the loop

	sub	%r8,	4,	%r7
	
	swap	%r0,	%r7,	%r2	!Delete the root node and move last node to the root node
	sub	%r8,	4,	%r8	!Reduce the size of heap by four
	
	save

	push	%r2
	push	%r0
	push	%r8
	call	DropNode		!To adjust the new root node

	load
	
	ba	MakeSort

EndSort:	

	return	0
!-----------------------------------------------


!####Create	Heap	Function####
!-----------------------------------------------
CreateHeap:
	pop	%r8
	pop	%r2
	push	%r15
	
	srl	%r8,	3,	%r1
	sll	%r1,	2,	%r1

Adjust:
	save

	push	%r2
	push	%r1
	push	%r8
	call	DropNode

	load

	cmp	%r1,	%r0
	be	EndCreat

	sub	%r1,	4,	%r1
	ba	Adjust

EndCreat:
	return	0
!-----------------------------------------------


!####Drop	Node	Function####
!-----------------------------------------------
DropNode:
	pop	%r9
	pop	%r1
	pop	%r2
	push	%r15

	mov	%r1,	%r3
	
	left	%r3,	%r5
	right	%r3,	%r6

	cmp	%r5,	%r9
	bge	EndDrop

	ld	[%r3+%r2],	%r7
	ld	[%r5+%r2],	%r8

	cmp	%r7,	%r8
	bge	LeftInvaid
	mov	%r5,	%r3

LeftInvaid:
	cmp	%r6,	%r9
	bge	RightInvaid

	ld	[%r3+%r2],	%r7
	ld	[%r6+%r2],	%r8

	cmp	%r7,	%r8
	bge	RightInvaid
	mov	%r6,	%r3

RightInvaid:
	cmp	%r3,	%r1
	be	EndDrop

	push	%r2
	push	%r3
	push	%r9
	swap	%r1,	%r3, %r2
	call	DropNode

EndDrop:
	return	0
!-----------------------------------------------


!####Quick	Sort	Function####
!-----------------------------------------------
QuickSort:
	pop	%r4
	pop	%r3
	push	%r15

	ld	%r3,	%r5

	mov	%r3,	%r1
	mov	%r4,	%r2

WhileA:
	cmp	%r1,	%r2
	be	DoneA

WhileB:
	cmp	%r1,	%r2
	be	DoneB
	ld	%r2,	%r6
	cmp	%r5,	%r6
	bg	DoneB
	sub	%r2,	4,	%r2
	ba	WhileB

DoneB:
	ld	%r2,	%r7
	st	%r7,	%r1

WhileC:
	cmp	%r1,	%r2
	be	DoneC
	ld	%r1,	%r6
	cmp	%r5,	%r6
	bl	DoneC
	add	%r1,	4,	%r1
	ba	WhileC

DoneC:	ld	%r1,	%r7
	st	%r7,	%r2

	ba	WhileA

DoneA:	
	st	%r5,	%r1
	add	%r1,	4,	%r5
	sub	%r1,	4,	%r6

	cmp	%r3,	%r6
	bge	NotLeft

	save

	push	%r3
	push	%r6

	call	QuickSort		!To sort the left
	
	load

NotLeft:
	cmp	%r4,	%r5
	ble	NotRight
	
	push	%r5
	push	%r4
	
	call	QuickSort		!To sort the right

NotRight:
	return	0
!-----------------------------------------------


!####To		Uppercase	Function####
!-----------------------------------------------
Uppercase:
	pop	%r2
	push	%r15
UpperLoop:
	ld	%r2,	%r3
	cmp	%r3,	%r0
	be	EndUpper
	
	cmp	%r3,	97
	bl	SkipUpper
	cmp	%r3,	122
	bg	SkipUpper

	sub	%r3,	32,	%r3
	st	%r3,	%r2

SkipUpper:
	add	%r2,	4,	%r2
	ba	UpperLoop
EndUpper:
	return	0
!-----------------------------------------------


!####To		Lowercase	Function####
!-----------------------------------------------
Lowercase:
	pop	%r2
	push	%r15
LowerLoop:
	ld	%r2,	%r3
	cmp	%r3,	%r0
	be	EndLower
	
	cmp	%r3,	65
	bl	SkipLower
	cmp	%r3,	90
	bg	SkipLower

	add	%r3,	32,	%r3
	st	%r3,	%r2

SkipLower:
	add	%r2,	4,	%r2
	ba	LowerLoop
EndLower:
	return	0
!-----------------------------------------------


!####Get	Octal	Number	Function####
!-----------------------------------------------
GetOctal:
	pop	%r2
	pop	%r1
	store	%r2,	%r0
	push	%r15
DivideOctal:
	cmp	%r1,	%r0
	be	EndOctal
	
	and	%r1,	Oct,	%r3
	add	%r3,	48,	%r3
	store	%r2,	%r3
	srl	%r1,	3,	%r1
	ba	DivideOctal

EndOctal:
	return	2
!-----------------------------------------------


!####Get	Hexadecimal	Number	Function####
!-----------------------------------------------
GetHex:
	pop	%r2
	pop	%r1
	store	%r2,	%r0
	push	%r15
DivideHex:
	cmp	%r1,	%r0
	be	EndHex
	
	and	%r1,	Hex,	%r3	!Get the last four bits

	cmp	%r3,	10
	bl	LessTen
	add	%r3,	7,	%r3	!Translate to character

LessTen:
	add	%r3,	48,	%r3
	
	store	%r2,	%r3
	srl	%r1,	4,	%r1
	ba	DivideHex

EndHex:
	return	2
!-----------------------------------------------


!####Get	Sum	Function####
!-----------------------------------------------
Sum:
	pop	%r2
	clr	%r4
	push	%r15
GetNext:
	ld	%r2,	%r3
	cmp	%r3,	%r0
	be	EndSum

	add	%r3,	%r4,	%r4
	add	%r2,	4,	%r2
	ba	GetNext

EndSum:
	return	4
!-----------------------------------------------


	.org	2048
!####Menu####
!-----------------------------------------------
	0x0a
	0x53,0x65,0x6c,0x65
	0x63,0x74,0x20,0x74
	0x68,0x65,0x20,0x73
	0x6f,0x72,0x74,0x69
	0x6e,0x67,0x20,0x61
	0x6c,0x67,0x6f,0x72
	0x69,0x74,0x68,0x6d
	0x0a,0x31,0x2e,0x20
	0x51,0x75,0x69,0x63
	0x6b,0x73,0x6f,0x72
	0x74,0x0a,0x32,0x2e
	0x20,0x48,0x65,0x61
	0x70,0x73,0x6f,0x72
	0x74
	0x00
!-----------------------------------------------


	.org	2500
!####Information	Heapsort####
!-----------------------------------------------
	0x48,0x65,0x61,0x70
	0x20,0x73,0x6f,0x72
	0x74,0x69,0x6e,0x67
	0x00
!-----------------------------------------------

	.org	2600
!####Information	Quicksort####
!-----------------------------------------------
	0x51,0x75,0x69,0x63
	0x6b,0x20,0x73,0x6f
	0x72,0x74,0x69,0x6e
	0x67
	0x00
!-----------------------------------------------

	.org	2700
!####Information	Soted####
!-----------------------------------------------
	0x53,0x6f,0x72,0x74
	0x65,0x64,0x3a
	0x00
!-----------------------------------------------

	.org	2800
!####Information	Uppercase####
!-----------------------------------------------
	0x55,0x70,0x70,0x65
	0x72,0x63,0x61,0x73
	0x65,0x3a
	0x00
!-----------------------------------------------

	.org	2900
!####Information	Lowercase####
!-----------------------------------------------
	0x4c,0x6f,0x77,0x65
	0x72,0x63,0x61,0x73
	0x65,0x3a
	0x00
!-----------------------------------------------


	.org	3000
!####Information	Oct####
!-----------------------------------------------
	0x4f,0x63,0x74,0x61
	0x6c,0x3a
	0x00
!-----------------------------------------------

	.org	3100
!####Information	Hex####
!-----------------------------------------------
	0x48,0x65,0x78,0x61
	0x64,0x65,0x63,0x69
	0x6d,0x61,0x6c,0x3a
	0x00
!-----------------------------------------------

	.org	3200
!####Information	greet####
!-----------------------------------------------
	0x50,0x6c,0x65,0x61
	0x73,0x65,0x20,0x65
	0x6e,0x74,0x65,0x72
	0x20,0x61,0x20,0x73
	0x74,0x72,0x69,0x6e
	0x67,0x3a
	0x00
!-----------------------------------------------

	.end
