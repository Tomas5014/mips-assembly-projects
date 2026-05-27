# =======================================================================================
# Titulo: Processamento Avancado e Extracao de Padroes em Matriz de Carateres
# Descricao: Executa um pipeline de transformacoes numa matriz nxm: conversao de 
# caixa (upper/lower), contagem de vogais, identificacao de repeticoes, busca 
# de palindromos, transposicao de linhas/colunas e ordenacao final.
# Analise de Computabilidade: O programa compila multiplos automatos finitos e 
# maquinas transdutoras num unico fluxo estruturado. Cada sub-rotina executa 
# o seu processamento polinomial garantindo a paragem isolada antes de transitar 
# o contexto de memoria para o proximo estado.
# Aplicacao: Limpeza de buffers, transformacao e engenharia de caracteristicas (feature 
# engineering) em grandes volumes de dados nao estruturados, operacoes vitais para 
# alimentar modelos de inteligencia artificial de forma confiavel.
# Referência na documentação: "atividade-mips-08.pdf"
# =======================================================================================

.data
Mat: .space 144 # 12x12 (caracteres)
mat1: .space 144 # 12x12 (caracteres)
vog1: .asciiz "aeiou"
vog2: .asciiz "AEIOU"
Ent1: .asciiz "Insira o caractere de Mat["
Ent2: .asciiz "]["
Ent3: .asciiz "]: "
ent4: .asciiz "Insira o tamanho n da matriz mxn: "
ent5: .asciiz "Insira o tamanho m da matriz mxn: "
saida1: .asciiz "\nMatriz inserida:\n"
saida2: .asciiz "\nMatriz inserida com as vogais MAIUSCULAS:\n"
saida3: .asciiz "\nO numero de vogais da matriz de entrada eh: "
saida4: .asciiz "\n\nOs caracteres que se repetem por mais de tres vezes na matriz de entrada sao: "
saida4.1: .asciiz "\n\nNao ha caracteres que se repetem por mais de tres vezes na matriz de entrada.\n "
saida5: .asciiz "\n\nA diagonal principal da matriz inserida eh:\n"
saida6: .asciiz "\nAs linhas que formam palindromos sao: "
saida6.1: .asciiz "\nLinha "
saida6.2: .asciiz ": "
saida7: .asciiz "\n\nMatriz de entrada com o conteudo das linhas impares trocadas:\n"
saida8: .asciiz "\nMatriz de entrada com o conteudo das colunas pares trocadas:\n"
saida9: .asciiz "\nMatriz de entrada ordenada na forma: minusculo, seguido por maiusculos e no final os caracteres especiais:\n"
.text
main:	
	
	la $a0, ent4
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall
	move $s1, $v0		# Numero de linhas ; $s1 <=> nlin
	
	la $a0, ent5
	li $v0, 4
	syscall
	
	li $v0, 5
	syscall
	move $s2, $v0		# Numero de colunas ; $s2 <=> ncol
	
	la $s0, Mat
	la $s3, mat1
	la $a0, Mat		# Endereco base de Mat
	move $a1, $s1		# Numero de linhas ; $a1 <=> nlin
	move $a2, $s2		# Numero de colunas ; $a2 <=> ncol
	jal leitura
	
	la $a0, saida1
	li $v0, 4
	syscall
	
	move $a0, $s0
	jal escrita
	
	la $a0, Mat		# Endereco base de Mat
	la $a2, mat1		# Endereco base de mat
	mul $a1, $s1, $s2
	jal inverte_vogais
	move $t0, $v0
	
	la $a0, saida2
	li $v0, 4
	syscall

	move $a1, $s1		# Numero de linhas ; $a1 <=> nlin
	move $a2, $s2		# Numero de colunas ; $a2 <=> ncol
	move $a0, $t0
	jal escrita
	
	la $a0, saida3
	li $v0, 4
	syscall
	
	move $a0, $v1
	li $v0, 1
	syscall
	
	la $a0, Mat		# Endereco base de Mat
	la $a2, mat1		# Endereco base de mat
	mul $a1, $s1, $s2
	jal caracteres_3x
	move $t0, $v0		# Endereco de mat
	move $t1, $v1		# Tamanho do vetor

	beqz $t1, pula_3x
	
	la $a0, saida4
	li $v0, 4
	syscall
	
	li $t2, 0
	p3x:
	add $t3, $t2, $t0
	lb $a0, ($t3)		# Carrega o caractere
	li $v0, 11		# Syscall pra imprimir caractere
	syscall
	li $a0, 32		# Espaco em ascii
	syscall
	addi $t2, $t2, 1
	blt $t2, $t1, p3x
	j pula_3x2
	pula_3x:
		la $a0, saida4.1
		li $v0, 4
		syscall
	pula_3x2:
	bne $s1, $s2, pula_funcao_diagonal # Pula se m != n
	la $a0, saida5
	li $v0, 4
	syscall
	move $a1, $s1		# Numero de linhas ; $a1 <=> nlin
	move $a2, $s2		# Numero de colunas ; $a2 <=> ncol
	move $a0, $s0
	jal diagonal_principal
	pula_funcao_diagonal:
	
	move $a0, $s0		# $a0 -> mat[0][0]
	addi $a1, $s2, -1
	add $a1, $a1, $a0	# $a1 -> mat[0][n-1}
	li $a3, 0		# i = 0
	li $t7, 0		# flag
	loop_palindromo:
	jal palindromo
	beqz $v0, falso_palindromo
	move $t6, $a0
	# Imprime a frase de saida se alguma linha formar um palindromo
	bnez $t7, pp
	la $a0, saida6
	li $v0, 4
	syscall
	li $t7, 1
	pp:
	la $a0, saida6.1
	li $v0, 4
	syscall
	move $a0, $a3
	li $v0, 1
	syscall
	la $a0, saida6.2
	li $v0, 4		# syscall pra imprimir inteiro
	syscall
	li $t0, 0		# i = 0
	loop_impressao_palindromo:
	add $t1, $t0, $t6
	lb $a0, ($t1)
	li $v0, 11
	syscall
	addi $t0, $t0, 1
	blt $t0, $s2, loop_impressao_palindromo	
	
	falso_palindromo:
	addi $a3, $a3, 1	# i++
	mul $a0,$a3 ,$s2	# $a0 = i * ncol
	add $a0, $a0, $s0	# mat[i][0]
	add $a1, $a0, $s2	# $a1 -> &mat[i][(i*n)+m]
	addi $a1, $a1, -1	# $a1 -> &mat[i][(i*n)+(m-1)]
	blt $a3, $s1, loop_palindromo
	
	move $a0, $s0
	move $a3, $s3
	move $a1, $s1
	move $a2, $s2
	jal copia_matriz
	
	move $a0, $s3
	move $a1, $s1
	move $a2, $s2
	jal inverte_linhas_impares
	
	la $a0, saida7
	li $v0, 4		# syscall pra imprimir string
	syscall
	
	move $a1, $s1		# Numero de linhas ; $a1 <=> nlin
	move $a2, $s2		# Numero de colunas ; $a2 <=> ncol
	move $a0, $s3
	jal escrita

	move $a0, $s0
	move $a3, $s3
	move $a1, $s1
	move $a2, $s2
	jal copia_matriz
	
	move $a0, $s3
	move $a1, $s1
	move $a2, $s2
	jal inverte_colunas_pares
	
	la $a0, saida8
	li $v0, 4		# syscall pra imprimir string
	syscall
	
	move $a1, $s1		# Numero de linhas ; $a1 <=> nlin
	move $a2, $s2		# Numero de colunas ; $a2 <=> ncol
	move $a0, $s3
	jal escrita
	
	la $a0, saida9
	li $v0, 4		# syscall pra imprimir string
	syscall
	
	mul $a1, $s1, $s2	# Envia o tamanho do vetor como parametro
	jal ordenacao
	
	move $a1, $s1		# Numero de linhas ; $a1 <=> nlin
	move $a2, $s2		# Numero de colunas ; $a2 <=> ncol
	move $a0, $s3
	jal escrita
					
	li $v0, 10		# Codigo pra finalizar o programa
	syscall
	
