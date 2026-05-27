# =======================================================================================
# Titulo: Comparacao Simultanea e Intersecao Posicional de Matrizes
# Descricao: Aloca e processa duas matrizes 4x4 na memoria estatica, comparando 
# sequencialmente os valores homologos e acumulando a soma das coordenadas 
# (linha + coluna) em caso de intersecão exata de valores.
# Analise de Computabilidade: Demonstra o processamento paralelo de duas estruturas de 
# dados. A complexidade linearizada O(n*m) e rigidamente controlada pelos limites de 
# cada bloco de memoria, evidenciando a decidibilidade da deteccao de padroes estritos 
# em tempo finito sem perigo de desbordamento de memoria (buffer overflow).
# Aplicacao: Deteccao de anomalias por comparacao de assinaturas estaticas e avaliacao 
# de similaridade em matrizes de confusao e analise de fluxos continuos (data stream).
# Referência na documentação: "atividade-mips-07.pdf"
# =======================================================================================

.data
mat1: .space 64 # 4x4 x 4 (inteiros)
mat2: .space 64 # 4x4 x 4 (inteiros)
insersao1: .asciiz "Insira a primeira matriz:\n"
insersao2: .asciiz "Insira a segunda matriz:\n"
ent1: .asciiz "Insira o valor de Mat["
ent2: .asciiz "]["
ent3: .asciiz "]: "
saida1: .asciiz "O numero de valores iguais que estao na mesma posicao eh: "
saida2: .asciiz "\nA soma das posicoes (linha+coluna) de todos os elementos iguais eh: "
.text
main:
	la $a0, insersao1
	li $v0, 4
	syscall
	
	la $a0, mat1		# Endereco base de Mat
	li $a1, 4		# Numero de linhas ; $a1 <=> nlin
	li $a2, 4		# Numero de colunas ; $a2 <=> ncol
	jal leitura
	move $s0, $v0		# $s0 -> &mat1
	move $a0, $v0
	jal escrita
	
	la $a0, insersao2
	li $v0, 4
	syscall
	
	la $a0, mat2		# Endereco base de Mat
	li $a1, 4		# Numero de linhas ; $a1 <=> nlin
	li $a2, 4		# Numero de colunas ; $a2 <=> ncol
	jal leitura
	move $s1, $v0
	move $a0, $v0	
	jal escrita
	
	jal iguais
	move $t0, $v0
	move $t1, $v1
	
	la $a0, saida1
	li $v0, 4
	syscall
	
	move $a0, $t0
	li $v0, 1
	syscall
	
	la $a0, saida2
	li $v0, 4
	syscall
	
	move $a0, $t1
	li $v0, 1
	syscall
	
	li $v0, 10		# Codigo pra finalizar o programa
	syscall
	
indice:
	mult $t0, $a2 		# i * ncol (essa formula serve pra "pular" as linhas anteriores)
	mflo $v0
	add $v0, $v0, $t1	# (i*ncol) + j
	sll $v0, $v0, 2		# [(i*ncol) + j] * 4
	add $v0, $v0, $a3	# soma com o endereco base
	jr $ra
	
leitura:
	li $t0, 0		# i = 0 ; i <=> $t0
	li $t1, 0		# j = 0 ; j <=> $t1
	subi $sp, $sp, 4	# Espaco para 1 item na pilha
	sw $ra, ($sp)		# Salva o retorno para a main
	move $a3, $a0		# aux = endereco base de Mat
