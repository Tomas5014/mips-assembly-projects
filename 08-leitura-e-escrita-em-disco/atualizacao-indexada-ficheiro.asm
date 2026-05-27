# =======================================================================================
# Titulo: Acesso Indexado e Atualizacao Direta em Ficheiro
# Descricao: Abre um ficheiro de dados, localiza o elemento na i-esima posicao de 
# um vetor persistido, incrementa o seu valor e atualiza a informacao em disco.
# Analise de Computabilidade: Demonstra o mapeamento do modelo de Maquina de Acesso 
# Aleatorio (RAM) sobre o armazenamento secundario. O algoritmo calcula o deslocamento 
# (offset) exato, realizando a atualizacao do estado interno de forma deterministica 
# e em tempo constante O(1) apos o calculo do ponteiro.
# Aplicacao: Atualizacao de indices em bases de dados de alto desempenho e rastreamento 
# dinamico de estados em sistemas de monitorizacao de fluxos continuos (stream mining).
# Referência na documentação: "atividade-mips-11.pdf"
# =======================================================================================

.data
arquivo: .asciiz "7.3_dados.txt"
entrada: .asciiz "Insira a posicao do arquivo que voce quer incrementar: "
m_erro_abrir: .asciiz "\nErro ao abrir arquivo!"
m_erro_ler: .asciiz "\nErro ao ler arquivo!"
espaco: .asciiz " "
quebra_linha: .asciiz "\n"
menos: .asciiz "-"
.align 1
buffer: .space 12
.align 4
vetor: .space 400

.text
	# Abre arquivo para leitura:
	li $v0, 13		# Codigo Syscall para leitura
	la $a0, arquivo		# Passa o endereco do arquivo
	li $a1, 0		# Codigo para leitura.
	li $a2, 0		# Codigo 0 (ignora) 
	syscall
	bltz $v0, erro_abrir
	move $s0, $v0		# Descritor do arquivo de entrada: $s0
	
	# Recebe a posicao do arquivo:
	li $v0, 4
	la $a0, entrada
	syscall
	
	li $v0, 5
	syscall
	move $s3, $v0
	
	# Funcao para conveter para vetor:
	move $a0, $s0
	la $a1, buffer
	li $a2, 1		# Caracteres por leitura
	la $a3, vetor
	jal transporte_vetor	# Retorna o endereco do vetor em $v0 e o numero tamanho do vetor em $v1
	move $s1, $v0
	move $s2, $v1
	
	#teste tamanho: 
#	li $v0, 1
#	move $a0, $s2
#	syscall
	
	# Incrementa o numero na posicao do vetor:
	sll $t0, $s3, 2
	add $t0, $t0, $s1
	lw $t1, ($t0)
	addi $t1, $t1, 1
	sw $t1, ($t0)
	
	#### TESTE:
	li $t0, 0
	loop_printar_vetor:
	sll $t1, $t0, 2
	add $t1, $t1, $s1
	lw $a0, ($t1)
	li $v0, 1
	syscall
	li $v0, 4
	la $a0, espaco
	syscall
	addi $t0, $t0, 1
	blt $t0, $s2, loop_printar_vetor
	
	# Fecha o arquivo:
	li $v0, 16
	move $a0, $s0
	syscall
	
	# Abre arquivo para escrita:
	li $v0, 13
	la $a0, arquivo
	li $a1, 1		# Codigo para escrita.
	li $a2, 0
	syscall
	bltz $v0, erro_abrir
	move $s0, $v0		# Descritor do arquivo: $s0
	
	# Transforma o vetor em string e depois printa no arquivo:
	li $t0, 0           # indice i = 0

loop_escrita:
    # Sair do loop quando percorrer todo o vetor
    bge $t0, $s2, fim_escrita

    # Pegar o proximo elemento do vetor
    sll $t1, $t0, 2     # Multiplica i por 4 (indice para acessar vetor)
    add $t2, $s1, $t1   # Calcula endereco vetor[i]
    lw $a0, 0($t2)      # Carrega o numero
    
    # Converter numero inteiro para string
    la $a1, buffer      # Endereco do buffer para conversao
    jal int_para_string # Chama funcao de conversao
    
    ### TESTE
    
#    li $v0, 4
#    la $a0, espaco
#    syscall
    
