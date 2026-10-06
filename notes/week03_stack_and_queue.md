# Конспект: Неделя 3. Работа со Стеком и Очередью
**Дисциплина:** SDT1009 Дискретные математические структуры  
**Преподаватель:** Рамазанов Е.Т., AlmaU  
**Литература по силлабусу:**
- Хаггарти Р. [стр. 18–78]
- Бэрри П. [Т.1, стр. 18–118]
- Новиков Ф.А., Щербина И.А. [стр. 5–31]
- Иванов Б.Н.

---

## 1. Стек (Stack)
**Стек** — линейная структура данных, функционирующая по принципу **LIFO (Last In, First Out)** — *«последним пришел — первым ушел»*.

### 1.1. Базовые операции над стеком:
* `push(x)` — добавить элемент на вершину стека ($O(1)$).
* `pop()` — извлечь и вернуть элемент с вершины стека ($O(1)$). Если стек пуст — ошибка опустошения (Stack Underflow).
* `peek()` / `top()` — просмотреть верхний элемент без удаления ($O(1)$).
* `is_empty()` — проверка на пустоту.
* `size()` — текущее количество элементов.

### 1.2. Применение стека в Computer Science:
1. Вызовы функций в процессоре (Call Stack, стек вызовов, хранение адресов возврата).
2. Обратная польская запись (RPN, постфиксная нотация вычислений).
3. Проверка корректности скобочных последовательностей (баланс скобок).
4. Обход графа в глубину (**DFS**).
5. Механизм Undo / Redo в текстовых и графических редакторах.

---

## 2. Очередь (Queue)
**Очередь** — линейная структура данных, функционирующая по принципу **FIFO (First In, First Out)** — *«первым пришел — первым ушел»*.

### 2.1. Базовые операции над очередью:
* `enqueue(x)` — добавить элемент в конец (хвост / rear) очереди ($O(1)$).
* `dequeue()` — извлечь элемент из начала (головы / front) очереди ($O(1)$).
* `front()` / `peek()` — посмотреть элемент в начале очереди без удаления ($O(1)$).
* `is_empty()` — проверка очереди на пустоту.

### 2.2. Применение очереди:
1. Буферизация данных (буфер клавиатуры, очередь печати принтера).
2. Планировщики задач в операционных системах (Round-robin scheduling).
3. Обход графа в ширину (**BFS**).
4. Очереди сообщений (Message Queues: RabbitMQ, Kafka).

---

## 3. Двусторонняя очередь (Deque) и Очередь с приоритетом (Priority Queue)
* **Deque (Double-Ended Queue):** допускает добавление и удаление элементов с обоих концов ($O(1)$).
* **Priority Queue:** каждому элементу сопоставлен приоритет. Элемент с наивысшим приоритетом извлекается первым (внутри строится на двоичной куче — Binary Heap, $O(\log n)$).

---

## 4. Эффективная реализация на Python

> **Важно для собеседований и экзамена:**  
> Использование обычного списка `list` для очереди через `pop(0)` неэффективно, так как занимает **$O(n)$** времени из-за сдвига всех элементов в памяти. Нужно использовать `collections.deque` с операциями за **$O(1)$**.

```python
from collections import deque

# 1. Реализация Стека на Python
class Stack:
    def __init__(self):
        self._items = []

    def push(self, item):
        self._items.append(item)

    def pop(self):
        if self.is_empty():
            raise IndexError("Стек пуст!")
        return self._items.pop()

    def peek(self):
        return self._items[-1] if not self.is_empty() else None

    def is_empty(self):
        return len(self._items) == 0

# 2. Пример применения: Проверка баланса скобок
def is_bracket_balanced(expr: str) -> bool:
    stack = Stack()
    brackets = {')': '(', '}': '{', ']': '['}
    for ch in expr:
        if ch in brackets.values():
            stack.push(ch)
        elif ch in brackets.keys():
            if stack.is_empty() or stack.pop() != brackets[ch]:
                return False
    return stack.is_empty()

print("Скобки валидны?:", is_bracket_balanced("{[()]}")) # True
print("Скобки валидны?:", is_bracket_balanced("{[(])}")) # False


# 3. Реализация Очереди на collections.deque (O(1))
class Queue:
    def __init__(self):
        self._items = deque()

    def enqueue(self, item):
        self._items.append(item)

    def dequeue(self):
        if self.is_empty():
            raise IndexError("Очередь пуста!")
        return self._items.popleft() # O(1)

    def front(self):
        return self._items[0] if not self.is_empty() else None

    def is_empty(self):
        return len(self._items) == 0
```
