# =======================================================================================
# Titulo: Transformacoes Lineares - Rotacao de Matrizes
# Descricao: Le uma matriz quadrada nxn estatica e aplica transformacoes espaciais, 
# gerando e imprimindo novas visualizacoes do tensor rotacionadas a 90, 180 e 270 graus.
# Analise de Computabilidade: Demonstra o mapeamento de indices bidimensionais atraves 
# de funcoes injetivas na memoria. A reorganizacao espacial ocorre em tempo polinomial 
# O(n^2) de forma deterministica, mantendo o espaco de enderecamento intacto. 
# Aplicacao: Manipulacao estrutural crucial para tecnicas de aumentacao de dados 
# (data augmentation) e deteccao de caracteristicas de invariancia posicional.
# Referência na documentação: "atividade-mips-09.pdf"
# =======================================================================================

.data
Ent1: .asciiz "Insira o valor de Mat["
Ent2: .asciiz "]["
Ent3: .asciiz "]: "
ent4: .asciiz "Insira o tamanho n da matriz nxn: "
saida1: .asciiz "\nMatriz de entrada:\n"
saida2: .asciiz "\nMatriz rotacionada em 90 graus:\n"
saida3: .asciiz "\nMatriz rotacionada em 180 graus:\n"
saida4: .asciiz "\nMatriz rotacionada em 270 graus:\n"
.text
main:
	li $v0, 4
	la $a0, ent4
	syscall
	
	li $v0, 5
	syscall
	move $s1, $v0
	
	mul $t0, $s1, $s1		# n*n
	sll $t0, $t0, 2			# n*n*4
	move $a0, $t0
	li $v0, 9
	syscall
	move $s0, $v0		# Endereco da matriz alocada
	li $v0, 9
	syscall
	move $s2, $v0
	move $a0, $s0
	move $a1, $s1		# Numero de linhas ; $a1 <=> nlin
	move $a2, $s1		# Numero de colunas ; $a2 <=> ncol
	jal leitura
	
	li $v0, 4
	la $a0, saida1
	syscall
	
	move $a0, $s0
	jal escrita
	
	move $a0, $s0
	move $a1, $s2
	move $a2, $s1
	jal rotaciona
	
	li $v0, 4
	la $a0, saida2
	syscall
	
	move $a0, $s2
	move $a1, $s1		# Numero de linhas ; $a1 <=> nlin
	move $a2, $s1		# Numero de colunas ; $a2 <=> ncol
	jal escrita
	
	move $a0, $s2
	move $a1, $s0
	move $a2, $s1
	jal rotaciona
	
	li $v0, 4
	la $a0, saida3
	syscall
	
	move $a0, $s0
	move $a1, $s1		# Numero de linhas ; $a1 <=> nlin
	move $a2, $s1		# Numero de colunas ; $a2 <=> ncol
	jal escrita
	
	move $a0, $s0
	move $a1, $s2
	move $a2, $s1
	jal rotaciona
	
	li $v0, 4
	la $a0, saida4
	syscall
	
	move $a0, $s2
	move $a1, $s1		# Numero de linhas ; $a1 <=> nlin
	move $a2, $s1		# Numero de colunas ; $a2 <=> ncol
	jal escrita
	
	
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
	la $a0, Ent1		# Carrega o endereco da string
	li $v0, 4		# Syscall pra imprimir string
	syscall
	move $a0, $t0		# Carrega i
	li $v0, 1		# Syscall pra imprimir inteiro
	syscall
	la $a0, Ent2		# Carrega o endereco da string
	li $v0, 4		# Syscall pra imprimir string
	syscall
	move $a0, $t1		# Carrega j
	li $v0, 1		# Syscall pra imprimir inteiro
	syscall
	la $a0, Ent3		# Carrega o endereco da string
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
	
rotaciona:
				# $a1 -> endereco da segunda matriz
	move $a3, $a0		# $a3 -> endereco da matriz base
				# $a2 -> tamanho n
	li $t0, 0		# i = 0 ; i <=> $t0
	li $t1, 0		# j = 0 ; j <=> $t1
	subi $sp, $sp, 4	# Espaco para 1 item na pilha
	sw $ra, ($sp)		# Salva o retorno para a main
r:
	jal indice		# Calcula o endereco de Mat[i][j]
	move $t3, $v0
	lw $t3, ($t3)
	
	move $t4, $t0
	move $t5, $t1
	move $t6, $a3
	
	move $t0, $t1
	sub $t1, $a2, $t4
	subi $t1, $t1, 1
	move $a3, $a1
	
	jal indice
	sw $t3, ($v0)
	
	move $t0, $t4
	move $t1, $t5
	move $a3, $t6
	
	addi $t1, $t1, 1	# j++
	blt $t1, $a2, r		# if(j < ncol) goto l
	li $t1, 0		# j = 0
	addi $t0, $t0, 1	# i++
	blt $t0, $a2, r		# if(i < nlin) goto l
	li $t0, 0		# i = 0
	lw $ra, ($sp)		# Recupera o retorno para a main
	addi $sp, $sp, 4	# Libera o espaco para a pilha
	move $v0, $a3		# Retorna o endereco base da matriz
	jr $ra			# Retorna para a main
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
