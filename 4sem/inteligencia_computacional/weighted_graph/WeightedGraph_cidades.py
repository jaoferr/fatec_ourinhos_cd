from collections import defaultdict
from pprint import pprint

class Graph:
    ''' Simple weighted graph representation using a dict '''

    def __init__(self):
        self.graph = defaultdict(dict)

    def add_edge(self, node, edge, weight):
        self.graph[node][edge] = weight

    def show_graph(self):
        pprint(self.graph)

    def dijkstra_path(self, start, end): 
        '''
        Returns shortest path between two nodes on a graph
        using Dijsktra Algorithm
        '''
        self.start = start
        self.end = end

        ctrl = {}
        distance = {}
        current_node = {}
        not_visited = []
        current = start
        current_node[current] = 0

        
        for v in self.graph.keys():
            not_visited.append(v)  # appends all nodes not yet visited
            distance[v] = float('inf')  # sets all distance as infinite for all of them

        distance[current] = [0, start] 
        not_visited.remove(current)

        while not_visited:
            for neighbor, weight in self.graph[current].items():
                weight_calc = weight + current_node[current]
                if distance[neighbor] == float("inf") or distance[neighbor][0] > weight_calc:
                    distance[neighbor] = [weight_calc, current]
                    ctrl[neighbor] = weight_calc
                    print(ctrl)
                    
            if ctrl == {} : break    
            min_neighbor = min(ctrl.items(), key=lambda x: x[1])  # selects closest neighbor
            current=min_neighbor[0]
            current_node[current] = min_neighbor[1]
            not_visited.remove(current)
            del ctrl[current]

        self.distance = distance
        print("\nA menor distância de %s atá %s é: %s" % (start, end, distance[end][0]))
        print("\nO menor caminho é: %s" % self.show_path(distance, start, end))        
   
    def show_path(self, distances, start, end):
            if  end != start:
                return "%s -- > %s" % (self.show_path(distances, start, distances[end][1]), end)
            else:
                return start


if __name__ == '__main__':
    g = Graph()
    g.add_edge('Irati', 'Paulo Frontin', 75)
    g.add_edge('Irati', 'Palmeira', 75)
    g.add_edge('Irati', 'São Mateus', 57)

    g.add_edge('Palmeira', 'Irati', 75)
    g.add_edge('Palmeira', 'Campo Largo', 55)
    g.add_edge('Palmeira', 'São Mateus', 77)

    g.add_edge('Paulo Frontin', 'Irati', 75)
    g.add_edge('Paulo Frontin', 'Porto União', 46)

    g.add_edge('Campo Largo', 'Palmeira', 55)
    g.add_edge('Campo Largo', 'Curitiba', 29)
    g.add_edge('Campo Largo', 'Balsa Nova', 22)

    g.add_edge('Porto União', 'Paulo Frontin', 46)
    g.add_edge('Porto União', 'São Mateus', 87)
    g.add_edge('Porto União', 'Canoinhas', 78)

    g.add_edge('São Mateus', 'Irati', 57)
    g.add_edge('São Mateus', 'Palmeira', 77)
    g.add_edge('São Mateus', 'Porto União', 87)
    g.add_edge('São Mateus', 'Tres barras', 43)
    g.add_edge('São Mateus', 'Lapa', 60)

    g.add_edge('Contenda', 'Balsa Nova', 19)
    g.add_edge('Contenda', 'Lapa', 26)
    g.add_edge('Contenda', 'Araucaria', 18)

    g.add_edge('Balsa Nova', 'Campo Largo', 22)
    g.add_edge('Balsa Nova', 'Contenda', 19)
    g.add_edge('Balsa Nova', 'Curitiba', 51)

    g.add_edge('Tres barras', 'São Mateus', 43)
    g.add_edge('Tres barras', 'Canoinhas', 12)

    g.add_edge('Lapa', 'São Mateus', 60)
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

    g.show_graph()
    g.dijkstra_path("Porto União", "Curitiba")
    g.dijkstra_path("Porto União", "Tijucas do Sul")