indice:
	mult $t0, $a2 		# i * ncol (essa formula serve pra "pular" as linhas anteriores)
	mflo $v0
	add $v0, $v0, $t1	# (i*ncol) + j
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
	
	li $v0, 12		# Codigo de leitura de caractere
	syscall
	move $t2, $v0
	jal indice		# Calcula o endereco de Mat[i][j]
	move $t3, $v0
	sb $t2, ($t3)		# mat[i][j] = aux
	
	li $a0, 10
	li $v0, 11		# Syscall pra imprimir caractere
	syscall
	
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
	lb $a0, ($t3)		# Valor em Mat[i][j]
	li $v0, 11		# Codigo pra imprimir caractere
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
	
inverte_vogais:
	move $a3, $a0		# Endereco da matriz
				# $a1 -> n
	li $t0, 0		# i
	li $t7, 0		# contador de vogais
	l_inverte:
	add $t1, $t0, $a3
	lb $t1, ($t1)		# vet[i]
	add $t2, $t0, $a2	# &vet2[i]
	# Verifica se eh vogal minuscula, se for, troca pra maiuscula e pula o resto do loop
	li $t3, 0		# j = 0
	l_interno_inverte:
	
	la $t4, vog1
	add $t4, $t3, $t4
	lb $t4, ($t4)		# $t4 -> vog1[j]
	
	la $t5, vog2
	add $t5, $t3, $t5		
	lb $t5, ($t5)		# $t5 -> vog2[j]
	
	bne $t4, $t1, lii	# pula se vet[i] != vog1[j]
	# Aqui eh o caso de vet[i] ser uma vogal. Vai trocar por maiusculo:	
	sb $t5, ($t2)		# Guarda no segundo vetor
	addi $t7, $t7, 1	# cont++
	j fim_lii		# pula pro fim do loop
	lii:
	bne $t1, $t5, lii2
	addi $t7, $t7, 1
	lii2:
	addi $t3, $t3, 1	# j++
	blt $t3, 5, l_interno_inverte
	
	# Se chegar aqui, vet[i] nao eh vogal minuscula. Assim so passo pro segundo vetor:
	sb $t1, ($t2)
	fim_lii:
	addi $t0, $t0, 1	# i++
	blt $t0, $a1, l_inverte
	
	move $v0, $a2
	move $v1, $t7
	jr $ra
	
