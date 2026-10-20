.section .text
.global strcmp
.type strcmp, @function

strcmp:

    pushl %ebp
	movl %esp, %ebp
	addl $8, %ebp
    
    #salvataggio dei registri come nel chiamante
    pushl %eax
    pushl %ebx
    pushl %ecx
    pushl %edx 
    

    xorl %ecx,%ecx #contatore
    xorl %edx,%edx

    #rimettiamo nei registri i parametri dallo stack
    movl (%ebp), %ebx 
    movl 4(%ebp), %eax 

    #scorro il parametro in eax e lo confronto con (\0, \n, ',')
    ciclo:
        movb (%eax,%ecx),%dl
        cmpb $0,%dl
        je second_check
        cmpb $10,%dl
        je equal
        cmpb $44,%dl
        je equal
        cmpb  %dl,(%ebx,%ecx)
        jne not_equal
        incl %ecx
        jmp ciclo
    
    second_check:
        cmpb $44,(%ebx,%ecx)
        je equal
        jmp not_equal

    #se i parametri corrispondono salvo 1 nello spazio dello stack riservato al risultato della strcmp
    equal:
        movl $1,8(%ebp)
        jmp return

    #se i parametri corrispondono salvo 0 nello spazio dello stack riservato al risultato della strcmp
    not_equal:
        movl $0,8(%ebp)
        jmp return

    return:
        popl %edx
        popl %ecx
        popl %ebx
        popl %eax
        popl %ebp
        ret
    




