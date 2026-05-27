# =======================================================================================
# Titulo: Verificador de Numero Perfeito
# Descricao: Recebe um inteiro positivo 'n' e verifica se ele e um numero perfeito 
# (ou seja, se a soma de seus divisores positivos proprios e igual ao proprio 'n').
# Analise de Computabilidade: O algoritmo consiste em um laco de repeticao finito que 
# itera de 1 ate n-1, realizando operacoes de modulo (divisoes) e somas condicionais. 
# Trata-se de um problema decidivel cujo tempo de execucao cresce linearmente O(n) em 
# relacao a magnitude da entrada, garantindo a parada.
# Aplicacao: Auxilio em pesquisa cientifica para demonstracao de lacos deterministicos 
# e teoria dos numeros em arquitetura de baixo nivel.
# Referência na documentação: "atividade-mips-02.pdf"
# =======================================================================================

.data
    msg_entrada: .asciiz "Digite um numero inteiro positivo: "
    msg_perfeito: .asciiz "O numero eh um numero perfeito.\n" 
    msg_nao_perfeito: .asciiz "O numero nao eh um numero perfeito.\n"
    msg_erro: .asciiz "Entrada invalida! Tente novamente.\n"   

.text
    main:
        # Exibe a mensagem de solicitacao de entrada
        li $v0, 4                    # Carrega o codigo da syscall para imprimir string
        la $a0, msg_entrada          # Carrega o endereco da string msg_entrada em $a0
        syscall                      # Chama a syscall para imprimir a mensagem

        # Le um numero inteiro fornecido pelo usuario
        li $v0, 5                    # Carrega o codigo da syscall para ler um inteiro
        syscall                      # Chama a syscall para ler o inteiro
        move $t0, $v0                # Move o valor lido para o registrador $t0

        # Verifica se o numero eh maior que zero
        blez $t0, erro               # Se $t0 <= 0, pula para o rotulo "erro"
        
        # Inicializa registradores
        li $t1, 1                    # Inicia $t1 com 1 (usado para encontrar divisores)
        li $t4, 0                    # Inicia $t4 com 0 (acumula a soma dos divisores)

    loop:
        # Calcula $t0 / $t1
        div $t0, $t1                 # Divide $t0 por $t1 (quociente em $LO e resto em $HI)
        mfhi $t2                     # Move o resto da divisao para $t2
        beq $t2, $zero eh_divizor    # Se o resto for 0, $t1 eh divisor de $t0

    soma1:
        # Incrementa $t1 e verifica se continua o loop
        addi $t1, $t1, 1             # Incrementa $t1 em 1
        slt $t3, $t1, $t0            # Verifica se $t1 < $t0 (define $t3)
        beq $t3, $zero fim_do_loop   # Se $t1 >= $t0, pula para fim_do_loop
        j loop                       # Caso contrario, volta ao inicio do loop

    eh_divizor:
        # Soma $t1 aos divisores acumulados em $t4
        add $t4, $t4, $t1            # Soma o valor de $t1 a $t4
        j soma1                      # Volta para soma1 para continuar o loop

    fim_do_loop:
        # Verifica se a soma dos divisores ($t4) eh igual ao numero original ($t0)
        beq $t4, $t0 eh_perfeito     # Se for igual, pula para eh_perfeito
        li $v0, 4                    # Carrega o codigo da syscall para imprimir string
        la $a0, msg_nao_perfeito      # Carrega a mensagem de numero nao perfeito
        syscall                      # Chama a syscall para imprimir a mensagem
        j fim_do_codigo              # Pula para o fim do codigo

    eh_perfeito:
        # Exibe a mensagem de numero perfeito
        li $v0, 4                    # Carrega o codigo da syscall para imprimir string
        la $a0, msg_perfeito          # Carrega a mensagem de numero perfeito
        syscall                      # Chama a syscall para imprimir a mensagem
        j fim_do_codigo              # Pula para o fim do codigo

    erro:
        # Exibe a mensagem de erro para entrada invalida
        li $v0, 4                    # Carrega o codigo da syscall para imprimir string
        la $a0, msg_erro             # Carrega a mensagem de erro
        syscall                      # Chama a syscall para imprimir a mensagem
        j main                       # Volta para o inicio do programa para nova entrada

    fim_do_codigo:
        # Termina o programa
        li $v0, 10                   # Carrega o codigo da syscall para encerrar o programa
        syscall                      # Chama a syscall para encerrar
