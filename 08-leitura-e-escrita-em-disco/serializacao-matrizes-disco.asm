# =======================================================================================
# Titulo: Serializacao e Deserializacao de Tensores (Matrizes)
# Descricao: Interpreta os metadados (m e n) iniciais de um ficheiro para alocar e 
# processar uma matriz, convertendo valores numericos para ASCII na escrita.
# Analise de Computabilidade: O sistema opera com previsibilidade total, alocando 
# espacos de iteracao finitos baseados na definicao estrutural do proprio ficheiro. 
# A conversao int-to-ASCII funciona como uma sub-rotina total, sem loops infinitos.
# Aplicacao: Persistencia de pesos de tensores na extracao de caracteristicas e 
# preparacao de dados em lote para avaliacao offline em modelos de machine learning.
# Referência na documentação: "atividade-mips-11.pdf"
# =======================================================================================

.data
entrada: .asciiz "7.4_entrada.txt"
saida: .asciiz "7.4_saida.txt"
espaco: .asciiz " "
quebra_linha: .asciiz "\n"
buffer: .space 1


.text
main:	
	# Abre o arquivo de leitura:
	li $v0, 13
	la $a0, entrada
	li $a1, 0
	li $a2, 0
	syscall
	move $s0, $v0		# Guarda o descritor do arquivo de entrada em $s0
	
	# Abre o arquivo de saida:
	li $v0, 13
	la $a0, saida
	li $a1, 1
	li $a2, 0
	syscall
	move $s1, $v0		# Guarda o descritor do arquivo de saida em $s1
	
	# Le o numero de linhas da matriz:
	ler_linhas:
	jal ler_caractere	# Le um caractere e deixa no buffer
	beq $v0, 32, ler_linhas
	subi $s2, $v0, 48	# $s2: numero m de linhas
	
	# Le o numero de colunas da matriz:
	ler_colunas:
	jal ler_caractere	# Le um caractere e deixa no buffer
	beq $v0, 32, ler_colunas
	subi $s3, $v0, 48	# $s3: numero n de colunas
	
	# Le o numero de posicoes que serao anuladas:
	ler_posicoes:
	jal ler_caractere	# Le um caractere e deixa no buffer.
	beq $v0, 32, ler_posicoes
	subi $s4, $v0, 48	# $s4: numero x de posicoes.
	
	# Aloca memoria da matriz:
	li $v0, 9
	mul $a0, $s2, $s3
	sll $a0, $a0, 2
	syscall
	move $s5, $v0		# $s5: vetor
	beqz $s5, erro_memoria
	
	# Preenche o vetor com 1:
	li $t0, 0
	mul $t1, $s2, $s3
	loop_1:
	sll $t2, $t0, 2
	add $t2, $t2, $s5
	li $t3, 1
	sw $t3, ($t2)
	addi $t0, $t0, 1
	blt $t0, $t1, loop_1
	
	# Funcao para anular as posicoes:
	move $a0, $s5		# Passa o endereco do vetor como parametro
	mul $a1, $s2, $s3	# Passa o tamanho do vetor como parametro
	move $a2, $s4		# Passa o numero de elementos que serao anulados
	move $a3, $s3		# Passa o numero de colunas da matriz
	jal anula
	
	# Funcao para escrever a matriz no arquivo:
	move $a0, $s1		# Passa o descritor do arquivo como parametro
	move $a1, $s5		# Passa o vetor como parametro
	move $a2, $s2		# Passa o numero de linhas como parametro
	move $a3, $s3		# Passa O numero de colunas como parametro
	jal escrita
	
	move $a0, $s0
	li $v0, 16
	syscall
	
	move $a0, $s1
	li $v0, 16
	syscall
	
	li $v0, 10
	syscall
#####################################################
ler_caractere:
	li $v0, 14
	move $a0, $s0
	la $a1, buffer
	li $a2, 1
	syscall
	lb $v0, ($a1)		# Retorna o endereco do buffer
	addi $s7, $s7, 1
	jr $ra		# Retorna
#####################################################	
anula:
	# $a0: vetor
	# $a1: tamanho do vetor
	# $a2: quantidade de elementos a serem anulados
	# $a3: numero de colunas da matriz
	li $t0, 0
	subi $sp, $sp, 4
	sw $ra, ($sp)
	move $t7, $a0
	move $t6, $a2
	loop_anula:
	
	ler_linha:
	jal ler_caractere
	beq $v0, 10, ler_linha		# le de novo se for \n
	beq $v0, 32, ler_linha		# Le de novo se for espaco
	blt $v0, 48, ler_linha		# ignora se nao for um digito
	subi $t1, $v0, 48		# $t1: i linha
	
	ler_coluna:
	jal ler_caractere
	beq $v0, 10, ler_coluna		# le de novo se for \n
	beq $v0, 32, ler_coluna		# Le de novo se for espaco
	blt $v0, 48, ler_coluna		# ignora se nao for um digito
	subi $t2, $v0, 48		# $t2: j coluna
	
	mul $t3, $t1, $a3
	add $t3, $t3, $t2
	
	sll $t3, $t3, 2
	add $t3, $t3, $t7
	sw $zero, ($t3)			
	
	addi $t0, $t0, 1	
	blt $t0, $t6, loop_anula
	
	# Retorna:
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
#####################################################
escrita:
    # $a0: descritor do arquivo
    # $a1: endereco do vetor 	-> $t6
    # $a2: num. linhas	  	-> $t7
    # $a3: num. colunas
    move $t6, $a1           # Salva endereco do vetor em $t6
    move $t7, $a2           # Salva numero de linhas em $t7
    move $t8, $a3           # Salva numero de colunas em $t8

    li $t0, 0               # i = 0 (contador de linhas)
loop_linhas:
    li $t1, 0               # j = 0 (contador de colunas)
loop_colunas:
    # Calcula o indice (i * n_colunas + j) * 4
    mul $t2, $t0, $t8       # i * n_colunas
    add $t2, $t2, $t1       # + j
    sll $t2, $t2, 2         # * 4 (tamanho de word)
    add $t2, $t2, $t6       # + endereco base
    lw $t2, ($t2)           # Carrega o valor da matriz

    # Converte o valor para ASCII
    addi $t2, $t2, 48
    sb $t2, buffer          # Armazena no buffer

    # Escreve o numero no arquivo
    li $v0, 15              # Syscall para escrever no arquivo
    move $a0, $s1           # Descritor do arquivo
    la $a1, buffer          # Buffer com o numero
    li $a2, 1               # 1 byte a ser escrito
    syscall

    # Verifica se eh a ultima coluna para evitar espaco extra
    addi $t9, $t1, 1        # Proxima coluna
    bge $t9, $t8, pula_espaco  # Se for a ultima coluna, pula o espaco

    # Escreve um espaco apos o numero
    li $t3, 32              # ASCII para espaco
    sb $t3, buffer          # Armazena no buffer
    li $v0, 15              # Syscall para escrever no arquivo
    syscall

pula_espaco:
    addi $t1, $t1, 1        # Incrementa j
    blt $t1, $t8, loop_colunas  # Repete para todas as colunas

    # Escreve uma quebra de linha apos cada linha
    li $t3, 10              # ASCII para \n
    sb $t3, buffer          # Armazena no buffer
    li $v0, 15              # Syscall para escrever no arquivo
    syscall

    addi $t0, $t0, 1        # Incrementa i
    blt $t0, $t7, loop_linhas  # Repete para todas as linhas

    jr $ra                  # Retorna
erro_memoria:
	li $v0, 10
	syscall