caracteres_3x:
    	move $a3, $a0       # Endereco da matriz
                        # $a1 -> n (numero de elementos na matriz original)
    	li $t0, 0           # i = 0
    	li $t6, 0           # k = 0 (indice para mat1)
    	la $t7, mat1        # $t7 -> Endereco de mat1

	lc3:
    	add $t1, $t0, $a3
    	lb $t1, ($t1)       # mat[i]
    	addi $t2, $t0, 1    # j = i + 1
    	li $t3, 1           # contador de repeticoes (comeca em 1)

	lc32:
    	add $t4, $t2, $a3
    	lb $t4, ($t4)       # mat[j]
    	bne $t1, $t4, plc32
    	addi $t3, $t3, 1    # contador++

    	blt $t3, 4, plc32   # So processa se repetiu mais de 3 vezes
    	# Verifica se ja esta em mat1
    	li $t5, 0           # indice de verificacao
	verifica_dup:
    	beq $t5, $t6, add_caractere # Se chegamos ao final, nao ha duplicata
    	add $t8, $t5, $t7
    	lb $t8, ($t8)
    	beq $t1, $t8, fim_verifica_dup # Se ja existe, sai do loop
    	addi $t5, $t5, 1
    	j verifica_dup

	add_caractere:
    	add $t8, $t6, $t7
    	sb $t1, ($t8)       # Adiciona o caractere a mat1
    	addi $t6, $t6, 1    # k++

	fim_verifica_dup:
    	j plc32

	plc32:
    	addi $t2, $t2, 1    # j++
    	blt $t2, $a1, lc32

    	addi $t0, $t0, 1    # i++
    	blt $t0, $a1, lc3

    	move $v0, $t7       # Retorna o endereco de mat1
    	move $v1, $t6       # Retorna o tamanho de mat1
    	jr $ra

	
