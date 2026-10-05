import random

def adjacency_matrix(n, edges, directed=False):
    A = [[0]*n for _ in range(n)]
    for u, v in edges:
        A[u][v] = 1
        if not directed:
            A[v][u] = 1
    return A

def incidence_matrix(n, edges, directed=False):
    B = [[0]*len(edges) for _ in range(n)]
    for j, (u, v) in enumerate(edges):
        if directed:
            B[u][j] = -1
            B[v][j] = 1
        else:
            B[u][j] = 1
            B[v][j] = 1
    return B

def random_edges(n, p=0.5, directed=False):
    edges = []
    for u in range(n):
        start = 0 if directed else u+1
        for v in range(start, n):
            if u != v and random.random() < p:
                edges.append((u, v))
    return edges

def print_matrix(m):
    for row in m:
        print(row)

n = int(input("Кол-во вершин: "))
p = float(input("Вероятность ребра (0-1): "))
d = input("Ориентированный? (y/n): ").strip().lower() == "y"

edges = random_edges(n, p, d)
print(f"\nРёбра: {edges}")

print("\nМатрица смежности:")
print_matrix(adjacency_matrix(n, edges, d))

print("\nМатрица инцидентности:")
print_matrix(incidence_matrix(n, edges, d))
