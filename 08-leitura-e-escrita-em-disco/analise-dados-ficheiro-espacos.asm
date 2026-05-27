# =======================================================================================
# Titulo: Analise Estatistica e Ordenacao de Dados em Ficheiro (Espaco)
# Descricao: Abertura e leitura de um ficheiro de texto (I/O em disco) contendo inteiros 
# separados por espaco. O algoritmo extrai metricas (minimo, maximo, pares, impares, 
# soma, produto) e aplica ordenacao em memoria (Bubble Sort).
# Analise de Computabilidade: A interacao com o sistema de ficheiros introduz o 
# conceito de fita de entrada externa, caracteristica de Maquinas de Turing com 
# oraculos de leitura. A conversao de carateres ASCII para inteiros opera atraves 
# de um automato finito deterministico (AFD) que reconhece o separador logico. O 
# tempo de processamento final e dominado pela ordenacao polinomial O(n^2), garantindo 
# a paragem dado que a fita de leitura possui um fim estritamente definido (EOF).
# Aplicacao: Leitura de datasets e ficheiros de log em sistemas de deteccao de 
# intrusao (IDS) e pre-processamento estatico para mineracao de dados (stream mining).
# Referência na documentação: "atividade-mips-10.pdf"
# =======================================================================================

.data
nomeArquivo: .asciiz "dados1.txt"
buffer: .space 4
erro: .asciiz "Nao foi possivel abrir o arquivo!\nO arquivo deve estar no mesmo diretorio que o simulador MARS.\n"
saida_num_car: .asciiz "\nO numero de caracteres do arquivo eh: "
quebra_linha: .asciiz "\n"
espaco: .asciiz " "
maior_valor: .asciiz "\nO MAIOR valor do arquivo eh: "
menor_valor: .asciiz "\nO MENOR valor do arquivo eh: "
par: .asciiz "\nA quantidade de numero pares eh: "
impar: .asciiz "\nA quantidade de numeros impares eh: "
soma: .asciiz "\nA soma do numero do arquivo eh: "
produto: .asciiz "\nO produto dos numero do arquivo eh: "
crescente: .asciiz "\nNumeros do arquivo em ordem crescente: "
decrescente: .asciiz "\nNumeros do arquivo em ordem decrescente: "
.align 2
vetor: .space 400

.text
main:
	# --------------------------------------------------------- #
	
	# Abertura do arquivo:
	la $a0, nomeArquivo	# Passo o nome do arquivo como parametro pro syscall
	li $a1, 0		# Modo de de apenas leitura
	jal abrir_arquivo
	move $s0, $v0		# Guarda o descritor do arquivo em $s0
	
	# --------------------------------------------------------- #
	# Transportar numeros para um vetor:
	move $a0, $s0		# Passo o descritor do arquivo como parametro
	la $a1, buffer		# Passo o buffer do arquivo como parametro
	li $a2, 1		# Parametro: caracteres por leitura
	la $a3, vetor		# Passo endereco do vetor como parametro
	jal transporte_vetor	# Retorna o endereco do vetor em $v0 e o numero tamanho do vetor em $v1
	move $s1, $v0
	move $s2, $v1
	
	#### TESTE:
	li $t0, 0
	loop_printar_vetor:
	sll $t1, $t0, 2
	add $t1, $t1, $s1
	lw $a0, ($t1)
	li $v0, 1
	syscall
	la $a0, espaco
	li $v0, 4
	syscall
	addi $t0, $t0, 1
	blt $t0, $s2, loop_printar_vetor

	# --------------------------------------------------------- #
	# Identifica maior e menor:
	move $a0, $s1		# Passa o vetor como parametro.
	move $a1, $s2		# Passa o tamanho n do vetor como parametro.
	jal maior_menor		# Retorna em $v0 o maior valor do vetor e em $v1 o menor valor.
	move $t0, $v0
	move $t1, $v1
	# Impressao do maior e do menor valor:
	la $a0, maior_valor
	li $v0, 4
	syscall
	li $v0, 1
	move $a0, $t0	
	syscall
	la $a0, menor_valor
	li $v0, 4
	syscall
	li $v0, 1
	move $a0, $t1	
	syscall
	
	# --------------------------------------------------------- #
	# Pares, impares, soma e produto:
	move $a0, $s1		# Passa o vetor como parametro.
	move $a1, $s2		# Passa o tamanho n do vetor como parametro.
	jal funcao_pisp		# Funcao sem retorno. O print acontece dentro da funcao
	
	# --------------------------------------------------------- #
	#Ordena vetor:
	move $a0, $s1		# Passa o vetor como parametro.
	move $a1, $s2		# Passa o tamanho n do vetor como parametro.
	jal bubble_sort		
	
	li $v0, 4
	la $a0, crescente
	syscall
	
	#### TESTE:
	li $t0, 0
	loop_printar_vetor2:
	sll $t1, $t0, 2
	add $t1, $t1, $s1
	lw $a0, ($t1)
	li $v0, 1
	syscall
	la $a0, espaco
	li $v0, 4
	syscall
	addi $t0, $t0, 1
	blt $t0, $s2, loop_printar_vetor2

	move $a0, $s1		# Passa o vetor como parametro.
	move $a1, $s2		# Passa o tamanho n do vetor como parametro.
	jal bubble_sort2		
	
	li $v0, 4
	la $a0, decrescente
	syscall
	
	#### TESTE:
	li $t0, 0
	loop_printar_vetor3:
	sll $t1, $t0, 2
	add $t1, $t1, $s1
	lw $a0, ($t1)
	li $v0, 1
	syscall
	la $a0, espaco
	li $v0, 4
	syscall
	addi $t0, $t0, 1
	blt $t0, $s2, loop_printar_vetor3	
	# --------------------------------------------------------- #
	
	#Fechar o arquivo:
	li $v0, 16
	move $a0, $s0
	syscall
	
	# Abertura do arquivo:
	la $a0, nomeArquivo	# Passo o nome do arquivo como parametro pro syscall
	li $a1, 0		# Modo de de apenas leitura
	jal abrir_arquivo
	move $s0, $v0		# Guarda o descritor do arquivo em $s0
	
	# --------------------------------------------------------- #
	
	# Contagem de caracteres:
	move $a0, $s0			# Parametro file descriptor
	la $a1, buffer			# Buffer de entrada
	li $a2, 1			# Caracteres por leitura
	jal contagem_de_caracteres	# Retorna em $v0 o numero de caracteres
	move $s7, $v0			# Move o numero de caracteres para $s7
	
	# Impressao da contagem:
	la $a0, saida_num_car
	li $v0, 4
	syscall
	
	li $v0, 1
	move $a0, $s7
	syscall
	
	la $a0, quebra_linha
	li $v0, 4
	syscall
	
	# --------------------------------------------------------- #

	#Fechar o arquivo:
	li $v0, 16
	move $a0, $s0
	syscall
	
	# Encerrar o programa:
	li $v0, 10
	syscall
	
