# Problema da mochila (Knapsack problem)
# Recursivo
# Adaptado de https://www.geeksforgeeks.org/0-1-knapsack-problem-dp-10/
 
# Retorna o maior valor possivel que uma
# mochila com peso maximo max_peso pode carregar
 
 
def knapSack(max_peso, peso_item, valor_item, n_itens):
 
    # Melhor caso, 0 itens ou peso max = 0
    if n_itens == 0 or max_peso == 0:
        return 0
 
    # Se o peso do item [n] for
    # maior que o max da mochila
    # ele nao sera incluido na resposta
    if (peso_item[n_itens-1] > max_peso):
        return knapSack(max_peso, peso_item, valor_item, n_itens-1)
 
    # Retorna uma nova chamada da funcao com:
    # (1) o item [n] incluso
    # (2) o item [n] nao incluso
    else:
        return max(
            valor_item[n_itens-1] + knapSack(
                max_peso-peso_item[n_itens-1], peso_item, valor_item, n_itens-1),
            knapSack(max_peso, peso_item, valor_item, n_itens-1))
 

 
valor_item = [50, 80, 100]
peso_item = [10, 22, 35]
max_peso = 55
n_itens = len(valor_item)
print(knapSack(max_peso, peso_item, valor_item, n_itens))
 
