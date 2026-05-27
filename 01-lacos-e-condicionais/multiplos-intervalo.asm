# =======================================================================================
# Titulo: Gerador de Sequencias de Multiplos em Intervalo Definido
# Descricao: Le dois numeros inteiros (A e B) via I/O do usuario e gera todos os multiplos 
# de A no intervalo fechado [A, A*B], tratando casos de entradas nulas ou negativas.
# Analise de Computabilidade: O tempo de execucao depende diretamente dos dados de entrada, 
# simulando um processamento dinamico. A implementacao conta com condicionais de guarda 
# (blez) que tratam dominios indefinidos (entradas <= 0), evitando loops infinitos e 
# garantindo a decidibilidade (parada) para qualquer entrada pertencente a Z.
# Aplicacao: Pesquisa cientifica envolvendo a geracao de sequencias computaveis limitadas 
# e o tratamento de restricoes de dominio em algoritmos matematicos estruturais.
# Referência na documentação: "atividade-mips-01.pdf"
# =======================================================================================

.data
    msg_a: .asciiz "Digite o valor de A: "                  # Mensagem pedindo o valor de A ao usuario
    msg_b: .asciiz "Digite o valor de B: "                  # Mensagem pedindo o valor de B ao usuario
    msg_erro: .asciiz "Erro: A e B devem ser maiores que 0. Tente novamente!\n"  # Mensagem de erro se A ou B forem <= 0
    msg_resultado: .asciiz "Os multiplos de A no intervalo de A ate A*B sao:\n"  # Mensagem antes de exibir os multiplos
    msg_espaco: .asciiz " "                                 # Espaco para separar os multiplos na saida
    a: .word 0                                              # Variavel para armazenar o valor de A
    b: .word 0                                              # Variavel para armazenar o valor de B

.text
entrada_de_dados:
    li $v0, 4                                              # Syscall para impressao de string
    la $a0, msg_a                                          # Carrega o endereco da mensagem em $a0
    syscall                                                # Executa a syscall para exibir a mensagem
    
    li $v0, 5                                              # Syscall para leitura de inteiro
    syscall                                                # Executa a syscall para ler o valor de A
    sw $v0, a                                              # Armazena o valor lido em "a"
    
    li $v0, 4                                              # Syscall para impressao de string
    la $a0, msg_b                                          # Carrega o endereco da mensagem em $a0
    syscall                                                # Executa a syscall para exibir a mensagem
    
    li $v0, 5                                              # Syscall para leitura de inteiro
    syscall                                                # Executa syscall para ler o valor de B
    sw $v0, b                                              # Armazena o valor lido em "b"
    
    lw $t0, a                                              # Carrega o valor de A em $t0
    lw $t1, b                                              # Carrega o valor de B em $t1
    blez $t0, erro                                         # Se A <= 0, desvia para erro
    blez $t1, erro                                         # Se B <= 0, desvia para erro
    
    li $v0, 4                                              # Syscall para impressao de string
    la $a0, msg_resultado                                  # Carrega o endereco da mensagem em $a0
    syscall                                                # Executa a syscall para exibir a mensagem
    
    move $t2, $t0                                          # Inicializa $t2 com o valor de A (primeiro multiplo)
    mul $t3, $t1, $t0                                      # Calcula A * B e armazena em $t3 (ultimo multiplo)

print_multiplos:
    ble $t2, $t3, print                                    # Se $t2 <= $t3, desvia para print para imprimir o multiplo
    j fim_do_programa                                      # Se nao, pula para o final do programa

print:
    li $v0, 1                                              # Syscall para impressao de inteiro
    move $a0, $t2                                          # Move o valor atual de $t2 para $a0 (multiplo de A)
    syscall                                                # Executa syscall para exibir o multiplo
    
    li $v0, 4                                              # Syscall para impressao de string
    la $a0, msg_espaco                                     # Carrega o endereco da mensagem com o espaco em $a0 
    syscall                                                # Executa syscall para exibir um espaco entre os multiplos
    
    add $t2, $t2, $t0                                      # Incrementa $t2 adicionando A (proximo multiplo)
    j print_multiplos                                      # Volta para o inicio do loop

erro:
    li $v0, 4                                              # Syscall para impressao de string
    la $a0, msg_erro                                       # Carrega o endereco da mensagem de erro em $a0
    syscall                                                # Executa a syscall para exibir a mensagem de erro
    j entrada_de_dados                                     # Volta para o inicio do programa para uma nova entrada de dados

fim_do_programa:
    li $v0, 10                                             # Syscall para encerrar o programa
    syscall                                                # Executa a syscall para terminar o programa
