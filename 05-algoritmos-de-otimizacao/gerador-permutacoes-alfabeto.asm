# =======================================================================================
# Titulo: Gerador de Permutacoes do Alfabeto
# Descricao: Gera todas as possiveis combinacoes com as n primeiras letras do 
# alfabeto, utilizando um algoritmo estruturado de permutacao posicional.
# Analise de Computabilidade: Este e um classico problema combinatorio. A complexidade 
# de tempo e espaco cresce de forma fatorial O(n!). A decidibilidade e assegurada 
# unicamente porque o alfabeto e um conjunto finito e 'n' e rigidamente limitado. 
# E uma demonstracao clara dos limites de processamento computacional em tempo util.
# Aplicacao: Algoritmos de forca bruta, geracao de dicionarios criptograficos e 
# pesquisa exaustiva em espacos de estados complexos (zero-day detection simulada).
# Referência na documentação: "atividade-mips-08.pdf"
# =======================================================================================

.data
alfabeto: .asciiz "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
vet: .space 26
saida: .asciiz "Permutacao: "
ent: .asciiz "Digite o valor de n:"

.text
main:
	la $s1, vet
	# Pedi o valor de n:
	la $a0, ent
	li $v0, 4
	syscall
	
	# Pega e guarda o valor de n:
	li $v0, 5
	syscall
	move $s0, $v0
	
	# Verifica se n eh valido:
	blt $s0, 1, fim
	bgt $s0, 26, fim
	
	la $a0, alfabeto
	la $a1, vet
	
	jal passa_vet
	
	la $a0, saida
	li $v0, 4
	syscall
	
	li $a1, 0		# i = 0
	jal permutacao
	
	
	
	fim:
	li $v0, 10
	syscall
	
passa_vet:
	li $t0, 0
	loop_passa:
	add $t1, $t0, $a0
	lb $t1, 0($t1)
	add $t2, $t0, $a1
	sb $t1, ($t2)
	addi $t0, $t0, 1
	blt $t0, $s0, loop_passa
	li $t3, 0		# Valor de asci pra '/0'
	add $t2, $t0, $a1
	sb $t3, ($t2)
	jr $ra
	

permutacao:
	# $a1 -> i
	# s0 -> n
	# $s1 -> vet
	addi $sp, $sp, -4
	sw $ra, ($sp)
	bne $a1, $s0, pos_print
		# Imprime vet
		move $a0, $s1
		li $v0, 4
		syscall
		
		#Imprime espaco:
		li $a0, 32		# Codido asci pra espaco(' ')
		li $v0, 11		# Codigo syscall pra imprimir caractere
		syscall
		
		j pos_for
	pos_print:
	move $t0, $a1
	for_troca:
		# Troca vet[i] com vet[j]:
		add $t1, $s1, $a1	# i + &vet
		lb $t2, ($t1)		# $t2 = vet[i]
		add $t3, $s1, $t0	# j + &vet
		lb $t4, ($t3)		# $t4 = vet[j]
		sb $t2, ($t3)		# vet[j] = vet[i]
		sb $t4, ($t1)		# vet[i] = vet[j]
		
		# Cachama a funcao permutacao() recursivamente:
		addi $sp, $sp, -4	# Aloca memoria na pilha
		sw $t0, ($sp)		# Salva j na pilha
		addi $a1, $a1, 1	# i++
		jal permutacao		# permutacao(vet, i+1, n)
		subi $a1 $a1, 1		# i--
		lw $t0, ($sp)		# Recupera o j da pilha
		addi $sp, $sp, 4	# Desaloca memoria da pilha
		
		# Destroca vet[i] com vet[j]:
		add $t1, $s1, $a1	# i + &vet
		lb $t2, ($t1)		# $t2 = vet[i]
		add $t3, $s1, $t0	# j + &vet
		lb $t4, ($t3)		# $t4 = vet[j]
		sb $t2, ($t3)		# vet[j] = vet[i]
		sb $t4, ($t1)		# vet[i] = vet[j]
		
		addi $t0, $t0, 1
		blt $t0, $s0, for_troca
	pos_for:
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