diagonal_principal:
	addi $sp, $sp, -4	# Aloca espaco na pilha
	sw $ra, ($sp)		# Guarda o endereco de retorno pra main na pilha
	move $a3, $a0		# GUarda o endereco base de mat em $a3
	
	li $t0, 0		# i = 0 ; i <=> $t0
	li $t1, 0		# j = 0 ; j <=> $t1
	e2:
	li $v0, 11		# Codigo para impressao de caractere
	la $a0, 32		# Codigo ASCII para espaco
	syscall
	
	jal indice		# Calcula o endereco de Mat[i][j]		
	bne $t0, $t1, e2p
	move $t3, $v0
	lb $a0, ($t3)		# Valor em Mat[i][j]
	li $v0, 11		# Codigo pra imprimir caractere
	syscall
	e2p:
	beq $t0, $t1, e2p2
	li $v0, 11		# Codigo para impressao de caractere
	la $a0, 32		# Codigo ASCII para espaco
	syscall
	e2p2:
	li $v0, 11		# Codigo para impressao de caractere
	la $a0, 32		# Codigo ASCII para espaco
	syscall
	
	addi $t1, $t1, 1	# j++
	
	blt $t1, $a2, e2		# if(j < ncol) goto e
	
	li $v0, 11		# Codigo para impressao de caractere
	la $a0, 10		# Codigo ASCII para new line ('\n')
	syscall
	
	li $t1, 0 		# j = 0
	add $t0, $t0, 1		# i++ (pula a linha)7
	blt $t0, $a1, e2		# if(i < nlin) goto e
	li $t0, 0		# i = 0
	lw $ra, ($sp)		# Recupera o retorno para a main
	addi $sp, $sp, 4	# Libera o espaco para a pilha
	move $v0, $a3		# Retorna o endereco base da matriz
	jr $ra			# Retorna para a main
	
palindromo:
	move $t1, $a0		# $t0 -> &str[0]
	move $t2, $a1		# $t2 -> &str[n-1] (j)
	
	loop_pal:
	ble $t2, $t1, true_pal 	# if (j <= i) goto true_pal
	lb $t4, ($t1)		# $t4 -> str[i]
	lb $t5, ($t2)		# $t5 -> str[j]
	bne $t4, $t5, false_pal	# if(str[i] != str[j]) goto false_pal
	addi $t1, $t1, 1	# i++
	addi $t2, $t2, -1	# j--
	j loop_pal
	
	true_pal:
	li $v0, 1
	jr $ra
	
	false_pal:
	li $v0, 0
	jr $ra
	
copia_matriz:
	move $t6, $a0		# $t6 -> mat1
	move $t7, $a3		# $t7 -> mat2
	# $a1 -> nlin
	# $a2 -> ncol
	li $t0, 0		# i = 0 ; i <=> $t0
	li $t1, 0		# j = 0 ; j <=> $t1
	subi $sp, $sp, 4	# Espaco para 1 item na pilha
	sw $ra, ($sp)		# Salva o retorno para a main
	move $a3, $a0		# aux = endereco base de Mat
	loop_copia:
	move $a3, $t6
	jal indice
	move $t2, $v0		# &mat1[i][j]
	move $a3, $t7
	jal indice
	move $t3, $v0		# &mat2[i][j]
	lb $t2, ($t2)
	sb $t2, ($t3)
	
	addi $t1, $t1, 1
	blt $t1, $a2, loop_copia
	li $t1, 0
	addi $t0, $t0, 1
	blt $t0, $a1, loop_copia
	li $t0, 0
	
	move $v0, $t7
	lw $ra, ($sp)
	addi $sp, $sp 4
	jr $ra
	
	

inverte_linhas_impares:
	addi $sp, $sp, -4	# Aloca espaco na pilha
	sw $ra, ($sp)		# Guarda o endereco de retorno pra main na pilha
	move $a3, $a0		# Endereco da matriz
				# $a1 -> nlin
				# $a2 -> ncol
	li $t3, 1		# i
	li $t1, 0		# j
	# while(i<m)
	loop_inveter_impares:
	addi $t2, $t3, 2	# i + 2
	# if((i+2)<m)
	bge $t2, $a1, fim_if_inverte_impares
	li $t1, 0		# j = 0
	loop_insersao:
	move $t0, $t3
	jal indice
	move $t4, $v0		# &mat[i][j]
	
	move $t0, $t2
	jal indice
	move $t5, $v0		# &mat[i+2][j]
	# inverte os elementos
	lb $t6, ($t4)
	lb $t7, ($t5)
	sb $t6, ($t5)
	sb $t7, ($t4)
	
	addi $t1, $t1, 1
	blt $t1, $a2, loop_insersao
	
	fim_if_inverte_impares:
	addi $t3, $t3, 4	# i+=4
	blt $t3, $a1, loop_inveter_impares
	
	move $v0, $a3
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
	
