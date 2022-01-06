# calculo numero boleto

AGENCIA_CONTA = '0057'
CARTEIRA = '12345-7'
NOSSO_N1 = '110'
NOSSO_N2 = '12345678'

def gerar_boleto(agencia_conta, carteira, nosso_n1, nosso_n2):
    raw_boleto = f'{AGENCIA_CONTA}{CARTEIRA[:-2]}{NOSSO_N1}{NOSSO_N2}'

    lista_calculo = [x for i in range(10) for x in [1, 2]]

    valor = 0
    for i, x in zip(lista_calculo, raw_boleto):
        soma = i*int(x)
        if soma > 10:
            valor+= int(str(soma)[0])+int(str(soma)[1])
        else:
            valor+=soma

    DAC = 10 - (valor%10)

    boleto = raw_boleto+'-'+str(DAC)

    print(f'DAC: {DAC}')
    print(f'Boleto completo: {AGENCIA_CONTA}{CARTEIRA[:-2]}{NOSSO_N1}{NOSSO_N2}-{str(DAC)}')
    return boleto

gerar_boleto(AGENCIA_CONTA, CARTEIRA, NOSSO_N1, NOSSO_N2)
