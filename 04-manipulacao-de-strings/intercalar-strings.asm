# =======================================================================================
# Titulo: Intercalacao de Strings em Memoria
# Descricao: Le duas strings da entrada padrao, higieniza os dados (removendo a quebra 
# de linha) e intercala os seus carateres sequencialmente numa terceira string 
# alocada estaticamente em memoria.
# Analise de Computabilidade: O processamento de cadeias de carateres (strings) 
# baseia-se na identificacao do terminador nulo ('\0'). O algoritmo atua como 
# um leitor de fita unidirecional, processando a informacao byte a byte (lb e sb). 
# A complexidade de tempo e linear O(n+m), assegurando a paragem do algoritmo.
# Aplicacao: Operacoes fundamentais de parseamento e formatacao de dados textuais, 
# cruciais na construcao de compiladores e na analise de fluxos de dados (streams).
# Referência na documentação: "atividade-mips-06.pdf"
# =======================================================================================

.data
ent1: .asciiz "Insira a string 1: "
ent2: .asciiz "Insira a string 2: "
str1: .space 100
str2: .space 100
str3: .space 200

.text
main:
	la $a0, ent1		# Endereco da mensagem
	la $a1, str1		# Endereco da string
	jal leitura 		# leitura (mensagem, string)
	
	la $a0, ent2		# Endereco da mensagem
	la $a1, str2		# Endereco da string
	jal leitura 		# leitura (mensagem, string)
	
	la $a0, str1		# Parametro: endereco da string 1
	la $a1, str2		# Parametro: endereco da string 2
	la $a2, str3		# Parametro: endereco da string 3
	jal intercala		# intercala (str1, str2, str3)
	move $a0, $v0		# Move a string retornada
	li $v0, 4		# Codigo para impressao de string
	syscall			# Imprime a string intercalada
	li $v0, 10		# Codigo para encerrar o programa
	syscall
	
leitura:
	li $v0, 4		# Codigo para impressao de string
	syscall			# Imprime a string
	move $a0, $a1		# Endereco da str
	li $a1, 100		# Numero maximo de caracteres a serem lidos
	li $v0, 8		# Codigo syscall para leitura de string
	syscall			# Faz a leitura da string

	# Vou remover o "\n" pra str3 nao ter uma quebra de linha se uma das strings for menor que a outra
	addi $t0, $a0, -1
	loop_n:
	addi $t0, $t0, 1
	lb $t1, ($t0)
	bnez $t1, loop_n
	addi $t0, $t0, -1
	li $t2, 0
	sb $t2, ($t0)
	
	jr $ra			# Retorna pra main
	
intercala:
	# $a0 -> edereco da str1
	# $a1 -> edereco da str2
	# $a2 -> edereco da str3
	move $t0, $a0		# $t0 -> str1[i]
	move $t1, $a1		# $t1 -> str2[j]
	move $t2, $a2		# $t2 -> str3[k]
	loop_intercala:
	lb $t3, ($t0)
	beqz $t3, fim_str1
	lb $t3, ($t1)
	beqz $t3, fim_str2
	lb $t4, ($t0)
	sb $t4, ($t2)
	addi $t2, $t2, 1
	lb $t4, ($t1)
	sb $t4, ($t2)
	addi $t2, $t2, 1
	addi $t0, $t0, 1
	addi $t1, $t1, 1
	j loop_intercala
	fim_str1:
	lb $t3, ($t1)
	beqz $t3, fim_intercala
	lb $t4, ($t1)
	sb $t4, ($t2)
	addi $t2, $t2, 1
	addi $t1, $t1, 1
	j fim_str1
	fim_str2:
	lb $t3, ($t0)
	beqz $t3, fim_intercala
	lb $t4, ($t0)
	sb $t4, ($t2)
	addi $t2, $t2, 1
	addi $t0, $t0, 1
	j fim_str2
	fim_intercala:
	li $t4, 0
	sb $t4, ($t2)
	move $v0, $a2
	jr $ra
	
	
	
	