#    la $a0, buffer
#    syscall
    
    #########
    
    # Escrever numero convertido no arquivo
    li $v0, 15          # Syscall para escrever em arquivo
    move $a0, $s0       # Descritor do arquivo
    #la $a1, buffer      # Endereco da string
    move $a2, $t5          # Tamanho maximo da string
    syscall

    # Incrementar indice e repetir
    addi $t0, $t0, 1
    
    # Sair do loop quando percorrer todo o vetor
    bge $t0, $s2, fim_escrita
    
    # Escrever espaco entre os numeros
    li $v0, 15
    move $a0, $s0
    la $a1, espaco
    li $a2, 1
    syscall

    
    j loop_escrita

fim_escrita:
    # Escrever quebra de linha no final
    li $v0, 15
    move $a0, $s0
    la $a1, quebra_linha
    li $a2, 1
    syscall

    # Fechar o arquivo
    li $v0, 16
    move $a0, $s0
    syscall

    # Encerrar o programa
    li $v0, 10
    syscall

# ---------------------------------------------------------
# Funcao: Converte inteiro para string
# Entrada: $a0 = numero, $a1 = buffer
# Saida: buffer preenchido com string do numero
# ---------------------------------------------------------
int_para_string:
    li $t3, 10          # Base decimal
    move $t4, $a1       # Posicao no buffer
    addi $t4, $t4, 11   # Aponta para o fim do buffer
    sb $zero, 0($t4)    # Adiciona terminador de string '\0'
    li $t5, 0           # Contador de digitos
    li $t6, 0           # Inicializa flag
    bltz $a0, negativo_detectado  
    j conversao_loop

negativo_detectado:
    li $t6, 1
    negu $a0, $a0       # Torna o numero positivo para conversao
    j conversao_loop
conversao_loop:
    # Obtem ultimo digito
    divu $a0, $t3
    mfhi $t2           # Resto (ultimo digito)
    mflo $a0           # Quociente

    # Converte para caractere ASCII
    addi $t2, $t2, 48  # '0' = 48 na tabela ASCII

    # Armazena no buffer
    addi $t4, $t4, -1
    sb $t2, 0($t4)

    # Contabiliza um digito
    addi $t5, $t5, 1

    # Repete ate que $a0 seja 0
    bnez $a0, conversao_loop
    
    # adiciona "-" se negativo:
    beqz $t6, pula_sinal
    addi $t4, $t4, -1
    li $t2, 45
    sb $t2, 0($t4)
    addi $t5, $t5, 1
    pula_sinal:
    
    # Retorna buffer ajustado para o inicio do numero
    move $a1, $t4
    move $v0, $t5		# Retorna o tamanho da string
    jr $ra
    	
	
erro_abrir:
	li $v0, 4
	la $a0, m_erro_abrir
	syscall
	
	li $v0, 10
	syscall
	
erro_ler:
	li $v0, 4
	la $a0, m_erro_ler
	syscall
	
	li $v0, 10
	syscall	
	
transporte_vetor:
	# $a0 -> descritor do arquivo
	# $a1 -> buffer
	# $a2 -> caracteres por leitura: 1
	# $a3 -> vetor
	li $t2, 0		# indice i do vetor
	li $t1, 0
	li $t7, 0
	li $t4, 0		# COntador de digitos lidos
	loop_transporte:
	li $v0, 14		# Codigo para leitura
	syscall			# Faz a leitura de 1 caractere
	beqz $v0, fim_numero
	lbu $t0, ($a1)		# Carrega o byte lido do buffer
	beq $t0, 13, loop_transporte	# se for carrige return, ignora
	beq $t0, 32, fim_numero		# Se for espaco
	beq $t0, 10, fim_numero		# Se for \n
	beq $t0, 45, negativo		# Se for -
	subi $t0, $t0, 48	# Tabela ascii para transformar em decimal
	mul $t1, $t1, 10	# Casa decimal para esquerda
	add $t1, $t1, $t0	# Adicino o numero na casa decimal da direita
	addi $t4, $t4, 1
	j loop_transporte
		
	fim_numero:
	beqz $v0, fim_transporte
	# Guardar o numero no vetor
	sll $t3, $t2, 2
	add $t3, $t3, $a3
	# Se for negativo:
	bne $t7, 1, pula_negativo
	mul $t1, $t1, -1
	pula_negativo:
	sw $t1, ($t3)	
	li $t1, 0		# Zera o $t1 para guardar o proximo numero
	addi $t2, $t2, 1
	li $t7, 0
	bnez $t4, pula_subi
	subi $t2, $t2, 1	# Corrige o vetor se nao leu nenhum numero e nao acabou o arquivo 
	pula_subi:
	li $t4, 0
	j loop_transporte
	
	negativo:
	li $t7, 1		# flag para negativo
	j loop_transporte
	
	fim_transporte:
	move $v0, $a3
	move $v1, $t2
	jr $ra
	
	
	
	
	
	
	
