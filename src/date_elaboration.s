
.section .data

    INPUT_SPEED: .ascii "\0\0\0\0" 
    INPUT_RPM: .ascii "\0\0\0\0\0\0"
    TEMP_MAX: .long 0 
    AVERAGE_SPEED: .long 0 
    MAX_SPEED: .long 0 
    INPUT_TEMP: .ascii "\0\0\0\0"
    MAX_RPM: .long 0 
    LOW_RPM: .long 5000 
    HIGH_RPM: .long 10000 
    OUTPUT_POINTER: .long 0
    ITERATION_SPEED: .long 0

.section .text

	.global date_elaboration
	.type date_elaboration, @function

date_elaboration:
    #salvataggio ebp nello stack
    pushl %ebp
    movl %esp,%ebp
    addl $8,%ebp #spostiamo ebp per recuperare il puntatore per la stampa del tempo
    
    #salvataggio registri
    pushl %eax
    pushl %ebx
    pushl %ecx
    pushl %edx

    #controllo per l'ultima riga
    cmpl $4,(%ebp)
    je last_line

    xorl %ecx,%ecx
    movl 40(%ebp),%edi
    movl (%ebp),%eax #carichiamo il puntatore per stampare il tempo
    movl OUTPUT_POINTER,%ecx
    #stampa tempo file output
    print_time:
        movb (%esi,%eax),%bl
        movb %bl,(%edi,%ecx)
        incl %eax
        incl %ecx
        cmpb $44,%bl
        jne print_time
    #aggiornamento puntatore file output
    pushl %ecx
    movl %ecx,OUTPUT_POINTER



    #caricamento variabile per la lettura della velocità nel file di input
    xorl %eax,%eax
    leal INPUT_SPEED,%eax
    xorl %edi,%edi
    xorl %edx,%edx #azzeriamo per usarlo come contatore virgole
    movl 4(%ebp),%ecx #rispristino ecx che punta all'id del file input


    #lettura del parametro in input e inserito nella variabile caricata in eax
    #il ciclo salta a determinate etichette a seconda del numero di virgole o \n trovate
    #se dovesse trovare \0 il ciclo salta a rpm e si procede all'elaborazione dei dati trovati per mandarli in stampa
    ciclo:
        movb (%esi,%ecx),%bl
        cmpb $0,%bl
        je rpm
        movb %bl,(%eax,%edi)
        incl %ecx
        incl %edi
        cmpb $44,%bl
        je comma
        cmpb $10,%bl
        je rpm
        jmp ciclo
        
    #etichetta che gestisce le virgole e a cascata le evenuali azioni
    comma:
        cmpl $0,%edx
        je comma_rpm
        jmp comma_temp

    #caricamento variabile per salvare rpm e chiamata al ciclo per leggerlo da input
    comma_rpm:
        incl %edx
        leal INPUT_RPM,%eax
        xorl %edi,%edi
        jmp ciclo
    
    #caricamento variabile per salvare temperatura e chiamata al ciclo per leggerla da input
    comma_temp:
        leal INPUT_TEMP,%eax
        xorl %edi,%edi
        jmp ciclo

    #gestione rpm
    rpm:
        leal INPUT_RPM,%eax
        subl $4,%esp
        pushl %eax #carichiamo nello stack input_rpm
        call str2num #conversione da stringa in numero
        popl %eax
        movl (%esp),%eax
        addl $4,%esp
        #salvataggio della max rpm
        xorl %ebx,%ebx
        leal MAX_RPM,%ebx
        movl (%ebx),%ebx
        cmpl %ebx,%eax
        jg max_rpm
        #confronti per determinare il livello e chiamata alla corrispondente etichetta
        continue_rpm:
            movl $1,%edx
            xorl %ebx,%ebx
            leal LOW_RPM,%ebx
            movl (%ebx),%ebx
            cmpl %ebx,%eax
            jle low_level
            xorl %ebx,%ebx
            leal HIGH_RPM,%ebx
            movl (%ebx),%ebx
            cmpl %ebx,%eax
            jg high_level
            jmp medium_level

    max_rpm:
        #aggiornamento della variabile
        movl %eax,MAX_RPM
        jmp continue_rpm

    #gestione temperatura
    temp:
        leal INPUT_TEMP,%eax
        subl $4,%esp
        pushl %eax #carichiamo nello stack input_temp
        call str2num #conversione da stringa in numero
        popl %eax
        movl (%esp),%eax
        addl $4,%esp
        #salvataggio della max temp
        xorl %ebx,%ebx
        leal TEMP_MAX,%ebx
        movl (%ebx),%ebx
        cmpl %ebx,%eax
        jg max_temp
        #confronti per determinare il livello e chiamata alla corrispondente etichetta
        continue_temp:
            incl %edx
            xorl %ebx,%ebx
            movl $90,%ebx
            cmpl %ebx,%eax
            jle low_level
            xorl %ebx,%ebx
            movl $110,%ebx
            cmpl %ebx,%eax
            jg high_level
            jmp medium_level

    max_temp:
        #aggiornamento della variabile
        movl %eax,TEMP_MAX
        jmp continue_temp

    #gestione velocità
    speed:
        xorl %ebx,%ebx
        movl ITERATION_SPEED,%ebx
        incl %ebx
        movl %ebx,ITERATION_SPEED
        leal INPUT_SPEED,%eax
        subl $4,%esp
        pushl %eax #carichiamo nello stack input_value
        call str2num #conversione da stringa in numero
        popl %eax
        movl (%esp),%eax
        addl $4,%esp
        #salvataggio della max speed
        xorl %ebx,%ebx
        leal MAX_SPEED,%ebx
        movl (%ebx),%ebx
        cmpl %ebx,%eax
        jg max_speed
        #confronti per determinare il livello e chiamata alla corrispondente etichetta
        continue_speed:
            incl %edx
            xorl %ebx,%ebx
            #facciamo la somma di speed per calcolare la media
            movl AVERAGE_SPEED,%ebx
            addl %eax,%ebx
            movl %ebx,AVERAGE_SPEED
            xorl %ebx,%ebx
            movl $100,%ebx
            cmpl %ebx,%eax
            jle low_level
            xorl %ebx,%ebx
            movl $250,%ebx
            cmpl %ebx,%eax
            jg high_level
            jmp medium_level

    max_speed:
        #aggiornamento della variabile
        movl %eax,MAX_SPEED
        jmp continue_speed

    #settings per la stampa di low level
    low_level:
        subl $4,%esp
        movl $1,(%esp) #carichiamo nello stack l'identificativo di LOW
        call print
        addl $4,%esp
        cmpl $1,%edx
        je temp
        cmpl $2,%edx
        je speed
        jmp fine

    #settings per la stampa di medium level
    medium_level:
        subl $4,%esp
        movl $2,(%esp) #carichiamo nello stack l'identificativo di MEDIUM
        call print
        addl $4,%esp
        cmpl $1,%edx
        je temp
        cmpl $2,%edx
        je speed
        jmp fine

    #settings per la stampa di high level
    high_level:
        subl $4,%esp
        movl $3,(%esp) #carichiamo nello stack l'identificativo di HIGH
        call print
        addl $4,%esp
        cmpl $1,%edx
        je temp
        cmpl $2,%edx
        je speed
        jmp fine

    #elaborazione dati per la stampa dell'ultima riga
    last_line:
        #reset registri
        xorl %eax,%eax
        xorl %ebx,%ebx
        xorl %ecx,%ecx
        xorl %edx,%edx

        #calcolo della velocità media
        movl AVERAGE_SPEED,%eax
        movl ITERATION_SPEED,%ebx
        cmpl $0,%ebx
        je no_div
        divl %ebx
        movl %eax,AVERAGE_SPEED
        
    no_div:

        #reset registri
        xorl %eax,%eax
        xorl %ebx,%ebx
        xorl %ecx,%ecx
        xorl %edx,%edx

        #traduzione da numero a stringa di MAX_RPM
        movl MAX_RPM,%eax
        subl $4, %esp
        pushl %eax
        call itoa
        popl %eax
        movl (%esp),%eax
        addl $4,%esp
        movl $4,%ebx
        pushl %ebx
        movl OUTPUT_POINTER,%ecx #caricamento puntatore file di output nello stack
        pushl %ecx
        pushl %eax
        pushl %edx
        call print #chiamata alla stampa di MAX_RPM
        popl %edx
        popl %eax
        popl %ecx
        popl %ebx
        incl %edx
        movl %ecx,OUTPUT_POINTER #aggiornamento puntatore file output

        #reset registri
        xorl %eax,%eax
        xorl %ebx,%ebx
        xorl %ecx,%ecx

        #traduzione da numero a stringa di TEMP_MAX
        movl TEMP_MAX,%eax
        subl $4, %esp
        pushl %eax
        call itoa
        popl %eax
        movl (%esp),%eax
        addl $4,%esp
        movl $4,%ebx
        pushl %ebx
        movl OUTPUT_POINTER,%ecx #caricamento puntatore file di output nello stack
        pushl %ecx
        pushl %eax
        pushl %edx
        call print #chiamata alla stampa di TEMP_MAX
        popl %edx
        popl %eax
        popl %ecx
        popl %ebx
        incl %edx
        movl %ecx,OUTPUT_POINTER #aggiornamento puntatore file output

        #reset registri
        xorl %eax,%eax
        xorl %ebx,%ebx
        xorl %ecx,%ecx

        #traduzione da numero a stringa di MAX_SPEED
        movl MAX_SPEED,%eax
        subl $4, %esp
        pushl %eax
        call itoa
        popl %eax
        movl (%esp),%eax
        addl $4,%esp
        movl $4,%ebx
        pushl %ebx
        movl OUTPUT_POINTER,%ecx #caricamento puntatore file di output nello stack
        pushl %ecx
        pushl %eax
        pushl %edx
        call print #chiamata alla stampa di MAX_SPEED
        popl %edx
        popl %eax
        popl %ecx
        popl %ebx
        incl %edx
        movl %ecx,OUTPUT_POINTER #aggiornamento puntatore file output

        #reset registri
        xorl %eax,%eax
        xorl %ebx,%ebx
        xorl %ecx,%ecx

        #traduzione da numero a stringa di AVERAGE_SPEED
        movl AVERAGE_SPEED,%eax
        subl $4, %esp
        pushl %eax
        call itoa
        popl %eax
        movl (%esp),%eax
        addl $4,%esp
        movl $4,%ebx
        pushl %ebx
        movl OUTPUT_POINTER,%ecx #caricamento puntatore file di output nello stack
        pushl %ecx
        pushl %eax
        pushl %edx
        call print #chiamata alla stampa di AVERAGE_SPEED
        popl %edx
        popl %eax
        popl %ecx
        popl %ebx
        movl %ecx,OUTPUT_POINTER #aggiornamento puntatore file output
        jmp end_print




    #etichetta per aggiornare stack puntatore output e stack per stampa delle righe 
    fine:
        xorl %ebx,%ebx
        movl (%esp),%ebx
        movl %ebx,OUTPUT_POINTER
        addl $4,%esp
    
    #ripristino registri e return
    end_print:
        popl %edx
        popl %ecx
        popl %ebx
        popl %eax
        popl %ebp
        ret
