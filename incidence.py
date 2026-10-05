import random

while True:
    n = int(input("Кол-во вершин: "))
    p = float(input("Вероятность ребра (0-1): "))

    edges = []
    for u in range(n):
        for v in range(u+1, n):
            if random.random() < p:
                edges.append((u, v))

    B = [[0]*len(edges) for _ in range(n)]
    for j, (u, v) in enumerate(edges):
        B[u][j] = 1
        B[v][j] = 1

    print(f"Рёбра: {edges}")
    print("Матрица инцидентности:")
    for row in B:
        print(row)
    print()
