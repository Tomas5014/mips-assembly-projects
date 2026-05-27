# =======================================================================================
# Titulo: Calculo e Soma de Quadrados em Vetor (Traducao de C para MIPS)
# Descricao: Traducao direta de um programa de alto nivel (C) para Assembly MIPS. 
# O algoritmo aloca estaticamente um vetor na memoria, itera para preenche-lo com o 
# quadrado dos seus indices (i*i) e realiza uma segunda iteracao para calcular a soma 
# total dos valores armazenados.
# Analise de Computabilidade: Demonstra o mapeamento de estruturas de controlo de alto 
# nivel (lacos 'for') e manipulacao de ponteiros para instrucoes de baixo nivel. O 
# acesso sequencial a memoria garante uma excelente localidade de referencia espacial, 
# executando em tempo linear O(n). O dominio e validado contra entradas negativas, 
# garantindo a seguranca e a paragem (decidibilidade) do algoritmo.
# Aplicacao: Estudo de engenharia reversa, construcao de compiladores e analise de 
# desempenho no acesso a memoria linear em arquiteturas RISC.
# Referência na documentação: "atividade-mips-03.pdf"
# =======================================================================================

.data
    squares: .space 256                     # Espaco para armazenar 64 inteiros (64 * 4 bytes = 256 bytes)
    msg_entrada: .asciiz "Digite um numero: "  # Mensagem de entrada para o usuario
    msg_saida: .asciiz "A soma dos quadrados eh: "  # Mensagem de saida para o resultado da soma
    msg_erro: .asciiz "O numero deve ser maior ou igual a zero!\nTente novamente.\n "  # Mensagem de erro
.text
main:
    # Imprime a mensagem de entrada
    li $v0, 4                  # Codigo da syscall para imprimir string
    la $a0, msg_entrada         # Carrega o endereco da mensagem de entrada no registrador $a0
    syscall                     # Executa a syscall para imprimir a mensagem

    # Le um numero inteiro do usuario
    li $v0, 5                  # Codigo da syscall para ler inteiro
    syscall                     # Executa a syscall para ler o numero
    move $t0, $v0               # Armazena o numero lido em $t0 (n)

	ble $t0, -1, erro		# se inserir um numero menor que zero pula pra erro 
    li $t1, 0                   # Inicializa o indice i = $t1 = 0
    
loop_storeValues:
    # Calcula o quadrado de i e armazena no array squares
    mult $t1, $t1               # Calcula i * i
    mflo $t2                    # Move o resultado do produto para $t2
    sll $t3, $t1, 2             # Calcula o deslocamento para squares[i] (i * 4)
    la $t4, squares             # Carrega o endereco base do array squares em $t4
    add $t4, $t4, $t3           # Calcula o endereco de squares[i]
    sw $t2, 0($t4)              # Armazena o valor de i^2 em squares[i]
    addi $t1, $t1, 1            # Incrementa o indice i
    blt $t1, $t0, loop_storeValues  # Se i < n, continua o loop

    li $t1, 0                   # Inicializa o indice i = $t1 = 0 para o proximo loop
    li $t5, 0                   # Inicializa sum = $t5 = 0

loop_computeSum:
    # Soma os quadrados armazenados em squares
    sll $t3, $t1, 2             # Calcula o deslocamento para squares[i] (i * 4)
    la $t4, squares             # Carrega o endereco base do array squares
    add $t4, $t4, $t3           # Calcula o endereco de squares[i]
    lw $t6, 0($t4)              # Carrega o valor de squares[i] em $t6
    add $t5, $t5, $t6           # Soma o valor de squares[i] a sum
    addi $t1, $t1, 1            # Incrementa o indice i
    blt $t1, $t0, loop_computeSum  # Se i < n, continua o loop

    # Imprime a mensagem de saida
    li $v0, 4                  # Codigo da syscall para imprimir string
    la $a0, msg_saida           # Carrega o endereco da mensagem de saida no registrador $a0
    syscall                     # Executa a syscall para imprimir a mensagem

    # Imprime o valor de sum
    li $v0, 1                  # Codigo da syscall para imprimir inteiro
    move $a0, $t5              # Move o valor da soma para $a0
    syscall                     # Executa a syscall para imprimir a soma
 	
    j fim_do_programa
erro:
	li $v0, 4                  # Codigo da syscall para imprimir string
    	la $a0, msg_erro           # Carrega o endereco da mensagem de saida no registrador $a0
   	syscall
   	j main
fim_do_programa:
	 # Chamada de sistema para terminar o programa
    	li $v0, 10    # Codigo de servico 10 para "exit"
    	syscall       # Executa a chamada de sistema