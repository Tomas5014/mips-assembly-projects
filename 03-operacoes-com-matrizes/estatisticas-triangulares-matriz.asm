# =======================================================================================
# Titulo: Extracao de Metricas Triangulares e Ordenacao de Matriz
# Descricao: Varre uma matriz 4x4 para calcular agregacoes matematicas nos triangulos 
# superior e inferior (relativos a diagonal principal), identificando valores extremos 
# (minimo e maximo) e aplicando a ordenacao completa da estrutura linearizada.
# Analise de Computabilidade: O problema combina limitacao condicional de espaco logico 
# com ordenacao in-place. Trata-se de um processamento rigoroso de limite polinomial 
# para as operacoes de procura e agregacao, garantindo a paragem e integridade do 
# estado da memoria em todas as sub-rotinas executadas em cascata.
# Aplicacao: Pre-processamento rigoroso, normalizacao de tensores e extracao de features, 
# operacoes recorrentes na preparacao de dados para modelos de aprendizado de maquina.
# Referência na documentação: "atividade-mips-07.pdf"
# =======================================================================================

.data
Mat: .space 64 # 4x4 x 4 (inteiros)
Ent1: .asciiz "Insira o valor de Mat["
Ent2: .asciiz "]["
Ent3: .asciiz "]: "
saida1: .asciiz "Resultado da subtracao: "
saida2: .asciiz "\nMaior elemento da fileira superior: "
saida3: .asciiz "\nMenor elemento da fileira inferior: "
saida4: .asciiz "\nMatriz ordenada:\n"
.text
main:
	la $a0, Mat		# Endereco base de Mat
	li $a1, 4		# Numero de linhas ; $a1 <=> nlin
	li $a2, 4		# Numero de colunas ; $a2 <=> ncol
	jal leitura
	move $a0, $v0
	jal escrita
	la $a0, Mat
	li $a2, 4
	jal funcao
	
	move $t0, $v0		# subtracao
	move $t1, $v1		# maior superior
	lw $t2, ($sp)		# menor superior
	addi $sp, $sp, 4
	
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
	
	la $a0, saida3
	li $v0, 4
	syscall
	
	move $a0, $t2
	li $v0, 1
	syscall
	
	la $a0, saida4
	li $v0, 4
	syscall
	
	la $a0, Mat		# Endereco base de Mat
	li $a1, 16		# Numero de elementos
	
	jal bubbleSort
	
	li $a1, 4		# Numero de linhas ; $a1 <=> nlin
	li $a2, 4		# Numero de colunas ; $a2 <=> ncol
	move $a0, $v0
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
	
funcao:
	move $a3, $a0
	addi $sp, $sp, -4
	sw $ra, ($sp)
	# Vou salvar os primeiros elementos da superior e inferior para a garantia do bom funcionamento do codigo
	# superior:
	li $t0, 0
	li $t1, 1
	jal indice
	lw $t4, ($v0)
	# inferior:
	li $t0, 1
	li $t1, 0
	jal indice
	lw $t5, ($v0)
	
				# $a2 -> nlin = ncol
				# $a3 -> &mat
	li $t0, 0		# $t0 -> i
	li $t1, 0		# $t1 -> j
	li $t2, 0		# $t2 -> supsoma
	li $t3, 0		# $t3 -> infsoma
	 			# $t4 -> maior acima
				# $t5 -> menor abaixo
f:
	jal indice
	lw $t6, ($v0)		# $t6 -> mat[i][j]
	
	ble $t1, $t0, sp	# if (j <= i) goto sp ; Se nao pular, esta na superior
	add $t2, $t2, $t6	# supsoma += $t6
	ble $t6, $t4, sp	
	move $t4, $t6		# maior acima = $t6
sp:	ble $t0, $t1, ip	# if (i <= j) goto ip ; Se nao pular, esta na inferir
	add $t3, $t3, $t6	# infsoma += $t6
	ble $t5, $t6, ip	
	move $t5, $t6		# menor abaixo = $t6
ip:	addi $t1, $t1, 1	# j++
	blt $t1, $a2, f		# if (j < n) goto f
	li $t1, 0
	addi $t0, $t0, 1	# i++
	blt $t0, $a2, f		# if(i < n) goto f
	li $t0, 0
	
	sub $v0, $t2, $t3	# retorna a soma dos elementos acima - a soma dos elementos abaixo
	move $v1, $t4		# Retorna o maior elemento acima
	lw $ra, ($sp)
	sw $t5, ($sp)		# Retorna o menor elemento abaixo
	jr $ra
	
bubbleSort:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	move $a3, $a0		# $a3 -> $vet
				# Numero de elementos ; $a1 <=> n
	li $t0, 0		# i
	li $t1, 1		# j

bs:
	sll $t3, $t0, 2		# i*4
	add $t3, $t3, $a3	# $vet[i]
	lw $t5, ($t3)		# vet[i]
	
	sll $t4, $t1, 2		# j*4
	add $t4, $t4, $a3	# &vet[j]
	lw $t6, ($t4)		# vet[j]

	ble $t5, $t6, postroca	# if (vet[i] <= vet[j]) goto postroca
	move $t7, $t5		# $t7 = vet[i]
	sw $t6, ($t3)		# vet[i] = vet[j]
	sw $t7, ($t4)		# vet[j] = $t7
postroca:
	addi $t1, $t1, 1	# j++
	blt $t1, $a1, bs	# if(j < n) goto bs2

	addi $t0, $t0, 1	# i++
	addi $t1, $t0, 1	# j = i + 1
	blt $t0, $a1, bs	# if(i < n - 1) goto bs

	# Concluir e restaurar pilha e registradores
	li $t0, 0
	move $v0, $a3
	lw $ra, ($sp)
	addi $sp, $sp , 4
	jr $ra

	
	
	
	
	