abrir_arquivo:
	# $a0 -> nome do arquivo
	# $a1 -> tipo de abertura (leitura, escrita, leitura e escrita)
	# retorno: $v0 se conseguir abrir, se nao encerra o programa
	li $v0, 13		# Syscall para ler arquivo
	syscall
	bgez $v0, retornar_abrir
	
	# Printa a mensagem de erro
	la $a0, erro
	li $v0, 4
	syscall
	
	# Encerra o programa:
	li $v0, 10
	syscall
	
	retornar_abrir:	jr $ra
	
contagem_de_caracteres:
	li $t0, 0		# $t0 -> n
	loop_contagem:
	li $v0, 14		# Codigo para leitura de arquivo
	syscall			# Faz a leitura de uma caractere
	addi $t0, $t0, 1	# n++
	bnez $v0, loop_contagem
	addi $t0, $t0, -1	# Desconsidera a contagem do EOF
	move $v0, $t0
	jr $ra
	
transporte_vetor:
	# $a0 -> descritor do arquivo
	# $a1 -> buffer
	# $a2 -> caracteres por leitura: 1
	# $a3 -> vetor
	li $t2, 0		# indice i do vetor
	li $t1, 0
	
	loop_transporte:
	li $v0, 14		# Codigo para leitura
	syscall			# Faz a leitura de 1 caractere
	beqz $v0, fim_numero
	lbu $t0, ($a1)		# Carrega o byte lido do buffer
	beq $t0, 13, loop_transporte	# se for carrige return, ignora
	beq $t0, 32, fim_numero		# Se for espaco
	beq $t0, 45, negativo		# Se for -
	subi $t0, $t0, 48	# Tabela ascii para transformar em decimal
	mul $t1, $t1, 10	# Casa decimal para esquerda
	add $t1, $t1, $t0	# Adicino o numero na casa decimal da direita
	j loop_transporte
		
	fim_numero:
	# Guardar o numero no vetor
	sll $t3, $t2, 2
	add $t3, $t3, $a3
	# Se for negativo:
	bne $t7, 1, pula_negativo
	mul $t1, $t1, -1
	pula_negativo:
	sw $t1, ($t3)	
	li $t1, 0		# Zera o $t1 para guardar o proximo numero
	addi $t2, $t2, 1
	li $t7, 0
	beqz $v0, fim_transporte
	j loop_transporte
	
	negativo:
	li $t7, 1		# flag para negativo
	j loop_transporte
	
	fim_transporte:
	move $v0, $a3
	move $v1, $t2
	jr $ra
	
