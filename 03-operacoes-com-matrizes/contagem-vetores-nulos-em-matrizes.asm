# =======================================================================================
# Titulo: Contagem de Linhas e Colunas Nulas em Matriz
# Descricao: Percorre uma matriz mxn contabilizando a quantidade de linhas e colunas 
# compostas inteiramente por valores zeros.
# Analise de Computabilidade: O sistema simula um Automato Finito Deterministico (AFD) 
# com estados de falha e aceitacao para cada sub-vetor. A maquina de estados transita 
# imediatamente para o proximo laco ao detetar o primeiro valor diferente de zero, 
# demonstrando eficiencia e otimizacao de ciclos de relogio na avaliacao de matrizes.
# Aplicacao: Pre-processamento de dados esparsos e compressao de matrizes, muito 
# utilizado em estagios iniciais de modelos de aprendizado de maquina.
# Referência na documentação: "atividade-mips-05.pdf"
# =======================================================================================

.data
Mat: .space 324 # 9x9 x 4 (inteiros)
Ent1: .asciiz "Insira o valor de Mat["
Ent2: .asciiz "]["
Ent3: .asciiz "]: "
Entm: .asciiz "Insira o numero m de linhas: "
Entn: .asciiz "Insira o numero n de colunas: "
Saida_linhas: .asciiz "\nLinhas nulas: "
Saida_colunas: .asciiz "\nColunas nulas: "
.text
main:
	la $s0, Mat		# Endereco base da matriz
		
	li $v0, 4
	la $a0, Entm
	syscall			# Printa a mensagem m
	
	li $v0, 5
	syscall
	move $s1, $v0		# Tamanho m da matriz_mxn
	
	li $v0, 4
	la $a0, Entn
	syscall			# Printa a mensagem n
	
	li $v0, 5
	syscall
	move $s2, $v0		# Tamanho n da matriz_mxn
	
	
	move $a0, $s0		# Endereco base de Mat
	move $a1, $s1		# Numero de linhas ; $a1 <=> nlin
	move $a2, $s2		# Numero de colunas ; $a2 <=> ncol
	jal leitura
	move $a0, $s0
	jal escrita
	
	jal nulas
	
	move $t0, $v0
	move $t1, $v1
	
	li $v0, 4
	la $a0, Saida_linhas
	syscall	
	
	li $v0, 1
	move $a0, $t0
	syscall
	
	li $v0, 4
	la $a0, Saida_colunas
	syscall	
	
	li $v0, 1
	move $a0, $t1
	syscall
	
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
	
nulas:
	# $v0 vai retornar o numero de linhas nulas e $v1 o numero de colunas nulas
	addi $sp, $sp, -4	# Aloca espaco na pilha
	sw $ra, ($sp)		# Guarda o endereco de retorno pra main na pilha
	li $t0, 0		# i = 0 ; i <=> $t0
	li $t1, 0		# j = 0 ; j <=> $t1
	li $t2, 0		# Contador de colunas
	li $t4, 0		# Contador de linhas
	move $a2, $s2		# Pra funcao indice
	move $a3, $s0		# Pra funcao indice 
loop_linhas:
	jal indice
	move $t3, $v0
	lw $t3, ($t3)		# mat[i][j]
	bnez $t3, errl		# if (mat[i][j] != 0) goto errl	;
	addi $t1, $t1, 1	# j++
	blt $t1, $s2, loop_linhas	# if(j < n) goto loop_linhas
	addi $t2, $t2, 1	# contlin++
	errl:
	li $t1, 0		# j = 0
	addi $t0, $t0, 1	# i++
	blt $t0, $s1, loop_linhas	# if(i < m) goto loop_linhas
	# Aqui acaba o contador de linhas nulas e comeca o contador de colunas
	li $t0, 0		# i = 0 ; i <=> $t0
	li $t1, 0		# j = 0 ; j <=> $t1
loop_colunas:
	jal indice
	move $t3, $v0
	lw $t3, ($t3)		# mat[i][j]
	bnez $t3, errc		# if (mat[i][j] != 0) goto errc	;
	addi $t0, $t0, 1	# i++
	blt $t0, $s1, loop_colunas	# if(i < m) goto loop_linhas
	addi $t4, $t4, 1	# contcol++
	errc:
	li $t0, 0		# i = 0
	addi $t1, $t1, 1	# j++
	blt $t1, $s2, loop_colunas	# if(j < n) goto loop_linhas
	
	# Se chegar aqui, todas as linhas e colunas nulas ja foram contadas
	move $v0, $t2		# Retorna o numero de linhas nulas
	move $v1, $t4		# Retorna o numero de colunas nulas
	lw $ra, ($sp)		# Recupera o retorno para a main
	addi $sp, $sp, 4	# Libera o espaco para a pilha
	jr $ra			# Retorna para a main
