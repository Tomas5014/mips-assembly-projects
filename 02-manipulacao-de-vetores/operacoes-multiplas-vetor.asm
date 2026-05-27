# =======================================================================================
# Titulo: Operacoes Multiplas e Analise de Vetor
# Descricao: Le um vetor de n elementos e aplica diversas operacoes atraves de chamadas 
# de procedimentos (sub-rotinas): ordenacao, soma de pares, filtragem por chaves, 
# e calculos envolvendo numeros perfeitos e semiprimos.
# Analise de Computabilidade: O programa divide o problema principal em modulos 
# (procedimentos), simulando chamadas de funcoes com isolamento de contexto. A ordenacao 
# e as filtragens ocorrem em tempo polinomial. O uso de procedimentos estruturados 
# facilita a prova de correcao e a manutencao do codigo, propriedades essenciais em 
# engenharia de software e processamento em lote.
# Aplicacao: Modelacao de pipelines de pre-processamento de dados e extracao de 
# caracteristicas estatisticas em ambientes de baixo nivel.
# Referência na documentação: "atividade-mips-04.pdf"
# =======================================================================================

.data
tam_vet: .asciiz "Insira o tamanho do vetor: "
ins_vet: .asciiz "Insira o valor de Vet["
ins_vet2: .asciiz "]: "
espaco: .asciiz " "
quebra_linha: .asciiz "\n"
imprimir_vetor_ordenado: .asciiz "Vetor ordenado: "
saida_soma_pares: .asciiz "Soma dos valores pares: "
entrada_c: .asciiz "Insira uma chave k: "
saida_c: .asciiz "O numero de elementos no vetor maiores que k e menore do que k*2, sao: "
entrada_d: .asciiz "Insira uma chave j: "
saida_d: .asciiz "O numero de vezes que a chave j se repete no vetor eh: "
saida_e: .asciiz "A soma dos numeros inteiros perfeitos menos a soma dos numeros inteiros semiprimos eh: "
msg_tamanho_invalido: .asciiz "ERRO! O tamanho do vetor deve ser maior que 1\nTente novamente.\n"
.align 2
vet: .space 256

.text

main:	
	# Ponteiro para o vetor guardado em $s0
	la $s0, vet
	jal leitura
	
	li $v0, 4
	la $a0, quebra_linha
	syscall
	
	move $a0, $s0	# Passa o ponteiro pro vetor como parametro
	move $a1, $s1	# Passa o tamanho do vetor como parametro
	jal bubble_sort
	
	li $v0, 4
	la $a0, imprimir_vetor_ordenado
	syscall
	
	move $a0, $s0	# Passa o ponteiro pro vetor como parametro
	move $a1, $s1	# Passa o tamanho do vetor como parametro
	jal imprimir_vetor
	
	li $v0, 4
	la $a0, quebra_linha
	syscall
	
	move $a0, $s0	# Passa o ponteiro pro vetor como parametro
	move $a1, $s1	# Passa o tamanho do vetor como parametro
	jal soma_pares_vetor	#chama a funcao. O retorno tem que vir em $v0.
	
	move $s2, $v0 # guarda a soma dos pares em $s2
	
	li $v0, 4
	la $a0, saida_soma_pares
	syscall
	
	li $v0, 1
	move $a0, $s2
	syscall
	
	li $v0, 4
	la $a0, quebra_linha
	syscall
	
	move $a0, $s0	# Passa o ponteiro pro vetor como parametro
	move $a1, $s1	# Passa o tamanho do vetor como parametro
	jal letra_c
	
	move $t1, $v0	# O retorno (contador de elementos iguais a chave vai pra $t1
	
	li $v0, 4
	la $a0, saida_c
	syscall
	
	li $v0, 1
	move $a0, $t1
	syscall
	
	li $v0, 4
	la $a0, quebra_linha
	syscall
	
	li $v0, 4
	la $a0, entrada_d
	syscall
	
	li $v0, 5
	syscall
	move $a2, $v0
	
	move $a0, $s0
	move $a1, $s1
	
	jal questao_d
	
	move $t0, $v0
	
	li $v0, 4
	la $a0, saida_d
	syscall
	
	move $a0, $t0
	li $v0, 1
	syscall
	
	li $v0, 4
	la $a0, quebra_linha
	syscall
	
	move $a0, $s0
	move $a1, $s1
	jal soma_numeros_perfeitos
	move $s4, $v0	# $s4: soma dos numeros perfeitos
	
	jal soma_semiprimos
	move $s5, $v0	# $s5: soma dos numeros semiprimos
	
	sub $t6, $s4, $s5
	
	li $v0, 4
	la $a0, saida_e
	syscall
	
	li $v0, 1
	move $a0, $t6
	syscall
	
	j fim_programa
