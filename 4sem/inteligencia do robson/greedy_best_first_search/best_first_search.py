'''
Use GBFS.py "Inicio" "Destino" no terminal
'''
from collections import defaultdict
from pprint import pprint
import geopy
import geopy.distance
from queue import PriorityQueue
import argparse

class Graph:
    ''' 
    Simple weighted graph representation using a dict 
    With a greedy best first search implementation
    '''

    def __init__(self, state, country):
        self.graph = defaultdict(dict)
        self.state = state
        self.country = country
        self.all_nodes = set()

    def add_edge(self, node, edge, weight):
        self.graph[node][edge] = weight
        self.all_nodes.add(node)
        self.all_nodes.add(edge)

    def show_graph(self):
        pprint(self.graph)

    def set_distances(self, goal):
        ''' Get distances between each location and the goal '''
        self.distances = {}
        loc = geopy.Nominatim(user_agent='GBFS')
        goal_coords = loc.geocode(f'{goal}, {self.state}, {self.country}')[1]  # coordenadas da cidade alvo
        for node in self.graph:                                                # para cada cidade no grafo
            location = loc.geocode(f'{node}, {self.state}, {self.country}')    # coordenadas da cidade
            coords = location[1]
            distance = geopy.distance.geodesic(coords, goal_coords).km         # distancia em km
            self.distances[node] = distance                                    # insere no dicionario

    def bfs(self, start, goal):
        ''' Best first search '''
        print('')
        print('+---------------------------------------+')
        print('|Starting Best first search (non-greedy)|')
        print('+---------------------------------------+')
        queue = PriorityQueue()  # fila de prioridade, m
        queue.put((0, start))    # insere o inicio na fila
        visited = {node: False for node in self.all_nodes}  # marca todas os nós como nao visitados

        last_node = start  # utilizado para calculo da distancia atual
        total_cost = 0     # utilizado para calculo da distancia total percorrida
        print('Caminho: ', end='', flush=False)
        while not queue.empty():
            current_node = queue.get()[1]  # nó atual = primeiro da fila, maior prioridade
            print(current_node, end='', flush=False)
            if current_node == goal:       # se nó atual = destino, acaba ai
                try:
                    total_cost += self.graph[current_node][last_node]
                except:
                    total_cost += total_cost
                break

            for next_node in self.graph[current_node].keys():  # passa por todos os vizinhos
                if visited[next_node] == False:                # se ele nao foi visitado ainda
                    visited[next_node] = True                  # marcar como visitado
                    cost = self.graph[current_node][next_node] # distancia entre o nó atual e o vizinho atual no loop
                    queue.put((cost, next_node))               # insere o vizinho e a distancia na fila

            if last_node != current_node:
                total_cost += cost

            last_node = current_node
            print(' -> ', end='', flush=False)
        print('\nCusto total:', total_cost)


    def gbfs(self, start, goal):
        ''' Greedy best first search '''
        print('')
        print('+---------------------------------------+')
        print('|   Starting Greedy best first search   |')
        print('+---------------------------------------+')
        self.set_distances(goal) # calcula a distancia de todos os nós até o alvo
        queue = PriorityQueue()  # fila de prioridade
        queue.put((0, start))    # insere o inicio na fila
        visited = {node: False for node in self.all_nodes}  # marca todas os nós como nao visitados

        last_node = start  # utilizado para calculo da distancia atual
        total_cost = 0     # utilizado para calculo da distancia total percorrida
        print('Caminho: ', end='', flush=False)
        while not queue.empty():
            current_node = queue.get()[1]  # nó atual = primeiro da fila, maior prioridade
            print(current_node, end='', flush=False)
            if current_node == goal:       # se nó atual = destino, acaba ai
                total_cost += self.graph[current_node][last_node]
                break
            
            for next_node in self.graph[current_node].keys():  # passa por todos os vizinhos
                if visited[next_node] == False:                # se ele nao foi visitado ainda
                    visited[next_node] = True                  # marcar como visitado
                    cost = self.distances[next_node]           # distancia entre o vizinho atual e o alvo final
                    queue.put((cost, next_node))               # insere o vizinho e a distancia na fila

            if last_node != current_node:
                total_cost += self.graph[current_node][last_node]

            last_node = current_node

            print(' -> ', end='', flush=False)
        print('\nCusto total:', total_cost)


