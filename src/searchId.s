.section .data
pilot_0_str:
    .string   "Pierre Gasly\0"
pilot_1_str:
    .string   "Charles Leclerc\0"
pilot_2_str:
    .string   "Max Verstappen\0"
pilot_3_str:                       
    .string   "Lando Norris\0"
pilot_4_str:
    .string   "Sebastian Vettel\0"
pilot_5_str:
    .string   "Daniel Ricciardo\0"
pilot_6_str: 
    .string   "Lance Stroll\0"
pilot_7_str:
    .string   "Carlos Sainz\0"
pilot_8_str:
    .string   "Antonio Giovinazzi\0"
pilot_9_str:
    .string   "Kevin Magnussen\0"
pilot_10_str:
    .string  "Alexander Albon\0"
pilot_11_str:
    .string  "Nicholas Latifi\0"
pilot_12_str:
    .string  "Lewis Hamilton\0"
pilot_13_str:
    .string  "Romain Grosjean\0"
pilot_14_str:
    .string  "George Russell\0"
pilot_15_str:
    .string  "Sergio Perez\0"
pilot_16_str:
    .string  "Daniil Kvyat\0"
pilot_17_str:
    .string  "Kimi Raikkonen\0"
pilot_18_str:
    .string  "Esteban Ocon\0"
pilot_19_str:
    .string  "Valtteri Bottas\0"

.section .text
.global searchId
.type searchId, @function

searchId:

    #caricamento e spostamento ebp nello stack
    pushl %ebp
    movl %esp,%ebp
    addl $8,%ebp #puntiamo il valore dallo stack

    #salvataggio registri
    pushl %eax
    pushl %ebx
    pushl %ecx
    pushl %edx

    #azzeramento registri
    xorl %eax,%eax
    xorl %ebx,%ebx
    xorl %ecx,%ecx
    xorl %edx,%edx

    movl %esp,%ecx

    #caricamento stringhe piloti nello stack
    leal pilot_19_str,%eax
    pushl %eax
    leal pilot_18_str,%eax
    pushl %eax
    leal pilot_17_str,%eax
    pushl %eax
    leal pilot_16_str,%eax
    pushl %eax
    leal pilot_15_str,%eax
    pushl %eax
    leal pilot_14_str,%eax
    pushl %eax
    leal pilot_13_str,%eax
    pushl %eax
    leal pilot_12_str,%eax
    pushl %eax
    leal pilot_11_str,%eax
    pushl %eax
    leal pilot_10_str,%eax
    pushl %eax
    leal pilot_9_str,%eax
    pushl %eax
    leal pilot_8_str,%eax
    pushl %eax
    leal pilot_7_str,%eax
    pushl %eax
    leal pilot_6_str,%eax
    pushl %eax
    leal pilot_5_str,%eax
    pushl %eax
    leal pilot_4_str,%eax
    pushl %eax
    leal pilot_3_str,%eax
    pushl %eax
    leal pilot_2_str,%eax
    pushl %eax
    leal pilot_1_str,%eax
    pushl %eax
    leal pilot_0_str,%eax
    pushl %eax
    
    xorl %eax,%eax
    movl (%ebp),%eax

    #calcolo dell'id 
    ciclo:
        movl (%esp),%ebx
        subl $4, %esp
        pushl %eax
        pushl %ebx
        call strcmp
        popl %ebx
        popl %eax
        cmpl $1, (%esp)
        je fine
        addl $8,%esp
        incl %edx
        cmpl $20,%edx
        je fine
        jmp ciclo

#rispristino registri e return
fine:
    movl %ecx,%esp
    movl %edx,4(%ebp) #caricamento id nello stack
    popl %edx
    popl %ecx
    popl %ebx
    popl %eax
    popl %ebp
    ret






