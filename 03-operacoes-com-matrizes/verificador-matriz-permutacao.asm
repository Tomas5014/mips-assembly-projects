# =======================================================================================
# Titulo: Verificador de Matriz de Permutacao
# Descricao: Avalia se uma matriz inteira quadrada Anxn possui exatamente n-1 elementos 
# nulos e um unico elemento igual a 1 em cada linha e coluna.
# Analise de Computabilidade: Trata-se de um problema de decisao classicamente 
# decidivel. O codigo atua como um reconhecedor formal que processa a entrada finita, 
# aceitando ou rejeitando a hipotese em tempo polinomial O(n^2) sem risco de loops 
# infinitos (halting problem evitado por limites estritos no domínio iterativo).
# Aplicacao: Analise estrutural de matrizes utilizada em criptografia, teoria dos 
# grafos e algoritmos de escalonamento em pesquisa operacional.
# Referência na documentação: "atividade-mips-05.pdf"
# =======================================================================================

.data
Mat: .space 324 # 9x9 x 4 (inteiros)
Ent1: .asciiz "Insira o valor de Mat["
Ent2: .asciiz "]["
Ent3: .asciiz "]: "
EntTam: .asciiz "Insira o tamanho n de linhas e colunas da matriz quadrada: "
Saida_true: "\nA matriz eh de permutacao!\n"
Saida_false: "\nA matriz NAO eh de permutacao!\n"
.text
main:
	la $s0, Mat		# Endereco base da matriz
		
	li $v0, 4
	la $a0, EntTam
	syscall			# Printa a mensagem de tamanho da matriz
	
	li $v0, 5
	syscall
	move $s1, $v0		# Tamanho n da matriz_nxn
	
	
	move $a0, $s0		# Endereco base de Mat
	move $a1, $s1		# Numero de linhas ; $a1 <=> nlin
	move $a2, $s1		# Numero de colunas ; $a2 <=> ncol
	jal leitura
	move $a0, $s0
	jal escrita
	jal permutacao
	move $t0, $v0
	
	beqz $t0, false
	
	li $v0, 4
	la $a0, Saida_true
	syscall			# Printa a mensagem de true
	j fim_programa
	
	false:
	li $v0, 4
	la $a0, Saida_false
	syscall			# Printa a mensagem de false
fim_programa:
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
	
permutacao:
	# $v0 vai ser booleano contendo a resposta, se eh ou nao de permutacao
	addi $sp, $sp, -4	# Aloca espaco na pilha
	sw $ra, ($sp)		# Guarda o endereco de retorno pra main na pilha
	li $t0, 0		# i = 0 ; i <=> $t0
	li $t1, 0		# j = 0 ; j <=> $t1
	li $t2, 0		# Contador de 1 
	move $a2, $s1		# Pra funcao indice
	move $a3, $s0		# Pra funcao indice 
loop_linhas:
	jal indice
	move $t3, $v0
	lw $t3, ($t3)		# mat[i][j]
	beqz $t3 eq0		# if(mat[i][j] == 0) goto eq0
	bne $t3, 1, err		# if (mat[i][j] != 1) goto err	;	se for diferente de 1 e de 0
	addi $t2, $t2, 1	# cont++	;	mat[i][j] == 1
	eq0:
	addi $t1, $t1, 1	# j++
	blt $t1, $s1, loop_linhas	# if(j < n) goto loop_linhas
	bne $t2, 1, err		# if(cont != 1) goto err
	li $t1, 0		# j = 0
	li $t2, 0		# cont = 0
	addi $t0, $t0, 1	# i++
	blt $t0, $s1, loop_linhas	# if(i < n) goto loop_linhas
	# Se chegar aqui, todas as linhas tem apenas um 1 e o resto dos elementos nulos
	li $t0, 0		# i = 0 ; i <=> $t0
	li $t1, 0		# j = 0 ; j <=> $t1
	li $t2, 0		# Contador de 1 
loop_colunas:
	jal indice
	move $t3, $v0
	lw $t3, ($t3)		# mat[i][j]
	beqz $t3 eqzero		# if(mat[i][j] == 0) goto eq0
	bne $t3, 1, err		# if (mat[i][j] != 1) goto err	;	se for diferente de 1 e de 0
	addi $t2, $t2, 1	# cont++	;	mat[i][j] == 1
	eqzero:
	addi $t0, $t0, 1	# i++
	blt $t0, $s1, loop_colunas	# if(i < n) goto loop_linhas
	bne $t2, 1, err		# if(cont != 1) goto err
	li $t0, 0		# i = 0
	li $t2, 0		# cont = 0
	addi $t1, $t1, 1	# j++
	blt $t1, $s1, loop_colunas	# if(j < n) goto loop_linhas
	# Se chegar aqui, todas as linhas e colunas tem apenas um 1 e o resto dos elementos nulos
	li $v0, 1		# retorna true
	lw $ra, ($sp)		# Recupera o retorno para a main
	addi $sp, $sp, 4	# Libera o espaco para a pilha
	jr $ra			# Retorna para a main
err:
	li $v0, 0		# retorna false
	lw $ra, ($sp)		# Recupera o retorno para a main
	addi $sp, $sp, 4	# Libera o espaco para a pilha
	jr $ra			# Retorna para a main