if __name__ == '__main__':
    g = Graph('Parana', 'Brazil')
    g.add_edge('Irati', 'Paulo Frontin', 75)
    g.add_edge('Irati', 'Palmeira', 75)
    g.add_edge('Irati', 'São Mateus do Sul', 57)

    g.add_edge('Palmeira', 'Irati', 75)
    g.add_edge('Palmeira', 'Campo Largo', 55)
    g.add_edge('Palmeira', 'São Mateus do Sul', 77)

    g.add_edge('Paulo Frontin', 'Irati', 75)
    g.add_edge('Paulo Frontin', 'Porto União', 46)

    g.add_edge('Campo Largo', 'Palmeira', 55)
    g.add_edge('Campo Largo', 'Curitiba', 29)
    g.add_edge('Campo Largo', 'Balsa Nova', 22)

    g.add_edge('Porto União', 'Paulo Frontin', 46)
    g.add_edge('Porto União', 'São Mateus do Sul', 87)
    g.add_edge('Porto União', 'Canoinhas', 78)

    g.add_edge('São Mateus do Sul', 'Irati', 57)
    g.add_edge('São Mateus do Sul', 'Palmeira', 77)
    g.add_edge('São Mateus do Sul', 'Porto União', 87)
    g.add_edge('São Mateus do Sul', 'Tres barras', 43)
    g.add_edge('São Mateus do Sul', 'Lapa', 60)

    g.add_edge('Contenda', 'Balsa Nova', 19)
    g.add_edge('Contenda', 'Lapa', 26)
    g.add_edge('Contenda', 'Araucaria', 18)

    g.add_edge('Balsa Nova', 'Campo Largo', 22)
    g.add_edge('Balsa Nova', 'Contenda', 19)
    g.add_edge('Balsa Nova', 'Curitiba', 51)

    g.add_edge('Tres barras', 'São Mateus do Sul', 43)
    g.add_edge('Tres barras', 'Canoinhas', 12)

    g.add_edge('Lapa', 'São Mateus do Sul', 60)
    g.add_edge('Lapa', 'Contenda', 26)
    g.add_edge('Lapa', 'Mafra', 57)

    g.add_edge('Araucaria', 'Contenda', 18)
    g.add_edge('Araucaria', 'Curitiba', 37)
    
    g.add_edge('Curitiba', 'Campo Largo', 29)
    g.add_edge('Curitiba', 'Balsa Nova', 51)
    g.add_edge('Curitiba', 'Araucaria', 37)
    g.add_edge('Curitiba', 'São José dos Pinhais', 15)

    g.add_edge('Canoinhas', 'Porto União', 78)
    g.add_edge('Canoinhas', 'Tres barras', 12)

    g.add_edge('Mafra', 'Lapa', 57)
    g.add_edge('Mafra', 'Canoinhas', 66)
    g.add_edge('Mafra', 'Tijucas do Sul', 99)

    g.add_edge('Tijucas do Sul', 'Mafra', 99)
    g.add_edge('Tijucas do Sul', 'São José dos Pinhais', 49)

    g.add_edge('São José dos Pinhais', 'Curitiba', 15)
    g.add_edge('São José dos Pinhais', 'Tijucas do Sul', 49) 

    # CLI args
    parser = argparse.ArgumentParser(description='Best first search (greedy and non-greedy) demo')
    parser.add_argument('start', type=str, help='Cidade de partida')
    parser.add_argument('goal', type=str, help='Cidade de chegada')
    args = parser.parse_args()

    print('+-------------------------------+')
    print('\tPartida: ', args.start)
    print('\tChegada: ', args.goal)
    print('+-------------------------------+')

    g.bfs(args.start, args.goal)
    g.gbfs(args.start, args.goal)
    input('\nPressione qualquer tecla para sair')
    # g.bfs('Irati', 'Lapa')
    # g.gbfs('Irati', 'Lapa')
