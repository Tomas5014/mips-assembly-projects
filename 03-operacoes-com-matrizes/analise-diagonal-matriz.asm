# =======================================================================================
# Titulo: Analise e Soma de Diagonal Secundaria em Matriz
# Descricao: O algoritmo mapeia uma matriz 3x3 e identifica os elementos pertencentes 
# a diagonal secundaria, calculando o somatorio dos mesmos atraves de um laco iterativo.
# Analise de Computabilidade: A identificacao dos elementos e feita em tempo deterministico
# atraves de operacoes logicas nos indices das coordenadas. O tempo de execucao e 
# polinomial O(n^2), garantindo a paragem do algoritmo sob as condicoes finitas do 
# espaco de enderecamento alocado na memoria estatica.
# Aplicacao: Conceito fundamental de algebra linear, aplicavel em extracao de 
# caracteristicas direcionais e analise vetorial em tensores bidimensionais.
# Referência na documentação: "atividade-mips-07.pdf"
# =======================================================================================

.data
mat: .space 36		# Matriz de inteiros 3x3 x 4
ent1: .asciiz "Insira o valor de Mat["
ent2: .asciiz "]["
ent3: .asciiz "]: "
saida1: .asciiz "Matriz inserida:\n"
saida2: .asciiz "A soma dos elementos da diagonal principal eh+: "

.text
main:
	la $a0, mat		# Endereco da matriz
	li $a1, 3		# Numero de linhas
	li $a2, 3		# Numero de colunas
	li $a3, 4		# n + 1
	
	jal leitura		# leitura($mat, 3, 3);
	move $t0, $v0
	move $s0, $v1
	
	la $a0, saida1		# Carrega o endereco da string
	li $v0, 4		# Syscall pra printar string
	syscall
	
	move $a0, $t0
	jal escrita 
	
	la $a0, saida2		# Carrega o endereco da string
	li $v0, 4		# Syscall pra printar string
	syscall
	
	li $v0, 1
	move $a0, $s0
	syscall
	
	li $v0, 10
	syscall
	
indice:
	mul $v0, $t0, $a2	# i * ncol
	add $v0, $v0, $t1	# (i * i) + j
	sll $v0, $v0, 2		# ((i * i) + j) * 4
	add $v0, $v0 $a3	# Soma com o endereco base
	jr $ra			# Retorna pra funcao
	
leitura:
	addi $sp, $sp, -4	# Aloca memoria na pilha
	sw $ra, ($sp)		# Salva o retorno pra main
	move $t3, $a3		# $t3 -> n + 1
	move $a3, $a0		# $a3 -> $mat
	li $t0, 0		# $t0 -> i
	li $t1, 0		# $t1 -> j
	li $t5, 0		# $t5 -> sum
l:
	la $a0, ent1		# Carrega o endereco da string
	li $v0, 4		# Syscall pra printar string
	syscall
	
	# Printa i:
	move $a0, $t0	
	li $v0, 1
	syscall
	
	la $a0, ent2		# Carrega o endereco da string
	li $v0, 4		# Syscall pra printar string
	syscall
	
	# Printa j:
	move $a0, $t1	
	li $v0, 1
	syscall
	
	la $a0, ent3		# Carrega o endereco da string
	li $v0, 4		# Syscall pra printar string
	syscall
	
	# Entrada de inteiro:
	li $v0, 5		
	syscall
	move $t2, $v0		# Guarda o valor lido em $t2
	
	# Verifica se esta na diagonal principal:
	add $t4, $t0, $t1	# $t4 = i + j
	addi $t4, $t4, 2
	bne $t3, $t4, nao_esta	# if ((j + i) != (n + 1)) goto nao_esta
	add $t5, $t5, $t2	# sum += mat[i][j]
	nao_esta:
	jal indice
	sw $t2 ($v0)		# Guarda na matriz
	addi $t1, $t1, 1	# j++
	blt $t1, $a2, l
	addi $t0, $t0, 1	# i++
	li $t1, 0		# j = 0
	blt $t0, $a1, l
	li $t0, 0		# i = 0
	lw $ra, ($sp)		# Recupera o endereco de retorno
	addi $sp, $sp, 4	# Desaloca a pilha
	move $v0, $a3		# Retona o endereco da matriz
	move $v1, $t5		# retorna sum
	jr $ra
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
	
	
