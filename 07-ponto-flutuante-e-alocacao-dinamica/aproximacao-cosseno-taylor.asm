# =======================================================================================
# Titulo: Aproximacao Polinomial de Cosseno (Serie de Taylor)
# Descricao: Calcula uma aproximacao para a funcao cos(x) utilizando a soma iterativa 
# dos 'n' primeiros termos da Serie de Taylor, operando nativamente com valores float.
# Analise de Computabilidade: Funcoes transcendentais sao, por definicao, incomputaveis 
# de forma exata em tempo finito. O algoritmo torna o problema decidivel e resolvivel 
# ao truncar a serie infinita num limite natural 'n', transformando-o num processamento 
# polinomial deterministico com paragem garantida.
# Aplicacao: Implementacao de baixo nivel para funcoes de ativacao em redes neuronais 
# e modelacao matematica de tensores em ambientes de alto desempenho e precisao.
# Referência na documentação: "atividade-mips-09.pdf"
# =======================================================================================

.data
ent1:         .asciiz "Digite o valor de x (real): "
ent2:         .asciiz "Digite o valor de n (natural): "
saida:        .asciiz "Aproximacao de cos(x): "
newline:      .asciiz "\n"

.text
main:
    # Entrada de x
    li $v0, 4
    la $a0, ent1
    syscall

    li $v0, 6
    syscall
    mov.s $f20, $f0  # x armazenado em $f20

    # Entrada de n
    li $v0, 4
    la $a0, ent2
    syscall

    li $v0, 5
    syscall
    move $s0, $v0  # n armazenado em $s0

    # Chamada para cosseno
    mov.s $f12, $f20  # Passa x como parametro
    move $a1, $s0     # Passa n como parametro
    jal cosseno

    # Exibe resultado
    li $v0, 4
    la $a0, saida
    syscall

    li $v0, 2
    mov.s $f12, $f0
    syscall

    # Finaliza o programa
    li $v0, 10
    syscall

cosseno:
    li $t0, 1         # Inicializa i = 1
    mtc1 $t0, $f0     # f0 = 1.0
    cvt.s.w $f0, $f0
    bnez $a1, pula_cosseno
    jr $ra            # Retorna soma = 1.0 se n = 0

pula_cosseno:
    li $t0, 1         # i = 1
    li $t1, 1
    mtc1 $t1, $f4
    cvt.s.w $f4, $f4  # f4 = soma inicial (1.0)

loop_cosseno:
    # Calcula 2*i
    mul $t1, $t0, 2    # t1 = 2*i

    # Calcula x^(2*i)
    li $t2, 0          # j = 0
    mov.s $f6, $f0     # f6 = 1.0
loop_exponencial:
    mul.s $f6, $f6, $f12
    addi $t2, $t2, 1
    blt $t2, $t1, loop_exponencial

    # Calcula (2*i)!
    li $t2, 1          # j = 1
    mov.s $f8, $f0     # f8 = 1.0
loop_fatorial:
    mtc1 $t2, $f10
    cvt.s.w $f10, $f10
    mul.s $f8, $f8, $f10
    addi $t2, $t2, 1
    ble $t2, $t1, loop_fatorial

    # Calcula (-1)^i
    rem $t5, $t0, 2
    beqz $t5, par
    li $t4, -1
    j continua
par:
    li $t4, 1
continua:
    mtc1 $t4, $f10
    cvt.s.w $f10, $f10

    # Calcula termo
    mul.s $f6, $f6, $f10
    div.s $f10, $f6, $f8
    add.s $f4, $f4, $f10

    # Incrementa i
    addi $t0, $t0, 1
    blt $t0, $a1, loop_cosseno

    mov.s $f0, $f4
    jr $ra
