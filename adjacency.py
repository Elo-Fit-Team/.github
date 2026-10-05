import random

while True:
    n = int(input("Кол-во вершин: "))
    p = float(input("Вероятность ребра (0-1): "))

    edges = []
    for u in range(n):
        for v in range(u+1, n):
            if random.random() < p:
                edges.append((u, v))

    A = [[0]*n for _ in range(n)]
    for u, v in edges:
        A[u][v] = 1
        A[v][u] = 1

    print(f"Рёбра: {edges}")
    print("Матрица смежности:")
    for row in A:
        print(row)
    print()