########################################################################################
leitura:
	# Imprime a frase pedindo o tamanho do vetor:
	li $v0, 4
	la $a0, tam_vet
	syscall
	# Syscall pra pegar um inteiro (tamanho do vetor), guarda em $s1
	li $v0, 5
	syscall
	move $s1, $v0
	
	ble $s1, 1, tamanho_invalido
	
	li $t0, 0 # inicia contador
	
loop_leitura:
	# O loop acaba quando o contador for igual ao tamanho
	beq $t0, $s1 fim_loop_leitura
	# Os proximos tres syscall imprimem a frase pedindo o inteiro Vet[i]: 
	li $v0, 4
	la $a0, ins_vet
	syscall
	
	li $v0, 1
	move $a0, $t0
	syscall
	
	li $v0, 4
	la $a0, ins_vet2
	syscall
	
	li $v0, 5	#le inteiro
	syscall
	move $t1, $v0
	# Desloca o contado duas casas pra esquerda(Multiplica por 4)
	sll $t2, $t0, 2
	# Ponteiro para a posicao do vetor
	add $t4, $t2, $s0
	# Guarda na posicao
	sw $t1, 0($t4)
	
	# Incrementa 1 no contador
	addi $t0, $t0, 1	
	j loop_leitura
	
fim_loop_leitura:
	# Volta pra main
	jr $ra
	
tamanho_invalido:
	li $v0, 4
	la $a0, msg_tamanho_invalido
	syscall
	
	j leitura

########################################################################################
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
########################################################################################
imprimir_vetor:
	move $t0, $a0 # $t0 eh igual ao ponteiro do vetor
	move $t1, $a1 # $t1 eh igual ao tamanho do vetor
	
	li $t3, 0 # Inicia o contador com valor zero
	
loop_impressao:
	beq $t3, $t1 fim_impressao
	
	sll $t4, $t3, 2	# Desloca o indice duas casas pra esquerda (multiplica por quatro) e guarda em $t4
	
	add $t4, $t4, $t0
	
	lw $t5, 0($t4)
	
	li $v0, 1
	move $a0, $t5
	syscall
	
	li $v0, 4
	la $a0, espaco
	syscall
	
	addi $t3, $t3, 1
	j loop_impressao
fim_impressao:
	li $v0, 4
	la $a0, quebra_linha
	syscall
	
	jr $ra	
	
########################################################################################
soma_pares_vetor:
	# $t0: ponteiro pro vetor
	# $t1: tamanho do vetor
	# $t2: soma dos elementos (sum)
	# $t3: contador (indice do vetor)
	# $t5: vet[i]
	
	move $t0, $a0
	move $t1, $a1
	li $t2, 0
	li $t3, 0
	loop_soma_pares:
		sll $t4, $t3, 2	# Desloca o indice duas casas pra esquerda (multiplica por quatro) e guarda em $t4
		add $t4, $t4, $t0	# Soma o indice com o endereco base do vetor. Guarda o endereco de vet[i] em $t4
		lw $t5, 0($t4)	#guarda o valor de vet[i] em $t5
		li $t6, 2	# $t6 = 2
		div $t5, $t6	# divide vet[i] por dois. O resto vai pra HI
		mfhi $t6	# move o resto pra $t6
		bnez $t6, pos_par # Se nao for par pula pra depois de somar o valor.
		add $t2, $t2, $t5 # sum += vet[i]
	pos_par:
		addi $t3, $t3, 1
		bne $t3, $t1, loop_soma_pares
	#fim do loop
	move $v0, $t2 # move sum pra $v0(retorno)
	jr $ra				
