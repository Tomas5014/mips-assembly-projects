# =======================================================================================
# Titulo: Implementacao de Somatorio Finito (S = somatorio(4k+2))
# Descricao: Algoritmo em MIPS Assembly que calcula o somatorio de k=1 ate 20 da funcao 4k+2.
# Analise de Computabilidade: Este programa simula uma Maquina de Turing com fita limitada 
# e laco deterministico finito. O Problema da Parada (Halting Problem) e trivialmente 
# decidivel neste escopo, pois o algoritmo possui um numero exato de transicoes de estado 
# (20 iteracoes) antes de atingir o estado de aceitacao de forma garantida.
# Aplicacao: Auxilio em pesquisa cientifica analisando a complexidade de tempo de execucao 
# de funcoes polinomiais computaveis.
# Referência na documentação: "atividade-mips-01.pdf"
# =======================================================================================

.data
	result : .word 0 		#variavel para armazenar o resultado final do somatorio.
	msg: .asciiz "O somatorio S eh igual a " #Mensagem pra printar no fim do programa.
.text
	main:
		li $t0, 1		#$t0 eh o k e eh inicializado com 1.
		li $t1, 20		#$t1 eh o valor maximo de k e eh inicializado com 20.
		li $t2, 0		#$t2 eh a variavel para armazenar, temporariamente, o resultado da somatoria.
		li $t4, 4		#carrega 4 pra $t4
	loop:
		mult $t0, $t4		#4 * k
		mflo $t3		#$t3 = 4 * k
		addi $t3, $t3, 2	#$t3 = (4 * k) + 2
		add $t2, $t2, $t3	#soma $t3 a variavel pro resultado da somatorio.
		
		addi $t0, $t0,1		#k = k + 1.
		ble $t0, $t1, loop	#se $t0  <= $t1, pula pra loop.
		
		sw $t2, result 		#armazena o resulado final na variavel result.
		
		#imprime o valor final na tela:
		li $v0, 4		# Codigo da syscall para imprimir uma string.
		la $a0, msg		# Carrega o endereco da string em $a0.
		syscall			# Chama syscall pra imprimir a string.
		
		li $v0, 1 		# Codigo da syscall para imprimir um inteiro.
		lw $a0, result		#carrega o valor final em $a0.
		syscall			#chama syscal pra imprimir o valor.
		
		#Termina o programa:
		li $v0, 10		#codigo pra encerrar o programa.		
		syscall
