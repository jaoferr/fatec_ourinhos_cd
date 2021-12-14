import time

def dynamic_fib(n):  
    start_time = time.time()
    fibs = []  # lista para armazenar os valores calculados
    for i in range(n):
        if i < 2:
            fibs.append(i)  # armazena os 2 primeiros valores
        else:
            fibs.append(fibs[i - 2] + fibs[i - 1])  # calcula e armazena o proximo termo
                                                    # utilizando os 2 anteriores já calculados
            
    print(fibs)
    print('\nTempo:' ,time.time() - start_time)
    return fibs

if __name__ == '__main__':
    f = dynamic_fib(10000000000)