########################################################################################
letra_c:
	# $s0: ponteiro pra base do vetor
	# $s1: tamanho do vetor
	# $t2: chave k
	# $t3: 2*k
	# $t4: contador dos maiores que k e menores que 2*k
	# $t6: contador do indice (i)
	# $t0: vet[i]
	
	li $v0, 4
	la $a0, entrada_c
	syscall
	
	li $v0, 5
	syscall
	move $t2, $v0

	li $t3, 2
	mult $t2, $t3
	mflo  $t3
	
	li $t4, 0
	
	li $t6, 0 # Incializa o indice com zero
	loop_questao_c:
		sll $t0, $t6, 2
		add $t0, $t0, $s0
		lw $t0, 0($t0)
		ble $t0, $t2, fim_condicao_c
		ble $t3, $t0, fim_condicao_c
		addi $t4, $t4, 1
		
		fim_condicao_c:
		addi $t6, $t6, 1	#incrementa o indice
		bne $t6, $s1 loop_questao_c	# Pula se o indice nao for igual ao tamanho do vetor
		
	#fim do loop
	move $v0, $t4
		
	jr $ra
########################################################################################
questao_d:
	# Essa funcao retorna a quantidade de vezes que uma chave j se repete em um vetor
	# $t0: ponteiro pra base do vetor
	# $t1: tamanho do vetor (n)
	# $t2: chave j
	# $t3: indice i
	# $t4: vet[i]
	# $t5: contador
	
	move $t0, $a0	# Mandei o endereco do vetor como parametro
	move $t1, $a1	# Mandei o indice do vetor como parametro
	move $t2, $a2	# Mandei a chave j como parametro
	
	li $t3, 0 # Inicia o indice (i) com zero
	li $t5, 0 # Inicia o contador com zero
	loop_d:
		sll $t4, $t3, 2	# Calcula o quanto tem que somar na base do vetor (i*4)
		add $t4, $t4, $t0	# Coloca o endereco de vet[i] em $t4
		lw $t4, 0($t4)	# $t4 = vet[i]
		
		bne $t4, $t2, pos_incremento # Pula a incrementacao do contador se os elementos forem diferentes
		addi $t5, $t5, 1
		pos_incremento:
		addi $t3, $t3, 1	# Incrementa o indice ( i += 1)
		bne $t3, $t1, loop_d	# Pula enquando o indice for diferente do numero de elementos do vetor (i != n)
	# Fim do loop
	move $v0, $t5	# Retorna o tamanho
	jr $ra
		
	

########################################################################################
soma_numeros_perfeitos:
	# $t0: ponteiro pra base do vetor &vet[0]
	# $t1: tamanho do vetor (n)
	# $t2: soma dos perfeitos
	# $t3: contador/indice (i)
	# $t4: vet[i]
	
	move $t0, $a0
	move $t1, $a1
	li $t2, 0
	li $t3, 0
	# Vou empilhar $ra em $sp, pra poder chamar outra funcao no meio dessa funcao
	add $sp, $sp, -4 # Aloco espaco pra uma palavra em $sp
	sw $ra, 0($sp)	# Armazena o endereco de retorno na pilha
	
	loop_perfeitos:
		sll $t4, $t3, 2	# Multiplica o indice por 4
		add $t4, $t4, $t0	#guarda o endereco de vet[i]
		lw $t4, 0($t4)	# Guarda vet[i]
		#move $a0, $t4
		jal eh_perfeito
		beqz $v0, pos_soma_perfeitos	# Se nao for perfeito, pula a soma
		add $t2, $t2, $t4
		pos_soma_perfeitos:
		addi $t3, $t3, 1
		bne $t3, $t1 loop_perfeitos
	# Fim do loop
	lw $ra, 0($sp) # A justo o retorno, desempilhando $sp
	addi $sp, $sp, 4 # Desaloco a memoria de $sp
	move $v0, $t2 # Ajusto a soma como retorno
	jr $ra
		
		