l:
	la $a0, ent1		# Carrega o endereco da string
	li $v0, 4		# Syscall pra imprimir string
	syscall
	addi $t7, $t0, 1
	move $a0, $t7		# Carrega i
	li $v0, 1		# Syscall pra imprimir inteiro
	syscall
	la $a0, ent2		# Carrega o endereco da string
	li $v0, 4		# Syscall pra imprimir string
	syscall
	addi $t7, $t1, 1
	move $a0, $t7		# Carrega j
	li $v0, 1		# Syscall pra imprimir inteiro
	syscall
	la $a0, ent3		# Carrega o endereco da string
	li $v0, 4		# Syscall pra imprimir string
	syscall
	
	li $v0, 5		# Codigo de leitura de inteiro
	syscall
	move $t2, $v0
	jal indice		# Calcula o endereco de Mat[i][j]
	move $t3, $v0
	sw $t2, ($t3)		# mat[i][j] = aux
	addi $t1, $t1, 1	# j++
	blt $t1, $a2, l		# if(j < ncol) goto l
	li $t1, 0		# j = 0
	addi $t0, $t0, 1	# i++
	blt $t0, $a1, l 	# if(i < nlin) goto l
	li $t0, 0		# i = 0
	lw $ra, ($sp)		# Recupera o retorno para a main
	addi $sp, $sp, 4	# Libera o espaco para a pilha
	move $v0, $a3		# Retorna o endereco base da matriz
	jr $ra			# Retorna para a main
	
escrita:
	addi $sp, $sp, -4	# Aloca espaco na pilha
	sw $ra, ($sp)		# Guarda o endereco de retorno pra main na pilha
	move $a3, $a0		# GUarda o endereco base de mat em $a3
	
	li $t0, 0		# i = 0 ; i <=> $t0
	li $t1, 0		# j = 0 ; j <=> $t1
e:
	li $v0, 11		# Codigo para impressao de caractere
	la $a0, 32		# Codigo ASCII para espaco
	syscall
	
	jal indice		# Calcula o endereco de Mat[i][j]		
	move $t3, $v0
	lw $a0, ($t3)		# Valor em Mat[i][j]
	li $v0, 1		# Codigo pra imprimir inteiro
	syscall
	
	li $v0, 11		# Codigo para impressao de caractere
	la $a0, 32		# Codigo ASCII para espaco
	syscall
	
	addi $t1, $t1, 1	# j++
	
	blt $t1, $a2, e		# if(j < ncol) goto e
	
	li $v0, 11		# Codigo para impressao de caractere
	la $a0, 10		# Codigo ASCII para new line ('\n')
	syscall
	
	li $t1, 0 		# j = 0
	add $t0, $t0, 1		# i++ (pula a linha)7
	blt $t0, $a1, e		# if(i < nlin) goto e
	li $t0, 0		# i = 0
	lw $ra, ($sp)		# Recupera o retorno para a main
	addi $sp, $sp, 4	# Libera o espaco para a pilha
	move $v0, $a3		# Retorna o endereco base da matriz
	jr $ra			# Retorna para a main
	
iguais:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	li $t0, 0		# $t0 -> i
	li $t1, 0		# $t1 -> j
	li $t2, 0 		# $t2 -> cont
	li $t3, 0		# $t3 -> soma
				# $s0 -> &mat1
				# $s1 -> &mat2
	li $a1, 4		# $a1 -> numero de colunas
	li $a2, 4		# $a2 -> numero de linhas
i:
	move $a3, $s0
	jal indice
	move $t4, $v0
	lw $t4, ($t4)
	
	move $a3, $s1
	jal indice
	move $t5, $v0
	lw $t5, ($t5)
	
	bne $t5, $t4, ni	# if(mat1[i][j] != mat2[i][j]) goto ni
	addi $t2, $t2, 1	# cont++
	add $t3, $t3, $t0	# soma += i
	add $t3, $t3, $t1	# soma += j
	addi $t3, $t3, 2
ni:
	addi $t1, $t1, 1	# j++
	blt $t1, $a2, i		# if(j < ncol) goto i
	li $t1, 0		# j = 0
	addi $t0, $t0, 1	# i++
	blt $t0, $a1, i		# if(i < nlin) goto i
	li $t0, 0		# i = 0
	
	lw $ra, ($sp)
	addi $sp, $sp, 4
	move $v0, $t2		# retorna cont
	move $v1, $t3		# retorna soma
	jr $ra
	
	
	