# Graph using dict
from collections import defaultdict
from pprint import pprint

class Graph:

    def __init__(self, edges):
        self.graph = defaultdict(list)
        self.edges = edges

    def build_graph(self):
        for edge in self.edges:
            a, b = edge[0], edge[1]
            self.graph[a].append(b)
            self.graph[b].append(a)

    def breadth_first_search(self, start, goal):
        ''' 
        Visit all adjacent nodes in a breadth first way
        to find the shortest path between two nodes
        if possible
        '''
        print('BFS: ', start, ' -> ', goal)
        visited = []
        queue = [[start]]

        if start == goal:
            print('Start = Goal.')
            return start

        while queue:
            path = queue.pop(0)
            node = path[-1]

            if node not in visited:  # checks if current node was visited
                adjacents = self.graph[node]

                for adj in adjacents:  # go over all adjacent nodes
                    new_path = list(path)
                    new_path.append(adj)
                    queue.append(new_path)

                    if adj == goal:  # check if an adjacent node is the goal
                        print(f'Reached with path {new_path}\n')
                        return new_path
                visited.append(node)

        # if no path exists
        print(f'No path exists between {start} and {goal}\n')
        return False

    def dfs_aux(self, node, visited, goal):
        '''
        Auxliary function to traverse graph
        '''
        if node not in visited:
            # print(node, end=' ')
            visited.append(node)
            if node == goal:  # check if an adjacent node is the goal
                print(f'Reached with path {visited}\n')
                self.dfs_found = True
            for adj in self.graph[node]:  # for all adjacent nodes
                self.dfs_aux(adj, visited, goal)  # search their adjacents
            return False

    def depth_first_search(self, start, goal):
        '''
        Visit all adjacent nodes in a depth first way
        to find the shortest path between two nodes
        if possible
        '''
        print('DFS: ', start, ' -> ', goal)
        if start == goal:
            print('Start = Goal.')
            return start

        self.dfs_found = False
        visited = []
        self.dfs_aux(start, visited, goal)
        if not self.dfs_found:
            print(f'No path exists between {start} and {goal}')


if __name__ == '__main__':
    edges = [
        ["A", "B"], ["A", "E"],
        ["A", "C"], ["B", "D"],
        ["B", "E"], ["C", "F"],
        ["C", "D"], ["D", "E"]
    ]
    g = Graph(edges)
    g.build_graph()
    pprint(g.graph)
    g.breadth_first_search('A', 'E')
    g.breadth_first_search('A', 'G')
    g.depth_first_search('A', 'E')
    g.depth_first_search('A', 'G')
