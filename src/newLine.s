.section .text
.global newLine
.type newLine, @function

newLine:

    pushl %ebp
	movl %esp, %ebp

    #salvataggio dei registri come nel chiamante
    pushl %eax
    pushl %ebx
    pushl %ecx
    pushl %edx 

    #scorriamo il file di input aggiornando il puntatore ecx fino al raggiungimento della nuova riga
    ciclo_newline:
        movb (%esi,%ecx),%bl
        incl %ecx
        cmpb $0,%bl 
        je end_file
        cmpb $10,%bl 
        je second_check
        jmp ciclo_newline

    second_check:
        cmpb $0,(%esi,%ecx)
        je end_file
        jmp fine
        
    end_file:
        movl $0,%ecx
    fine:
        movl %ecx,8(%ebp) #salvo il nuovo valore del puntatore nello spazio riservato nello stack
        popl %edx
        popl %ecx
        popl %ebx
        popl %eax
        popl %ebp
        ret

     