.section .data

pilot_name:
    .string "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"

input_pointer:
    .long 0
    
find_id:
    .string "..\0"

input_id:
    .string "..\0"

invalid_pilot_str:	
.string "Invalid\n\0"

.section .text 
.global telemetry

telemetry:
          
                            
#salvataggio registri 
pushl %eax                  
pushl %ebx
pushl %ecx
pushl %edx
pushl %edi
pushl %esi

#caricamento parametri input output
movl 28(%esp),%esi #parametro input
movl 32(%esp),%edi #parametro output

xorl %ecx, %ecx             # Azzero il valore di ecx

#-----------------------------------------------------------------------
# Ricerca dell' id del pilota e scrittura in una stringa
#carichiamo in eax la stringa in input e la mettiamo nella pilot name

leal pilot_name,%eax

#lettura della stringa pilota nel file di input
ciclo_id: 
    movb (%esi,%ecx),%dl
    movb %dl,(%eax,%ecx)
    incl %ecx
    cmpb $10,%dl   # Controllo se l'ultimo carattere e uguale al carattere di terminazione, in caso positivo
    jne ciclo_id



#-------------------------------------------------------------------------------------
#confronta nella stringa ricevuta in input con quella dei piloti per trovare l'id
xorl %edx, %edx
search_id:
    subl $4,%esp
    pushl %eax
    call searchId
    popl %eax
    movl (%esp),%edx
    addl $4,%esp
    cmpl $19,%edx
    jg invalid
    jmp equals_string

    #---------------------------------------------------------------------
    #id trovato 
    equals_string:
        xorl %eax, %eax
        xorl %ebx, %ebx
        xorl %edi,%edi

        #conversione id pilota in stringa
        subl $4, %esp
        pushl %edx
        call itoa
        popl %edx
        movl (%esp),%edx
        addl $4,%esp

    
    start_new_line:
        xorl %edi,%edi
        xorl %eax,%eax
        movl %ecx,input_pointer 

    #spostamento puntatore file input dopo la prima virgola
    first_comma: 
        cmpl $0,%ecx
        je last_line
        cmpl $0,(%esi,%ecx)
        je last_line
        movb (%esi,%ecx),%bl
        incl %ecx
        cmpb $44,%bl             
        jne first_comma

    #azzeramento registri e caricamento della variabile riservata all'input_id
    xorl %eax,%eax #adesso in eax possiamo salvare l'ID
    xorl %edi,%edi
    leal input_id,%eax

    #lettura dell' id da file e caricamento nella variabile riservata
    read_id:
        movb (%esi,%ecx),%bl
        movb %bl,(%eax,%edi)
        incl %ecx
        incl %edi
        cmpb $44,%bl             
        jne read_id
        #salvataggio dei parametri per la strcmp
        subl $4,%esp
        pushl %edx
        pushl %eax
        call strcmp #cmp tra id file e id trovato
        popl %eax
        popl %edx
        cmpl $1,(%esp)
        je save_dates #id corrispondono salvo i dati per l'elaborazione
        addl $4,%esp
        subl $4,%esp
        #se id non corrispondono passo alla riga del file di input successiva
        call newLine 
        movl (%esp),%ecx #aggiornamento puntatore alla riga successiva nel file di input
        addl $4,%esp
        jmp start_new_line #riaggiorniamo il puntatore alla prima virgola per ogni riga


    save_dates:
        addl $4,%esp
        pushl %ecx
        movl input_pointer,%ecx
        pushl %ecx
        #chiamata alla funzione che elabora i dati della stringa con il pilota associato
        call date_elaboration
        popl %ecx
        popl %ecx
        subl $4,%esp
        #passaggio alla riga successiva
        call newLine 
        movl (%esp),%ecx
        addl $4,%esp
        jmp start_new_line

#gestione pilota non valido
invalid:
    xorl %eax,%eax
    xorl %ebx,%ebx
    xorl %ecx,%ecx
    xorl %edx,%edx
    leal invalid_pilot_str,%eax
    #stampa sul file di output la stringa invalid
    print_invalid:
        movb (%eax,%ecx),%bl
        movb %bl,(%edi,%ecx)
        cmpb $0,%bl
        je fine
        incl %ecx
        jmp print_invalid

#settings per calcolare i dati per l' ultima riga
last_line:
    xorl %eax,%eax
    xorl %ebx,%ebx
    xorl %ecx,%ecx
    xorl %edx,%edx
    movl $4,%eax
    pushl %eax
    call date_elaboration
    popl %eax
    jmp fine
    
# rispristino valori registri e return al main.c
fine:
    popl %esi
    popl %edi
    popl %edx
    popl %ecx
    popl %ebx
    popl %eax
ret

