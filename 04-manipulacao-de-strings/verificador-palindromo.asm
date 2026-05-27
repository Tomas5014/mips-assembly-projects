# =======================================================================================
# Titulo: Verificador de Palindromos (Abordagem de Dois Ponteiros)
# Descricao: Recebe uma string, remove o carater de nova linha e verifica se a palavra 
# e um palindromo, ou seja, se a sequencia de carateres e identica quando lida 
# da esquerda para a direita e vice-versa.
# Analise de Computabilidade: Trata-se de um problema de decisao resolvido em 
# tempo linear O(n). A implementacao utiliza uma abordagem de dois ponteiros 
# (inicio e fim) que convergem para o centro da cadeia de carateres na memoria. 
# O problema e estritamente decidivel e condicionado ao tamanho finito da string.
# Aplicacao: Filtragem de dados textuais e validacao de padroes estruturais em 
# algoritmos de seguranca da informacao e analise de sequencias.
# Referência na documentação: "atividade-mips-06.pdf"
# =======================================================================================

.data
ent: .asciiz "Insira uma palavra: "
str: .space 100
saida_true: .asciiz "A palavra inserida eh um palindromo.\n"
saida_false: .asciiz "A palavra inserida NAO eh um palindromo.\n"
.text
main:
	la $a0, ent		# Endereco da mensagem
	la $a1, str		# Endereco da string
	jal leitura 		# leitura (mensagem, string)
		
	la $a0, str		# Parametro: endereco da string 1
	jal palindromo		# palindromo (str)
	move $a0, $v0		# Retorna true (1) ou false (0) 
	beqz $a0, false
	
	true:
	la $a0, saida_true
	li $v0, 4
	syscall	
	j fim_programa
	
	false:
	la $a0, saida_false
	li $v0, 4
	syscall
	
	fim_programa:	
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
	
palindromo:
	move $t1, $a0		# $t0 -> &str[0]
	
	# Funcao para encontrar &str[n-1] (n = tamanho de str[]), considerando que o "\n" foi tirado na leitura:
	addi $t2, $a0, -1
	loop_p:
	addi $t2, $t2, 1
	lb $t3, ($t2)
	bnez $t3, loop_p
	addi $t2, $t2, -1	# $t2 -> &str[n-1] (j)
	
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
	
	
	
	
	
	
