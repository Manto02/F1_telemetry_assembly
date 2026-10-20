# per convertire i caratteri in numero si utilizza la formula ricorsiva
#
# 10*( 10*( 10*d + d ) + d ) + d
#             N-1 N-2   N-3   N-4
#


.section .text
  .global str2num
  .type str2num, @function

str2num:

  pushl %ebp
  movl %esp,%ebp
  addl $8,%ebp #recuperiamo eax dallo stack (parametro input_value)


  pushl %eax
  pushl %ebx
  pushl %ecx
  pushl %edx
  pushl %esi

  xorl %ecx,%ecx            # azzero il contatore
  xorl %ebx,%ebx            # azzero il registro EBX
  xorl %eax,%eax

  movl (%ebp),%esi        #mettiamo la stringa recuperata dallo stack in esi
ripeti:

  # movb (%esi), %al
  movb (%ecx,%esi), %bl

  cmpb $10, %bl             # vedo se e' stato letto il carattere '\n'
  je fine
  cmpb $44,%bl
  je fine

  subb $48, %bl            # converte il codice ASCII della cifra nel numero corrisp.
  movl $10, %edx
  mull %edx                # EBX = EBX * 10
  addl %ebx, %eax

  inc %ecx
  jmp ripeti


fine:

  movl %eax,4(%ebp)
  popl %esi
  popl %edx
  popl %ecx
  popl %ebx
  popl %eax
  popl %ebp
  ret

