# =======================================================================================
# Titulo: Validador de Identificacao (Algoritmo de Verificacao de CPF)
# Descricao: Extrai os digitos numericos de uma string formatada e aplica a regra 
# matematica de validacao de integridade atraves de multiplicacoes modulares.
# Analise de Computabilidade: O algoritmo atua como um reconhecedor formal de 
# linguagens regulares. O processamento e estritamente finito e deterministico, 
# mapeando uma cadeia de entrada para um estado de aceitacao (valido) ou 
# rejeicao (invalido) em tempo constante O(1), dado que o tamanho da entrada e fixo.
# Aplicacao: Sanitizacao de dados e validacao de inputs em interfaces de seguranca 
# cibernetica, prevenindo injecoes maliciosas e exploracao de vulnerabilidades.
# Referência na documentação: "atividade-mips-08.pdf"
# =======================================================================================

.data
buffer: .space 15                  # Espaco para armazenar o CPF digitado como string (ex: "123.456.789-10")
cpf: .space 11                     # Espaco para armazenar apenas os digitos numericos
ent: .asciiz "Digite o CPF (formato XXX.XXX.XXX-XX): "
saida_true: .asciiz "O CPF inserido eh valido!"
saida_false: .asciiz "O CPF inserido NAO eh valido!"
.text
main:
	# Imprime mensagem de entrada
    	li $v0, 4
    	la $a0, ent
    	syscall

	# Le o CPF como string
    	li $v0, 8
    	la $a0, buffer
    	li $a1, 15                  # Limite de 14 caracteres para o CPF com pontuacao + terminador
    	syscall

	la $a0, buffer              # Ponteiro para o buffer de entrada
    	la $a1, cpf                 # Ponteiro para o vetor onde os numeros serao armazenados
	jal filtro
	
	move $a0, $v0
	jal verificar
	move $t0, $v0
	
	beqz $t0, pulofalse
	la $a0, saida_true
	li $v0, 4
	syscall
	j fim
	
	pulofalse:
	la $a0, saida_false
	li $v0, 4
	syscall
	
	fim:	
	# Termina o programa
    	li $v0, 10
    	syscall
	
filtro:
    	# Filtra e armazena apenas os numeros
    	move $t0, $a0              # Ponteiro para o buffer de entrada
    	move $t1, $a1                 # Ponteiro para o vetor onde os numeros serao armazenados
    	li $t2, 0                   # Contador de digitos do CPF

filtro_loop:
    	lb $t3, 0($t0)              # Le o proximo caractere
    	beq $t3, 0, fim_loop_filtro       # Termina se for o final da string

    	# Verifica se eh um digito numerico (entre '0' e '9')
    	li $t4, 48                  # ASCII '0'
    	li $t5, 57                  # ASCII '9'
    	bge $t3, $t4, check_digito
    	j prox_caractere

check_digito:
    	ble $t3, $t5, store_digito   # Se $t3 esta entre '0' e '9', armazena o digito
    	j prox_caractere

store_digito:
    	sub $t3, $t3, 48            # Converte de ASCII para valor numerico
    	sb $t3, 0($t1)              # Armazena o digito no buffer cpf
    	addi $t1, $t1, 1            # Avanca o ponteiro de armazenamento
    	addi $t2, $t2, 1            # Incrementa o contador de digitos

prox_caractere:
    	addi $t0, $t0, 1            # Avanca para o proximo caractere no buffer
    	j filtro_loop

fim_loop_filtro:
    	move $v0, $a1
    	jr $ra
    	
verificar:
	move $a3, $a0
	# Digito 1:
	li $t0, 0	# i
	li $t1, 10	# j
	li $t7, 0	# soma
digito_1:
	# Pega vet[i]:
	add $t2, $a3, $t0
	lb $t2, 0($t2)
    	
    	mul $t3, $t2, $t1	# $t3 = vet[i] * j
    	add $t7, $t7, $t3	# soma += (vet[i] * j)
    	subi $t1, $t1, 1	# j--
    	addi $t0, $t0, 1	# i++
    	blt $t0, 9, digito_1
    	
	add $t0, $a3, $t0
	lb $t0, 0($t0)
	
    	li $t4, 11		
    	div $t7, $t4
    	mfhi $t4		# $t4 = soma%11
    	blt $t4, 2, menor_que_dois
    	li $t5, 11
    	sub $t5, $t5, $t4
    	bne $t5, $t0, erro
    	retorno1:

# Digito 1:
	li $t0, 0	# i
	li $t1, 11	# j
	li $t7, 0	# soma
digito_2:
	# Pega vet[i]:
	add $t2, $a3, $t0
	lb $t2, 0($t2)
    	
    	mul $t3, $t2, $t1	# $t3 = vet[i] * j
    	add $t7, $t7, $t3	# soma += (vet[i] * j)
    	subi $t1, $t1, 1	# j--
    	addi $t0, $t0, 1	# i++
    	blt $t0, 10, digito_2
    	
	add $t0, $a3, $t0
	lb $t0, 0($t0)
	
    	li $t4, 11		
    	div $t7, $t4
    	mfhi $t4		# $t4 = soma%11
    	blt $t4, 2, menor_que_dois1
    	li $t5, 11
    	sub $t5, $t5, $t4
    	bne $t5, $t0, erro
    	retorno2:
    	###########
    	li $v0, 1
	jr $ra
    	###########
menor_que_dois:
	beqz $t0, retorno1
	j erro

menor_que_dois1:
	beqz $t0, retorno1
	j erro		
erro:
	li $v0, 0
	jr $ra


