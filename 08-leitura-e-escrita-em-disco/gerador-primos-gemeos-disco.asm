# =======================================================================================
# Titulo: Geracao e Persistencia de Primos Gemeos
# Descricao: Verifica iterativamente a primalidade de numeros no intervalo de 1 a N, 
# identificando pares de primos gemeos (p, p+2) e persistindo os resultados num ficheiro.
# Analise de Computabilidade: A verificacao de primalidade e um problema decidivel. 
# O espaco de busca e rigorosamente limitado por N, garantindo a paragem. A escrita 
# sequencial atua como uma fita de saida unidirecional numa Maquina de Turing.
# Aplicacao: Geracao de chaves assimetricas em criptografia e construcao de dicionarios 
# de fatores primos para investigacao em seguranca da informacao.
# Referência na documentação: "atividade-mips-11.pdf"
# =======================================================================================

.data
arquivo: .asciiz "primos_gemeos.txt"
entrada: .asciiz "Insira um inteiro N: "
espaco: .asciiz " "
quebra_linha: .asciiz "\n"
.align 1
buffer: .space 12		# Espaco para guardar o numero do vetor convertido em string.
.align 2
vetor: .space 400


.text
	# vetor: $s0
	# tamanho do vetor: $s2
	# descritor do arquivo: $s3
	
	# Printa a mensagem de entrada:
	la $a0, entrada
	li $v0, 4
	syscall
	# Le inteiro:
	li $v0, 5
	syscall
	move $s1, $v0		# Guarda n em $s1
	la $s0, vetor
	move $a0, $s0
	move $a1, $s1
	jal gemeo
	move $s2, $v0
	#################################
	# TESTE
#	li $t0, 0
#	loop_teste:
#	la $a0, espaco
#	li $v0, 4
#	syscall
	
#	sll $t1, $t0, 2
#	add $t1, $t1, $s0
#	lw $a0, ($t1)
#	li $v0, 1
#	syscall
	
#	addi $t0, $t0, 1
#	blt $t0, $s2, loop_teste
	#################################
	
	# Abrir arquivo:
	la $a0, arquivo
	li $a1, 1	# Modo de escrita
	li $v0, 13
	syscall
	move $s3, $v0	# Descritor do arquivo
	
	li $t0, 0
	loop_escrita:
	
	# Sai do programa quando percorrer todo o vetor:
	bge $t0, $s2, fim_escrita
	
	# Pega o proximo elemento do vetor:
	sll $t1, $t0, 2
	add $t1, $t1, $s0
	lw $a0, ($t1)
	
	# Converte o numero de inteiro para string:
	la $a1, buffer
	jal int_para_string
	
	# Escreve a string no arquivo:
	li $v0, 15
	move $a0, $s3		# Passa o descritor do arquivo como parametro
	la $a1, buffer
	li $a2, 12
	syscall
	
	# Escreve um espaco entre os numeros:
	li $v0, 15
	move $a0, $s3
	la $a1, espaco
	li $a2, 1
	syscall
	
	# Encrementa o indice e pula para o inicio do loop:
	addi $t0, $t0, 1
	j loop_escrita
	
	fim_escrita:
	# Escreve uma quebra de linha no arquivo:
	li $v0, 15
	move $a0, $s3
	la $a1, quebra_linha
	li $a2, 1
	
	# Fecha o arquivo:
	li $v0, 16
	move $a0, $s3
	syscall	
	
	# Encerra o programa:
	li $v0 ,10
	syscall
	
	





gemeo:
	# $a0 -> vetor
	# $a1 -> n
	subi $sp, $sp, 4
	sw $ra, ($sp)
	move $a3, $a0		# Passa o vetor para $a3
	li $t0, 1		# i = 0
	li $t7, 0		# j = 0
	loop_gemeo:
	move $a0, $t0
	jal eh_primo
	beq $v0, 0, pula_gemeo
	
	addi $a0, $t0, 1
	jal eh_primo
	beq $v0, 1, pula_gemeo
	
	addi $a0, $t0, 2
	jal eh_primo
	beq $v0, 0, pula_gemeo
	
	sll $t1, $t7, 2
	add $t1, $t1, $a3
	sw $t0, ($t1)
	addi $t7, $t7, 1
	pula_gemeo:
	addi $t0, $t0, 1
	blt $t0, $a1, loop_gemeo
	move $v0, $t7
	lw $ra, ($sp)
	addi $sp $sp 4
	jr $ra
	

eh_primo:
	li $t5, 2
	beq $a0, 1, primo_false
	beq $a0, 2, primo_true
	loop_eh_primo:
	div $a0, $t5
	mfhi $t6
	beq $t6, 0, primo_false
	addi $t5, $t5, 1
	beq $t5, $a0, primo_true
	j loop_eh_primo

primo_true:
	li $v0, 1
	jr $ra
primo_false: 
	li $v0, 0
	jr $ra

int_para_string:
	# Numero: $a0
	# Buffer: $a1
	li $t2, 10 		# Base decimal
	move $t3, $a1		# Move o buffer para $t3
	addi $t3, $t3, 11	# Vai para o fim do buffer
	lb $zero, ($t3)		# adiciona o terminador de strin '\0'
	
	loop_conversao:
	div $a0, $t2
	mfhi $t4		# resto
	mflo $a0		# quociente
	
	# converte para ascii:
	addi $t4, $t4, 48
	
	# Guarda no buffer:
	subi $t3, $t3, 1
	sb $t4, ($t3)
	
	# inicio do loop se $a0 != 0
	bnez $a0, loop_conversao
	
	move $a1, $t3
	jr $ra
	

