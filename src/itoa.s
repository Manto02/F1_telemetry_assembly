# Conversione in stringa del numero caricato nello stack dal chiamante
# Il valore di ritorno è nello stack sotto al numero.

.section .data
	num: .ascii "\0\0\0\0\0\0\0\0\0\0\0\0"

.section .text
	.global itoa
	.type itoa, @function
itoa:

	# salvataggio ebp e spostamento per farlo puntare ai parametri
	pushl %ebp
	movl %esp, %ebp
	addl $8, %ebp

	# salvataggio registri
	pushl %eax
	pushl %ebx
	pushl %ecx
	pushl %edx

	#reset della variabile num
    xorl %ecx,%ecx
	leal num,%eax
    reset_num:
        movb (%eax,%ecx),%bl
		cmpb $0,%bl
        je continue
        movb $0,(%eax,%ecx)
        incl %ecx
        jmp reset_num

	continue:
	#reset registri
	xorl %eax,%eax
	xorl %ebx,%ebx
	xorl %ecx,%ecx
	# caricamento numero e divisore
	movl (%ebp), %eax
	movl $10, %ebx

	# azzeramento contatore
	xorl %ecx, %ecx

	# salvataggio nello stack delle singole cifre e conteggio
	division:
		cmpl $10, %eax
		jl last_cipher
		xorl %edx, %edx
		divl %ebx
		pushl %edx
		incl %ecx
		jmp division
		
# salvataggio ultima cifra
last_cipher:
	pushl %eax
	incl %ecx
	# copio le cifre nella stringa
	leal num, %ebx
	xorl %edx, %edx
	copy:
		popl %eax
		addl $48, %eax
		movb %al, (%ebx, %edx)
		incl %edx
		loop copy
	# restituisco indirizzo stringa
	movl %ebx, 4(%ebp)
	# ripristino registri e fine funzione
	popl %edx
	popl %ecx
	popl %ebx
	popl %eax
	popl %ebp
	ret
