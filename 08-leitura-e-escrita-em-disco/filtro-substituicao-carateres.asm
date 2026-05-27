# =======================================================================================
# Titulo: Transdutor de Ofuscacao de Ficheiros de Texto
# Descricao: Leitura de um ficheiro de entrada caractere a caractere, substituindo 
# todas as vogais por um caractere de mascara ('*') e gravando o resultado num novo 
# ficheiro de saida.
# Analise de Computabilidade: Implementa o conceito de Maquina de Mealy (Transdutor de 
# Estado Finito). A cada transicao, o automato avalia o simbolo lido e mapeia para o 
# alfabeto de saida. O tempo de execucao e estritamente linear O(n), limitado pelo 
# marcador de fim de ficheiro (EOF).
# Aplicacao: Sanitizacao de conjuntos de dados (data sanitization), ofuscacao de 
# assinaturas em ficheiros e pre-processamento em pipelines de seguranca.
# Referência na documentação: "atividade-mips-11.pdf"
# =======================================================================================

.data
entrada: .asciiz "7.2_entrada.txt"
saida: .asciiz "7.2_saida.txt"
vogais: .asciiz "aeiouAEIOU"
asterisco: .asciiz "*"
mensagem_erro_abrir: .asciiz "\nErro ao abrir arquivo!"
.align 1
buffer: .space 1

.text
	# Abrir arquivo de entrada - apenas para leitura:
	li $v0, 13
	la $a0, entrada
	li $a1, 0		# Abrindo o arquivo para leitura
	li $a2, 0
	syscall
	bltz $v0, erro_abrir
	move $s0, $v0		# Guarda o descritor do arquivo de entrada em $s0
	
	# Abrir arquivo para escrita:
	li $v0, 13
	la $a0, saida
	li $a1, 1
	li $a2, 0
	syscall
	bltz $v0, erro_abrir
	move $s1, $v0		# Gruada o descritor do arquivo de saida em $s1.
	
	loop_transcricao:
	# Le um caractere do arquivo:
	move $a0, $s0
	la $a1, buffer
	li $a2, 1
	li $v0, 14
	syscall
	# Verifica se acabou o conteudo do arquivo:
	blez $v0, fim_loop
	
	# Altera o caractere do buffer se necessario:
	jal verificao_transcricao
	
	# Grava no outro arquivo:
	li $v0, 15
	move $a0, $s1
	la $a1, buffer
	li $a2, 1
	syscall
	
	# Volta para o comeco do loop:
	j loop_transcricao
	
	fim_loop:
	# Fecha os arquivos:
	li $v0, 16
	move $a0, $s0
	syscall
	move $a0, $s1
	syscall
	
	fim_programa:
	li $v0, 10
	syscall
	
	
	# Printa mensagem de erro ao abrir:
	erro_abrir:
	la $a0, mensagem_erro_abrir
	li $v0, 4
	syscall
	
	j fim_programa
	
	
	verificao_transcricao:
	lb $t1, buffer
	li $t2, 0
	loop_verificacao:
	la $t4, vogais
	add $t3, $t2, $t4
	lb $t3, ($t3)
	beq $t3, $t1, substituicao
	addi $t2, $t2, 1
	blt $t2, 10, loop_verificacao
	
	jr $ra
	
	substituicao:
	lb $t5, asterisco
	sb $t5, buffer
	jr $ra
	
	
	
	
	
	
	
	
	
	
	
	