maior_menor:
	# $a0 -> vetor
	# $a1 -> tamanho n do vetor
	lw $t6, ($a0)		# maior recebe vet[0]
	lw $t7, ($a0)		# menor recebe vet[0]
	li $t0, 0		# indice i = 0
	loop_maior_menor: 
	sll $t1, $t0, 2
	add $t1, $t1, $a0
	lw $t1, ($t1)
	bge $t7, $t1, maior_funcao
	move $t7, $t1	
	maior_funcao:  
	ble $t6, $t1, pula_maior_funcao
	move $t6, $t1
	pula_maior_funcao:
	addi $t0, $t0, 1
	blt $t0, $a1, loop_maior_menor
	move $v0, $t7
	move $v1, $t6
	jr $ra
	
funcao_pisp:
	# $a0 -> vetor
	# $a1 -> tamanho n do vetor
	# $t0 -> indice i
	# $t1 -> pares
	# $t2 -> impares
	# $t3 -> soma 
	# $t4 -> produto
	li $t0, 0
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $t4, 1
	loop_pisp:
	sll $t5, $t0, 2
	add $t5, $a0, $t5
	lw $t5, ($t5)
	add $t3, $t3, $t5
	mul $t4, $t4, $t5
	li $t6, 2
	div $t5, $t6
	mfhi $t6
	beqz $t6, ehpar
	addi $t2, $t2, 1
	pula_impar:
	addi $t0, $t0, 1
	blt $t0, $a1, loop_pisp
	
	# Prints:
	li $v0, 4
	la $a0, par
	syscall
	li $v0, 1
	move $a0, $t1
	syscall
	
	li $v0, 4
	la $a0, impar
	syscall
	li $v0, 1
	move $a0, $t2
	syscall
	
	li $v0, 4
	la $a0, soma
	syscall
	li $v0, 1
	move $a0, $t3
	syscall
	
	li $v0, 4
	la $a0, produto
	syscall
	li $v0, 1
	move $a0, $t4
	syscall
	
	jr $ra		# Return
	
	ehpar:
	addi $t1, $t1, 1
	j pula_impar

bubble_sort:
	# t0: ponteiro pro vetor;
	# t1: tamanho do contador
	# t2: contador 1
	# t3: contador 2
		
	move $t0, $a0 #endereco do vetor eh guardado em $t0
	move $t1, $a1 # Tamanho do vetor eh guardado em $t1
	li $t2, 0	# Inicia o contador 1 com zero
	sub $t7, $t1, 1
loop_bubble_externo:
	beq $t2, $t1 fim_bubble
	li $t3, 0	
	loop_bubble_interno:
		sll $t4, $t3, 2 # Desloca o indice duas casas pra esquerda (multiplica por quatro) e guarda em $t4
		addi $t5, $t3, 1
		sll $t5, $t5, 2	# Desloca o indice + 1 duas casas pra esquerda (multiplica por quatro) e guarda em $t5
		add $t4, $t4, $t0	# Guarda o enderoco do de vet[i]
		add $t5, $t5, $t0	# Guarda o enderoco do de vet[i+1]
		
		lw $a0, 0($t4)
		lw $a1, 0($t5)
		
		slt $t6, $a1, $a0  # $t6 = ($t5 < $t4) ? 1 : 0
		
		beq $t6, $zero sem_swap
		swap:
			sw $a0, 0($t5)
			sw $a1, 0($t4) 
		sem_swap:
		
		addi $t3, $t3, 1
		bne $t3, $t7 loop_bubble_interno
	# Fim do loop intero
	addi $t2, $t2, 1
	j loop_bubble_externo
fim_bubble:
	jr $ra

bubble_sort2:
	# t0: ponteiro pro vetor;
	# t1: tamanho do contador
	# t2: contador 1
	# t3: contador 2
		
	move $t0, $a0 #endereco do vetor eh guardado em $t0
	move $t1, $a1 # Tamanho do vetor eh guardado em $t1
	li $t2, 0	# Inicia o contador 1 com zero
	sub $t7, $t1, 1
loop_bubble_externo2:
	beq $t2, $t1 fim_bubble2
	li $t3, 0	
	loop_bubble_interno2:
		sll $t4, $t3, 2 # Desloca o indice duas casas pra esquerda (multiplica por quatro) e guarda em $t4
		addi $t5, $t3, 1
		sll $t5, $t5, 2	# Desloca o indice + 1 duas casas pra esquerda (multiplica por quatro) e guarda em $t5
		add $t4, $t4, $t0	# Guarda o enderoco do de vet[i]
		add $t5, $t5, $t0	# Guarda o enderoco do de vet[i+1]
		
		lw $a1, 0($t4)
		lw $a0, 0($t5)
		
		slt $t6, $a1, $a0  # $t6 = ($t5 < $t4) ? 1 : 0
		
		beq $t6, $zero sem_swap2
		swap2:
			sw $a1, 0($t5)
			sw $a0, 0($t4) 
		sem_swap2:
		
		addi $t3, $t3, 1
		bne $t3, $t7 loop_bubble_interno2
	# Fim do loop intero
	addi $t2, $t2, 1
	j loop_bubble_externo2
fim_bubble2:
	jr $ra	
	
	