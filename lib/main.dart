import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const SnakeApp());
}

class SnakeApp extends StatelessWidget {
  const SnakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SnakeGame(),
    );
  }
}

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  static const int gridSize = 20;
  static const double boardSize = 300;

  List<Point<int>> snake = [const Point(10, 10)];
  Point<int> food = const Point(5, 5);
  Point<int> direction = const Point(1, 0);

  int score = 0;
  Timer? timer;
  bool isRunning = false;

  Color snakeColor = Colors.greenAccent;

  @override
  void initState() {
    super.initState();
  }

  // 🎮 CONTROL DEL JUEGO
  void startGame() {
    if (isRunning) return;

    isRunning = true;
    timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      moveSnake();
    });
  }

  void pauseGame() {
    timer?.cancel();
    isRunning = false;
  }

  void resetGame() {
    pauseGame();
    setState(() {
      snake = [const Point(10, 10)];
      direction = const Point(1, 0);
      food = randomFood();
      score = 0;
      snakeColor = randomColor(); // 🎨 cambia color
    });
  }

  void moveSnake() {
    setState(() {
      final head = snake.first;
      final newHead = Point(head.x + direction.x, head.y + direction.y);

      // 💥 colisiones
      if (newHead.x < 0 ||
          newHead.y < 0 ||
          newHead.x >= gridSize ||
          newHead.y >= gridSize ||
          snake.contains(newHead)) {
        resetGame();
        return;
      }

      snake.insert(0, newHead);

      if (newHead == food) {
        score++;
        food = randomFood();
      } else {
        snake.removeLast();
      }
    });
  }

  Point<int> randomFood() {
    final rand = Random();
    return Point(rand.nextInt(gridSize), rand.nextInt(gridSize));
  }

  Color randomColor() {
    final rand = Random();
    return Color.fromARGB(
      255,
      rand.nextInt(256),
      rand.nextInt(256),
      rand.nextInt(256),
    );
  }

  void changeDirection(Point<int> newDir) {
    direction = newDir;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('🐍 Snake Flutter'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Puntaje: $score',
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 10),

          // 🟦 MARCO DEL JUEGO
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomPaint(
              size: const Size(boardSize, boardSize),
              painter: SnakePainter(
                snake: snake,
                food: food,
                snakeColor: snakeColor,
              ),
            ),
          ),

          const SizedBox(height: 15),

          // ▶ ⏸ 🔄 BOTONES
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: startGame,
                child: const Text("Iniciar"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: pauseGame, child: const Text("Pausar")),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: resetGame,
                child: const Text("Reiniciar"),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 🎮 CONTROLES TÁCTILES
          buildControls(),
        ],
      ),
    );
  }

  Widget buildControls() {
    return Column(
      children: [
        IconButton(
          iconSize: 50,
          onPressed: () => changeDirection(const Point(0, -1)),
          icon: const Icon(Icons.keyboard_arrow_up, color: Colors.white),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              iconSize: 50,
              onPressed: () => changeDirection(const Point(-1, 0)),
              icon: const Icon(Icons.keyboard_arrow_left, color: Colors.white),
            ),
            const SizedBox(width: 40),
            IconButton(
              iconSize: 50,
              onPressed: () => changeDirection(const Point(1, 0)),
              icon: const Icon(Icons.keyboard_arrow_right, color: Colors.white),
            ),
          ],
        ),
        IconButton(
          iconSize: 50,
          onPressed: () => changeDirection(const Point(0, 1)),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        ),
      ],
    );
  }
}

class SnakePainter extends CustomPainter {
  final List<Point<int>> snake;
  final Point<int> food;
  final Color snakeColor;

  SnakePainter({
    required this.snake,
    required this.food,
    required this.snakeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / 20;
    final paint = Paint();

    // 🍎 comida
    paint.color = Colors.red;
    canvas.drawRect(
      Rect.fromLTWH(food.x * cellSize, food.y * cellSize, cellSize, cellSize),
      paint,
    );

    // 🐍 serpiente
    paint.color = snakeColor;
    for (final p in snake) {
      canvas.drawRect(
        Rect.fromLTWH(p.x * cellSize, p.y * cellSize, cellSize, cellSize),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
