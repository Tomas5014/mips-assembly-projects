# =======================================================================================
# Titulo: Calculo de Arranjo Simples com Sub-rotinas (Fatorial)
# Descricao: Calcula o arranjo simples A(n,p) = n! / (n-p)! utilizando uma sub-rotina 
# dedicada para o calculo do fatorial, demonstrando a passagem de parametros em Assembly.
# Analise de Computabilidade: Destaca-se pela reutilizacao de codigo atraves de desvios 
# incondicionais com ligacao (jal/jr). A complexidade esta ligada ao crescimento 
# exponencial das operacoes de multiplicacao, porem a paragem e garantida pela 
# condicao de contorno estruturada no laco do fatorial.
# Aplicacao: Pesquisa em analise combinatoria e otimizacao de chamadas de rotinas 
# matematicas em arquiteturas RISC.
# Referência na documentação: "atividade-mips-04.pdf"
# =======================================================================================

.data
    prompt_n:       .asciiz "Digite o valor de n: "
    prompt_p:       .asciiz "Digite o valor de p: "
    result_msg:     .asciiz "O valor do arranjo (n, p) = "
    newline:        .asciiz "\n"

.text
    .globl main

main:
    # Leitura do valor de n
    li      $v0, 4              # Syscall para imprimir string
    la      $a0, prompt_n       
    syscall                     
    
    li      $v0, 5              # Syscall para ler inteiro
    syscall                     
    move    $t0, $v0            # Armazena n em $t0

    # Leitura do valor de p
    li      $v0, 4              # Syscall para imprimir string
    la      $a0, prompt_p       
    syscall                     

    li      $v0, 5              # Syscall para ler inteiro
    syscall                     
    move    $t1, $v0            # Armazena p em $t1

 
    sub     $t2, $t0, $t1       # t2 = n - p

   
    move    $a0, $t0            # Passa n como parametro
    jal     fatorial           
    move    $t3, $v0            # Armazena o resultado de n! em $t3

    
    move    $a0, $t2            # Passa (n - p) como parametro
    jal     fatorial           
    move    $t4, $v0            # Armazena (n - p)! em $t4

    div     $t3, $t3, $t4       # Divide n! por (n - p)!
    mflo    $t5                 # Armazena o resultado em $t5

   
    li      $v0, 4              # Syscall para imprimir string
    la      $a0, result_msg     
    syscall                     

    move    $a0, $t5            
    li      $v0, 1              
    syscall                     # Imprime o valor do arranjo

    
    li      $v0, 4
    la      $a0, newline
    syscall

    li      $v0, 10             # Syscall para encerrar o programa
    syscall


fatorial:
    li      $v0, 1              # Inicializa o resultado como 1
    blez    $a0, fatorial_saida # Se n <= 0, retorna 1

fatorial_loop:
    mul     $v0, $v0, $a0       # v0 = v0 * n
    sub     $a0, $a0, 1         # n = n - 1
    bgtz    $a0, fatorial_loop # Se n > 0, continua o loop

fatorial_saida:
    jr      $ra                 # Retorna