inverte_colunas_pares:
	addi $sp, $sp, -4	# Aloca espaco na pilha
	sw $ra, ($sp)		# Guarda o endereco de retorno pra main na pilha
	move $a3, $a0		# Endereco da matriz
				# $a1 -> nlin
				# $a2 -> ncol
	li $t0, 0		# i
	li $t3, 0		# j
	# while(j<m)
	loop_inveter_pares:
	addi $t2, $t3, 2	# j + 2
	# if((j+2)<m)
	bge $t2, $a2, fim_if_inverte_pares
	li $t0, 0		# i = 0
	loop_insersao2:
	move $t1, $t3
	jal indice
	move $t4, $v0		# &mat[i][j]
	
	move $t1, $t2
	jal indice
	move $t5, $v0		# &mat[i+2][j]
	# inverte os elementos
	lb $t6, ($t4)
	lb $t7, ($t5)
	sb $t6, ($t5)
	sb $t7, ($t4)
	
	addi $t0, $t0, 1
	blt $t0, $a1, loop_insersao2
	
	fim_if_inverte_pares:
	addi $t3, $t3, 4	# j+=4
	blt $t3, $a2, loop_inveter_pares
	
	move $v0, $a3
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
	
ordenacao:
	# $s0 -> endereco do vetor principal
	# $s3 -> endereco do vetor onde serao carregados os valores ordenados
	# $a1 -> n
	
	# as letras minusculas em ascii ficam entre (97,122)
	# as letras maiusculas em ascii ficam entre (65, 90)
	li $t7, 0		# k = 0
	# Primeira parte da funcao vou guardar todas as letras minusculas no vetor
	li $t0, 0		# i = 0
	loop_ordenacao_1:
	add $t1, $s0, $t0
	lb $t1, ($t1)
	blt $t1, 97, fim_loop_1
	bgt $t1, 122, fim_loop_1
	# Se chegar aqui, eh uma letra minuscula
	add $t2, $t7, $s3
	sb $t1, ($t2)	
	addi $t7, $t7, 1	# k++
	fim_loop_1:
	addi $t0, $t0, 1	# i++
	blt $t0, $a1, loop_ordenacao_1
	
	# Segunda parte da funcao vou guardar todas as letras maiusculas no vetor
	li $t0, 0		# i = 0
	loop_ordenacao_2:
	add $t1, $s0, $t0
	lb $t1, ($t1)
	blt $t1, 65, fim_loop_2
	bgt $t1, 90, fim_loop_2
	# Se chegar aqui, eh uma letra maiuscula
	add $t2, $t7, $s3
	sb $t1, ($t2)	
	addi $t7, $t7, 1	# k++
	fim_loop_2:
	addi $t0, $t0, 1	# i++
	blt $t0, $a1, loop_ordenacao_2	
	
	# Terceira parte da funcao vou guardar tudo que nao eh letra no vetor
	li $t0, 0		# i = 0
	loop_ordenacao_3:
	add $t1, $s0, $t0
	lb $t1, ($t1)
	bge $t1, 97, maior_97
	retorno1:
	bge $t1, 65, maior_65
	retorno2:
	# Se chegar aqui, nao eh uma letra
	add $t2, $t7, $s3
	sb $t1, ($t2)	
	addi $t7, $t7, 1	# k++
	fim_loop_3:
	addi $t0, $t0, 1	# i++
	blt $t0, $a1, loop_ordenacao_3
	
	jr $ra
	
	maior_97:
	ble $t1, 122, fim_loop_3
	j retorno1
	
	maior_65:
	ble $t1, 90, fim_loop_3
	j retorno2
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
