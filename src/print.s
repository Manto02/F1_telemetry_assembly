.section .data
    LOW_LEVEL:
        .ascii "LOW\0"
    MEDIUM_LEVEL:
        .ascii "MEDIUM\0"
    HIGH_LEVEL:
        .ascii "HIGH\0"


.section .text
	.global print
	.type print, @function

print:
    #settings per gestione stampa ultima riga
    addl $16,%esp
    cmpl $4,(%esp)
    je last_line
    subl $16,%esp

    #salvataggio ebp per prendere i parametri presenti nello stack
    pushl %ebp
    movl %esp,%ebp
    addl $80,%ebp #spostato fino al parametro di output

    #salvataggio registri
    pushl %eax
    pushl %ebx
    pushl %ecx
    pushl %edx
    pushl %edi
    pushl %esi

    #carichiamo in edi il parametro del file di output
    movl (%ebp),%edi

    #azzeramento registri
    xorl %eax,%eax
    xorl %ebx,%ebx
    xorl %ecx,%ecx

    #recupero del puntatore del file di output
    movl 36(%esp),%ecx 


#stampa dei valori livello dei vari parameti passati
print_level:
    movl 32(%esp),%eax #recupero etichetta del livello
    cmpl $1,%eax
    je print_low
    cmpl $2,%eax
    je print_medium
    jmp print_high
    
    #caricamento stringhe livelli in esi per la stampa
    print_low:
        leal LOW_LEVEL,%esi
        xorl %eax,%eax
        jmp ciclo_level

    print_medium:
        leal MEDIUM_LEVEL,%esi
        xorl %eax,%eax
        jmp ciclo_level

    print_high:
        leal HIGH_LEVEL,%esi
        xorl %eax,%eax
        jmp ciclo_level

    ciclo_level:
        movb (%esi,%eax),%bl
        cmpb $0,%bl
        je fine_level
        movb %bl,(%edi,%ecx)
        incl %ecx
        incl %eax
        jmp ciclo_level


#controlli per stampare virgola o \n a seconda del parametro stampato
fine_level:
    cmpl $3,%edx
    je new_line
    jmp comma

#stampa \n
new_line:
    movb $10,(%edi,%ecx)
    incl %ecx
    subl $68,%ebp
    jmp fine

#stampa virgola
comma:
    movb $44,(%edi,%ecx)
    incl %ecx
    subl $68,%ebp
    jmp fine

#stampa dell'ultima riga
last_line:
    #salvataggio valori nello stack
    subl $16,%esp
    pushl %ebp
    movl %esp,%ebp
    addl $84,%ebp #spostato fino al parametro di output

    #salvataggio registri
    pushl %eax
    pushl %ebx
    pushl %ecx
    pushl %edx
    pushl %edi
    pushl %esi

    #carichiamo in edi il parametro del file di output
    movl (%ebp),%edi

    #azzeramento registri
    xorl %eax,%eax
    xorl %ebx,%ebx
    xorl %ecx,%ecx

    #recupero parametri file output e stringhe da stampare a video
    movl 40(%esp),%ecx #recupero del puntatore del file di output
    subl $72,%ebp #riportiamo ebp al parametro da stampare
    movl (%ebp),%esi
    subl $4,%ebp
    movl (%ebp),%edx

    ciclo_string:
        movb (%esi,%eax),%bl
        cmpb $0,%bl
        je fine_string
        movb %bl,(%edi,%ecx)
        incl %ecx
        incl %eax
        jmp ciclo_string

    #controlli per la stampa della virgola o EOF a seconda del parametro presente
    fine_string:
        cmpl $3,%edx
        je EOF
        jmp comma_last_line

    #stampa della virgola
    comma_last_line:
        movb $44,(%edi,%ecx)
        incl %ecx
        addl $8,%ebp
        jmp fine

    #stampa EOF
    EOF:
        movb $10,(%edi,%ecx)
        incl %ecx
        movb $0,(%edi,%ecx)
        incl %ecx
        addl $8,%ebp
        jmp fine

#ripristino valori e return
fine:
    movl %ecx,(%ebp) #salviamo nello stack il puntatore del file di output
    popl %esi
    popl %edi
    popl %edx
    popl %ecx
    popl %ebx
    popl %eax
    popl %ebp
    ret
    

