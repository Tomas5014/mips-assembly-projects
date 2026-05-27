# =======================================================================================
# Titulo: Agregacao Estatistica em Matrizes Dinamicas
# Descricao: Aloca uma matriz nx3 no heap para receber dados em virgula flutuante. 
# Calcula medias locais (linhas) e a media global da estrutura, separando as entidades 
# em classes baseadas num limiar de aceitacao (threshold).
# Analise de Computabilidade: Opera de forma equivalente a uma maquina de estados de 
# avaliacao. A alocacao contigua no heap preserva a localidade de referencia linear O(n*m).
# As divisoes em virgula flutuante sao estritamente protegidas por limites estruturais, 
# evitando bloqueios no Coprocessador 1 e assegurando a paragem do algoritmo.
# Aplicacao: Avaliacao iterativa de metricas de desempenho, agregacao estatistica de 
# tensores e processamento em lote (batch processing) no pre-treino de modelos de dados.
# Referência na documentação: "atividade-mips-09.pdf"
# =======================================================================================

.data
ent1: .asciiz "\nInsira a quantidade de alunos: "
ent2: .asciiz "Insira a nota "
ent3: .asciiz " do aluno "
ent4: .asciiz ": "
espaco: .asciiz " "
quebra_linha: .asciiz "\n"
saida1: .asciiz "\nA media do aluno "
saida2: .asciiz " eh: "
saida3: .asciiz "\n\nA media aritmetica da sala eh: "
saida4: .asciiz "\nO numero de alunos aprovados eh: "
saida5: .asciiz "\nO numero de alunos reprovados eh: "
.text
main:
	li $v0, 4
	la $a0 ent1
	syscall
	
	li $v0, 5
	syscall
	move $s1, $v0		# $s1 -> n
	
	mul $t0, $s1, 3		# multiplica n por 3 (numero de colunas)
	mul $t0, $t0, 4		# multiplica n*3 por 4 (tamanho do float)
	
	move $a0, $t0
	li $v0, 9
	syscall
	move $s0, $v0		# Endereco da matriz alocada
	
	li $s2, 3		# $s2 -> m
	
	move $a0, $s0		# Passa o endereco da matriz como parametro
	move $a1, $s1		# Passa o nlin como parametro
	move $a2, $s2		# Passa o ncol como parametro
	jal leitura
	
	move $a0, $s0		# Passa o endereco da matriz como parametro
	move $a1, $s1		# Passa o nlin como parametro
	move $a2, $s2		# Passa o ncol como parametro
	jal escrita
	
	move $a0, $s0		# Passa o endereco da matriz como parametro
	move $a1, $s1		# Passa o nlin como parametro
	move $a2, $s2		# Passa o ncol como parametro
	jal funcao
	
	li $v0, 10
	syscall
indice:
	mul $v0, $t0, $a2
	add $v0, $t1, $v0
	sll $v0, $v0, 2
	add $v0, $v0, $a3
	jr $ra	


leitura:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	move $a3, $a0		# $a3 -> endereco da matriz
	
	li $t0, 0		# i = 0
	li $t1, 0		# j = 0
	
	loop_leitura:
	# Imprime a mensagem de entrada:
	jal mensagem_leitura
	mov.s $f4, $f0		# nota
	
	jal indice
	move $t2, $v0
	s.s $f4, ($t2)
	
	addi $t1, $t1, 1
	blt $t1, $a2, loop_leitura
	li $t1, 0
	addi $t0, $t0, 1
	blt $t0, $a1, loop_leitura
	li $t0, 0
	
	lw $ra, ($sp)
	addi $sp, $sp 4
	jr $ra
	
mensagem_leitura:
	li $v0, 4
	la $a0, ent2
	syscall
	
	move $a0, $t1
	li $v0, 1
	syscall
	
	li $v0, 4
	la $a0, ent3
	syscall
	
	move $a0, $t0
	li $v0, 1
	syscall
	
	li $v0, 4
	la $a0, ent4
	syscall
	
	li $v0, 6
	syscall
	
	jr $ra
	
funcao:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	move $a3, $a0		# $a3 -> endereco da matriz
	
	li $t0, 0		# i = 0
	li $t1, 0		# j = 0
	mtc1 $t0, $f2
	cvt.s.w $f2, $f2	# soma de todas as notas
	li $t4, 0		# contador de aprovados 
	mov.s $f6, $f2		# soma para media do aluno
	li $t3, 6
	mtc1 $t3, $f8
	cvt.s.w $f8, $f8
	li $t3, 3
	mtc1 $t3, $f10
	cvt.s.w $f10, $f10
	loop_funcao:	
	jal indice
	move $t2, $v0
	l.s $f12, ($t2)
	
	add.s $f2, $f2, $f12		# somaDeTodasAsNotas+=nota
	add.s $f6, $f6, $f12		# somaDasNotasDoAluno+=nota
		
	addi $t1, $t1, 1		# j++
	blt $t1, $a2, loop_funcao
	li $t1, 0			# j = 0
	
	div.s $f6, $f6, $f10		# soma das notas do aluno / 3
	# Printa a mensagem de saida:
	la $a0, saida1
	li $v0, 4
	syscall
	
	li $v0, 1
	move $a0, $t0
	syscall
	
	la $a0, saida2
	li $v0, 4
	syscall
	
	li $v0, 2
	mov.s $f12, $f6
	syscall
	
	c.lt.s $f6, $f8
	bc1t false_funcao
	addi $t4, $t4, 1		# contador de aprovados++
	false_funcao:
	li $t5, 0
	mtc1 $t5, $f6
	cvt.s.w $f6, $f6		# soma do aluno = 0
	addi $t0, $t0, 1		# i++
	blt $t0, $a1, loop_funcao
	li $t0, 0			# i = 0
	
	mul $t6, $a1, $a2		# $t6 = m*n
	mtc1 $t6, $f8
	cvt.s.w $f8, $f8
	
	div.s $f2, $f2, $f8		# Media aritmetica da sala
	
	li $v0, 4
	la $a0, saida3
	syscall
	
	li $v0, 2
	mov.s $f12, $f2
	syscall
	
	li $v0, 4
	la $a0, saida4
	syscall
	
	li $v0, 1
	move $a0, $t4
	syscall
	
	sub $t6, $a1, $t4
	
	li $v0, 4
	la $a0, saida5
	syscall
	
	li $v0, 1
	move $a0, $t6
	syscall
	
	
	
	
	lw $ra, ($sp)
	addi $sp, $sp 4
	jr $ra
	
escrita:
	addi $sp, $sp, -4
	sw $ra, ($sp)
	move $a3, $a0		# $a3 -> endereco da matriz
	
	li $t0, 0		# i = 0
	li $t1, 0		# j = 0
	
	loop_escrita:	
	jal indice
	move $t2, $v0
	l.s $f12, ($t2)
	
	la $a0, espaco
	li $v0, 4
	syscall
	
	li $v0, 2
	syscall
	
	
	addi $t1, $t1, 1
	blt $t1, $a2, loop_escrita
	li $t1, 0
	
	la $a0, quebra_linha
	li $v0, 4
	syscall
	
	addi $t0, $t0, 1
	blt $t0, $a1, loop_escrita
	li $t0, 0
	
	lw $ra, ($sp)
	addi $sp, $sp 4
	jr $ra
	
	
	
	
	
	
	
	
	
	
