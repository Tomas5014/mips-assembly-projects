# =======================================================================================
# Titulo: Produto de Matriz por Vetor
# Descricao: Calcula o produto de uma matriz A (4x3) por um vetor V (3 elementos).
# Demonstra a manipulacao de arrays bidimensionais linearizados na memoria estatica.
# Analise de Computabilidade: O algoritmo executa em tempo polinomial O(n*m). 
# A transformacao de indices bidimensionais para um espaco de enderecamento linear 
# (memoria RAM) e uma funcao computavel total, garantindo a paragem e a exatidao 
# das operacoes matematicas.
# Aplicacao: Operacoes fundamentais de algebra linear essenciais para pesquisa 
# cientifica em redes neuronais e deteccao de anomalias (stream mining).
# Referência na documentação: "atividade-mips-05.pdf"
# =======================================================================================

.data
Mat: .space 48 			# 4x3 x 4 (inteiros)
Vet: .space 12			# 3 x 4 (inteiros)
Prod: .space 16			# 4 x 4 (inteiros)
Ent1: .asciiz "Insira o valor de MatA["
Ent2: .asciiz "]["
Ent3: .asciiz "]: "
EntVet1: .asciiz "Insira o valor de VetV["
EntVet2: .asciiz "]: "
EntMat: .asciiz "Insira a Matriz A:\n"
EntVet: .asciiz "\nInsira o Vetor V:\n"

.text
main:
	la $s0, Mat		# Endereco base de Mat
	la $s1, Vet		# Endereco base de vet
	li $s2, 3		# Tamanho do vetor; $s2 <=> tamvet
	li $s3, 4		# Numero de linhas ; $s3 <=> nlin
	li $s4, 3		# Numero de colunas ; $a2 <=> ncol
	la $s5, Prod		# Endereco base de prod
	
	li $v0, 4
	la $a0, EntMat
	syscall
	
	la $a0, Mat		# Endereco base de Mat
	li $a1, 4		# Numero de linhas ; $a1 <=> nlin
	li $a2, 3		# Numero de colunas ; $a2 <=> ncol
	jal leitura		# Leitura da matriz
	#move $s0, $v0
	
	li $v0, 4
	la $a0, EntVet
	syscall
	
	la $a0, Vet		# Passa o endereco do vetor como parametro
	li $a1, 3		# Passa o tamanho do vetor como parametro
	
	jal leitura_vet		# Leitura do vetor
	
	jal multiplicacao
	
	move $a0, $s5
	li $a1, 4
	li $a2, 1
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
	add $t0, $t0, 1		# i++ (pula a linha)
	blt $t0, $a1, e		# if(i < nlin) goto e
	li $t0, 0		# i = 0
	lw $ra, ($sp)		# Recupera o retorno para a main
	addi $sp, $sp, 4	# Libera o espaco para a pilha
	move $v0, $a3		# Retorna o endereco base da matriz
	jr $ra			# Retorna para a main
	
leitura_vet:
	move $a3, $a0		# Guarda o endereco do vetor
	li $t0, 0		# k = 0
l_vet:
	bge $t0, $a1, fim_l_vet	# pula se k >= tamvet
	li $t1, 4
	mult $t0, $t1
	mflo $t1		# $t1 = k*4
	add $t1, $t1, $a3	# $t1 = &vet[k]
	
	li $v0, 4		# Codigo pra imprimir string
	la $a0, EntVet1
	syscall
	
	li $v0, 1		# Codigo pra imprimir inteiro
	move $a0, $t0
	syscall
	
	li $v0, 4		# Codigo pra imprimir string
	la $a0, EntVet2
	syscall
	
	li $v0, 5		# Codigo pra ler inteiro
	syscall
	
	sw $v0, ($t1)		# Guarda o inteiro no vetor
	
	addi $t0, $t0, 1	# k++
	j l_vet
	
fim_l_vet:
	move $a0, $a3		# Retorna o endereco base do vetor
	jr $ra

multiplicacao:
	li $t0, 0		# i = 0 ; i <=> $t0	; linha
	li $t1, 0		# j = 0 ; j <=> $t1	; coluna
	subi $sp, $sp, 4	# Espaco para 1 item na pilha
	sw $ra, ($sp)		# Salva o retorno para a main
	
loop_mult:
	li $t5, 0		# aux = 0
	move $a3, $s0
	move $a2, $s4
	loop_int:
		
		jal indice		# Calcula o endereco de Mat[i][j]
		move $t3, $v0
		lw $t3, ($t3)		# $t3 = mat[i][j]
		li $t2, 4
		mult $t1, $t2
		mflo $t2		# $t2 = j*4
		add $t2, $t2, $s1	# $t2 = &vet[j]
		lw $t2, ($t2)		# $t2 = vet[j]
		mult $t3, $t2
		mflo $t4		# $t4 = mat[i][j] * vet[j]
		add $t5, $t4, $t5	# aux += $t4
		addi $t1, $t1, 1	# j++
		blt $t1, $s4 loop_int		# if(j < ncol) goto loop_int
	li $t1, 0		# j = 0
	li $t6, 4		
	mult $t6, $t0
	mflo $t6		# $t6 = i*4
	add $t6, $t6, $s5	# $t6 = $prod[i]
	sw $t5, ($t6)		# prod[i] = aux
	
	addi $t0, $t0, 1	# i++
	blt $t0, $s3, loop_mult # if(i < nlin) goto loop_mult
	lw $ra, ($sp)		# Recupera o retorno para a main
	addi $sp, $sp, 4	# Libera o espaco para a pilha
	jr $ra			# Retorna para a main
		
	