# =======================================================================================
# Titulo: Subsequencia Contigua de Soma Maxima
# Descricao: Determina o segmento de nota maxima num vetor alocado dinamicamente.
# Analise de Computabilidade: O algoritmo avalia sub-vetores dentro de um espaco de 
# estados finito. Trata-se de um problema de otimizacao decidivel. A sua execucao 
# ocorre em tempo polinomial, garantindo a paragem e evitando ciclos infinitos na 
# avaliacao de maximos locais e globais.
# Aplicacao: Deteccao de anomalias temporais e picos de trafego em stream mining e 
# analise de comportamento em sistemas de deteccao de intrusoes (IDS).
# Exemplo: na sequência 5, 2, -2, -7, 3, 14, -3, 9, -6, 4, 1, a soma do maior segmento 
# é 23, obtida pela soma dos números de 3 até 9.
# Referência na documentação: "atividade-mips-08.pdf"
# =======================================================================================

.data
vet: .space 256			# 64 x 4 (inteiro)
ent1: .asciiz "Insira o tamanho n do vetor: "
ent2: .asciiz "Insira o valor de vet["
ent3: .asciiz "]: "
saida: .asciiz "\nO seguimento de nota maxima eh: "

.text
	la $s0, vet		# $s0 -> &vet[0]
	
	# Imprime a frase pedindo o tamanho do vetor:
	la $a0, ent1
	li $v0, 4
	syscall
	
	# Syscall pra ler inteiro (n):
	li $v0, 5
	syscall
	move $s1, $v0		# $s1 -> n
	
	move $a0, $s0		# Manda o endereco do vetor como parametro
	move $a1, $s1		# Manda o tamanho n do vetor como parametro
	jal leitura
	
	move $a0, $s0
	move $a1, $s1
	jal escrita
	
	jal seguimento
	move $s2, $v0
	
	la $a0, saida
	li $v0, 4
	syscall
	
	move $a0, $s2
	li $v0, 1
	syscall
		
	li $v0, 10
	syscall
	
	
	
	
	
	
leitura:
	# $a0 -> $vet, $a1 -> n
	move $a3, $a0		# Endereco do vetor
	li $t0, 0		# $t0 -> i
	
l:
	# Os proximos 3 syscall's imprimem a mensagem pedindo o elemento vet[i]
	la $a0,	ent2
	li $v0, 4
	syscall	
	
	move $a0, $t0
	li $v0, 1
	syscall
	
	la $a0, ent3
	li $v0, 4
	syscall
	
	# Ler inteiro:
	li $v0, 5
	syscall
	move $t2, $v0		# $t2 -> vet[i]
	
	# Os proximos passos vao pegar o endereco de vet[i]:
	sll $t3, $t0, 2		# $t3 = i * 4
	add $t3, $t3, $a3	# $t3 -> &vet[i]
	
	# Guarda o valor no vetor:
	sw $t2, ($t3)
	
	# Verificacao do loop:
	addi $t0, $t0, 1	# i++
	blt $t0, $a1, l		# if (i < n) goto l
	
	# Fim do loop:
	li $t0, 0
	move $v0, $a3
	jr $ra
	
	
escrita:
	move $a3, $a0
	li $t0, 0
	
e:
	li $a0, 32		# ascii pra impressao de espaco
	li $v0, 11		# codigo pra impressao de caractere
	syscall
	
	sll $t1, $t0, 2
	add $t1, $t1, $a3
	
	lw $a0 ($t1)
	li $v0, 1
	syscall
	
	addi $t0, $t0, 1
	blt $t0, $a1 e
	 
	jr $ra
	
seguimento:
				# $s0 -> $&vet[]
				# $s1 -> n	;	tamanho do vetor
	li $t0, 1		# $t0 -> i
	lw $t1, ($s0)		# $t1 -> soma;
				# $t2 -> j;
				# $t3 -> k;
				# $t4 -> sum;
				# $t5 -> x;
	
	s1:		# while( i < n){
	li $t2, 0		# j = 0;
	
		s2:		# while((j + k) < n){
		li $t3, 0
		li $t4, 0	# sum = 0;
		
			s3:		# while(k < i){
			add $t5, $t2, $t3	# x = j + k;
			sll $t5, $t5, 2
			add $t5, $s0, $t5
			lw $t5, ($t5)		# x= vet[x]
			add $t4, $t4, $t5	# sum += x
			addi $t3, $t3, 1	# k++
			
			ble $t3, $t0, s3
		# if(sum < soma) soma = sum
		ble $t4, $t1 spulo
		move $t1, $t4
		spulo:
		addi $t2, $t2, 1	# j++
		
		add $t6, $t0, $t2	# j + i
		blt $t6, $s1, s2
	
	addi $t0, $t0, 1
	blt $t0, $s1 s1
	
	# fim dos whiles
	move $v0, $t1		# Retorna soma.;
	jr $ra
	
	
