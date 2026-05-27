# =======================================================================================
# Titulo: Analise de Frequencia e Distribuicao de Reais (Alocacao Dinamica)
# Descricao: Aloca memoria dinamicamente para um vetor de tamanho 'n' e avalia um fluxo 
# de numeros em virgula flutuante (Coprocessador 1), contabilizando o numero de 
# ocorrencias individuais de cada elemento.
# Analise de Computabilidade: O algoritmo lida com alocacao em tempo de execucao (heap).
# A decidibilidade da contagem e garantida por lacos finitos que avaliam o estado da
# memoria ate ao limite 'n'. O tempo de execucao no pior cenario e O(n^2) devido as 
# verificacoes de redundancia para evitar reprocessamento de elementos ja contabilizados.
# Aplicacao: Processamento primario em data stream mining, criacao de histogramas e 
# deteccao de anomalias (analise de picos de frequencia em trafego de rede).
# Referência na documentação: "atividade-mips-09.pdf"
# =======================================================================================

.data
ent1: .asciiz "Digite o tamanho da sequencia (n): "
ent2: .asciiz "Insira o valor de vet["
ent3: .asciiz "]: "
espaco: .asciiz " "
quebra_linha: .asciiz "\n"
saida_ocorre: .asciiz " ocorre "
saida_vezes: .asciiz " vezes\n"

.text
	# Imprime a mensagem e la o valor de n:
	li $v0, 4
	la $a0, ent1
	syscall
	
	li $v0, 5
	syscall
	move $s1, $v0
	
	li $t0, 4		# tamanho de um float
	mul $a0, $s1, $t0
	li $v0, 9		# syscall pra alocacao dinamica
	syscall
	move $s0, $v0		# Salva o endereco do vetor em $s0
	
	mul $a0, $s1, $t0
	li $v0, 9		# syscall pra alocacao dinamica
	syscall
	move $s2, $v0		# Salva o endereco do vetor em $s2
	
	move $a0, $s0		# passa o endereco do vetor como parametro
	move $a1, $s1		# Passa o tamanho n do veotr como parametro
	jal leitura
	
	move $a0, $s0		# passa o endereco do vetor como parametro
	move $a1, $s1		# Passa o tamanho n do veotr como parametro
	jal escrita
	
	la $a0, quebra_linha
	li $v0, 4
	syscall
	
	move $a0, $s0		# passa o endereco do vetor como parametro
	move $a1, $s1		# Passa o tamanho n do veotr como parametro
	move $a3, $s2		# passa o segundo vetor como parametro
	jal contagem
	
	li $v0, 10
	syscall
	
leitura:
	move $a3, $a0		# $a3 -> &vet
	# $a1 -> n
	li $t0, 0
	loop_leitura:
	# Printa a frase pedindo pra inserir o valor:
	la $a0, ent2
	li $v0, 4
	syscall
	
	move $a0, $t0
	li $v0, 1
	syscall
	
	la $a0, ent3
	li $v0, 4
	syscall
	
	li $v0, 6
	syscall
	mov.s $f2, $f0
	
	sll $t1, $t0, 2
	add $t2, $a3, $t1
	
	swc1 $f2, ($t2)
	
	addi $t0, $t0, 1
	blt $t0, $a1, loop_leitura
	
	jr $ra
	
escrita:
	move $a3, $a0		# $a3 -> &vet
				# $a1 -> n
	li $t0, 0
	loop_escrita:
	sll $t1, $t0, 2
	add $t2, $a3, $t1
	# carrega o valor real pra $f12
	lwc1 $f12, ($t2)
	
	la $a0, espaco
	li $v0, 4
	syscall
	# Syscall pra imprimir o float no registrador $f12
	li $v0, 2
	syscall
	
	addi $t0, $t0,1 
	blt $t0, $a1, loop_escrita
	jr $ra			
							
contagem:
	move $t7, $a0		# $t7 -> &vet1
				# $a1 -> n
				# $a3 -> &vet2								
	li $t0, 0		# i
	li $t6, 0		# k
	# Loop pra percorrer todo o vetor principal:
	loop_contagem:
	sll $t1, $t0, 2
	add $t1, $t1, $t7
	lwc1 $f2, ($t1)		# vet[i]
	beqz $t6, fim_verificacao_contagem
	li $t2, 0		# j
	# Verifica se o valor ja esta no vetor secudario. Se ja estiver, ele ja foi analizado antes:
	verificacao_contagem:
	sll $t3, $t2, 2
	add $t3, $t3, $a3
	lwc1 $f4, ($t3)
	c.eq.s $f2, $f4
	bc1t fim_loop_contagem
	addi $t2, $t2, 1
	blt $t2, $t6, verificacao_contagem	
	fim_verificacao_contagem:
	# Adiciona o valor no vetor secundario e incrementa o tamanho do vetor secundario k:
	sll $t3, $t6, 2
	add $t3, $t3, $a3
	swc1 $f2, ($t3)
	addi $t6, $t6, 1	# k++
	# Percorre o resto do vetor principal e conta quantas vezes o valor aparece:
	li $t3, 0		# cont
	move $t4, $t0		# j
	loop_contador_contagem:
	sll $t5, $t4, 2
	add $t5, $t7, $t5
	lwc1 $f6, ($t5)
	c.eq.s $f6, $f2
	bc1f fim_contador_contagem
	addi $t3, $t3, 1	
	fim_contador_contagem:
	addi $t4, $t4, 1
	blt $t4, $a1, loop_contador_contagem
	
	mov.s $f12, $f2
	li $v0, 2
	syscall
	
	la $a0, saida_ocorre
	li $v0, 4
	syscall
	
	move $a0, $t3
	li $v0, 1
	syscall
	
	la $a0, saida_vezes
	li $v0, 4
	syscall	
	fim_loop_contagem:					
	addi $t0, $t0, 1
	blt $t0, $a1, loop_contagem
	jr $ra