########################################################################################
eh_perfeito:
	# $a0: numero que eu estou verificando (n)
	# $t5: contador (i)
	# $t6: soma dos divisores (sum)
	
	#move $t4, $a0
	blez $t4, false_perfeito
	
	li $t5, 1 # Contador comeca com 1 porque nao tem como dividir por zero
	li $t6, 0
	
	loop_eh_perfeito:
		div $t4, $t5
		mfhi $t7	# guarda o resto da divisao de i por n em $t3
		bnez $t7 pos_soma_eh_perfeito	# pula a soma se o resto nao for zero
		add $t6, $t6, $t5
		pos_soma_eh_perfeito:
		addi $t5, $t5, 1
		blt $t5, $t4, loop_eh_perfeito
	# Fim do loop
	bne $t6, $t4 false_perfeito
	li $v0, 1	# Se a soma dos divisores for igual ao numero retorna true
	jr $ra
	false_perfeito:
	li $v0, 0
	jr $ra	# Se nao for, ou se n for zero ou negativo, retorna false.
		
		
	
########################################################################################
soma_semiprimos:
	# $t0: contador de indice do vetor (i)
	# $t1: vet[i]
	# $t7: soma dos semiprimos (sum)
	li $t7, 0
	li $t0, 0
	loop_semiprimos:
		# As proximas tres linhas salvam vet[i] em $t1
		sll $t1, $t0, 2
		add $t1, $t1, $s0
		lw $t1, 0($t1)
		
		j eh_semiprimo
		fim_semi:
		
		addi $t0, $t0, 1	#incrementa o indice, i += 1
		blt $t0, $s1, loop_semiprimos	# pula enquanto o indice for diferente do tamanho do vetor
		move $v0, $t7
		jr $ra
	
	eh_semiprimo:
		# $t2: contador para achar os divisores (vai de 2 a vet[i]) (j)
		# $t3: contador de divisores
		# $t1: vet[i] (valor que eu estou verificando)
		
		ble $t1, 3, fim_semi	# se vet[i] <= 3, vet[i] nao eh semiprimo, porque o menor semiprimo eh 4.
		li $t2, 2	# Inicia o contador j com 2
		li $t3, 0	#zera o contador de divisor
		loop_eh_semiprimo:
			bgt $t3, 2, fim_semi	# Se o numero tiver mais que dois divisores, nao eh semi primo
			div $t1, $t2
			mfhi $t4	# $t4 eh o resto da divisao vet[i]/j
			bnez $t4, pulo_eh_semiprimo	# Pula se nao for divisor
			addi $t3, $t3, 1 	#incrementa o contador de divisor
			#j eh_primo_semiprimo
			#volta_primo_semi:
			# Se voltar pra ca, o divisor eh primo			
			pulo_eh_semiprimo:
			
			addi $t2, $t2, 1
			blt $t2, $t1, loop_eh_semiprimo
		# Fim do loop
		bgt $t3, 2, fim_semi
		beqz $t3, fim_semi
		# Se chegou aqui vet[i] tem 2 ou menos divisores, e todos os divisores sao primos, logo eh semi primo
		# Soma sum += vet[i]
		add $t7, $t7, $t1
		li $v0, 1
		j fim_semi
		
	
	eh_primo_semiprimo:
		# Essa funcao verifica se o j eh primo
		# $t5: contador pra encontrar possiveis divisores (l)
		# $t4: numero que eu estou verificando  (y)
		
		#beq $t4, 2, volta_primo_semi	# se y == 2, y eh primo
		li $t5, 2	# Incia o contador com 2 ( l = 2 )
	loop_eh_primo_semiprimo:
		div $t4, $t5	# x/l
		mfhi $t6	# $t6 = x%l
		bnez $t6, fim_semi # Se algum divisor de vet[i] nao for primo, vet[i] nao eh semiprimo
		addi $t5, $t5, 1
		blt $t5, $t4, loop_eh_primo_semiprimo
	#j volta_primo_semi
		
########################################################################################

fim_programa:
	li $v0, 10
	syscall
	

	
	
	
	
	
	
	
