import 'dart:io';

void main() {
  // reads the option of how the user wants to play (1 - Player vs Player, 2 - Player vs Computer)
  int playOption;
  do {
    // keep reading until the user inters a valid number
    print("Choose how you want to play:");
    print("1. Player vs Player");
    print("2. Player vs Computer");
    playOption = readInt();
  } while (playOption != 1 && playOption != 2);

  if (playOption == 1) {
    playerVsPlayer();
  } else {
    playerVsComputer();
  }
}

// this function will read from the console and return -1 if the input is not a number
// ans if it is a number, it will return the number
int readInt() {
  String input = stdin.readLineSync() ?? '';
  try {
    int number = int.parse(input);
    return number;
  } catch (e) {
    return -1;
  }
}

// build a class for each Player
class Player {
  // all the variables are private so the user can't change them
  String _symbol; // the symbol of the player (X or O)
  List<int> _moves = []; // the moves that the player has made so far

  Player(this._symbol); // constructor to set the symbol of the player

  String get symbol => _symbol; // getter for the symbol of the player

  // this function will return true if the player has made a move at the given position
  bool isLocatedAt(int position) {
    return _moves.contains(position);
  }

  // this function will add a move to the player
  void addMove(int position) {
    _moves.add(position);
  }

  // this function will remove a move from the player (this is impossible for the user to do, but it is used to find the best move to the cpu to do)
  void removeMove(int position) {
    _moves.remove(position);
  }

  // this function will check if the player has won
  bool checkWin() {
    for (int i = 1; i <= 3; ++i) {
      // check colums
      if (isLocatedAt(i) && isLocatedAt(i + 3) && isLocatedAt(i + 6)) {
        return true;
      }
      // check rows
      if (isLocatedAt(3 * i - 2) &&
          isLocatedAt(3 * i - 1) &&
          isLocatedAt(3 * i)) {
        return true;
      }
    }
    // check diagonals
    if (isLocatedAt(1) && isLocatedAt(5) && isLocatedAt(9)) {
      return true;
    }
    if (isLocatedAt(3) && isLocatedAt(5) && isLocatedAt(7)) {
      return true;
    }
    return false;
  }

  // this function will check if the player can win if he makes a move at the given cell
  bool checkPossibility(int cell) {
    addMove(cell);
    bool result = checkWin();
    removeMove(cell);
    return result;
  }
}

// this function will print the board
void printBoard(Player player1, Player player2) {
  print('');
  for (int i = 1; i <= 9; ++i) {
    // print the symbol of the player if he has made a move at the given cell or the number of the cell if no one has made a move at the given cell yet
    if (player1.isLocatedAt(i)) {
      stdout.write(' ${player1.symbol}');
    } else if (player2.isLocatedAt(i)) {
      stdout.write(' ${player2.symbol}');
    } else {
      stdout.write(' $i');
    }
    // print breaks for better design and readability
    if (i % 3 == 0) {
      print('');
      print('---+---+---');
    } else {
      stdout.write(' |');
    }
  }
  print('');
}

// build a funtion to control the game when the user plays against another user
void playerVsPlayer() {
  Player player1 = Player("X"), player2 = Player("O"); // define both playes
  List<int> emptyCells = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9
  ]; // define the current empty cells list
  int turn = 1; // define the current turn (1 - player1, 2 - player2)

  // keep going while there's empty cells or anyone win
  while (emptyCells.length > 0) {
    printBoard(player1, player2);
    print(
        'Player ${turn}, please enter the number of the cell where you want to place your ${turn == 1 ? 'X' : 'O'}: ');
    int position = readInt();
    // if the user entered an invalid number, ask him to enter a valid one
    if (position == -1) {
      print("Invalid cell number");
      continue;
    }
    // if the user entered a valid cell number check if the cell is empty
    if (emptyCells.contains(position)) {
      // add the move for the player who's turn it is and check if he wins
      if (turn == 1) {
        player1.addMove(position);
        if (player1.checkWin()) {
          printBoard(player1, player2);
          print("Game ended\nPlayer 1 won");
          return;
        }
        turn = 2;
      } else {
        player2.addMove(position);
        if (player2.checkWin()) {
          printBoard(player1, player2);
          print("Game ended\nPlayer 2 won");
          return;
        }
        turn = 1;
      }
      emptyCells.remove(position);
    } else {
      print("Cell already occupied");
    }
  }
  // if theres no empty cells, then the game ended in a draw
  printBoard(player1, player2);
  print("Game ended\nit's a Draw");
}

// build a funtion to control the game when the user plays against the computer
void playerVsComputer() {
  Player player = Player("X"), cpu = Player("O"); // define both playes
  List<int> emptyCells = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9
  ]; // define the current empty cells list
  int turn = 1; // define the current turn (1 - player, 2 - cpu)

  // keep going while there's empty cells or anyone win
  while (emptyCells.length > 0) {
    printBoard(player, cpu);
    // if the users turn, then treat him like he is playing against another user
    if (turn == 1) {
      print("Please Enter the cell where you want to place your X: ");
      int position = readInt();
      if (position == -1) {
        print("Invalid cell number");
        continue;
      }
      if (emptyCells.contains(position)) {
        player.addMove(position);
        if (player.checkWin()) {
          printBoard(player, player);
          print("Game ended\nThe layer won");
          return;
        }
        turn = 2;
        emptyCells.remove(position);
      } else {
        print("Cell already occupied");
      }
    } else {
      // check the best move for the cpu and make it
      int cpuMove = bestMove(emptyCells, player, cpu);
      print("The cpu chose cell $cpuMove");
      cpu.addMove(cpuMove);
      if (cpu.checkWin()) {
        printBoard(player, cpu);
        print("Game ended\nThe cpu won");
        return;
      }
      turn = 1;
      emptyCells.remove(cpuMove);
    }
  }
  printBoard(player, cpu);
  print("Game ended\nit's a Draw");
}

// build a function to find the best move for the cpu
int bestMove(List<int> emptyCells, Player player, Player cpu) {
  // check if there's a move that the cpu can make and win, then make it and win
  for (int cell in emptyCells) {
    if (cpu.checkPossibility(cell)) {
      return cell;
    }
  }
  // check if there's a move that the player can make and win, then make it and prevent the user from winning
  for (int cell in emptyCells) {
    if (player.checkPossibility(cell)) {
      return cell;
    }
  }
  /*
    check if there's a move that the cpu can make and give him more that two winning cells in the next round,
    then make it, so if the user prevented the cpu from winning in some cell, the cpu have another winning cell and will win in the next round
  */
  for (int cell in emptyCells) {
    cpu.addMove(cell);
    int winingMoves = 0;
    for (int new_cell in emptyCells) {
      if (cell != new_cell && cpu.checkPossibility(cell)) {
        ++winingMoves;
      }
    }
    cpu.removeMove(cell);
    if (winingMoves > 1) {
      return cell;
    }
  }
  // now do some conditions to find the best move according to tic-tac-toe logic
  if (cpu.isLocatedAt(5) &&
      cpu.isLocatedAt(7) &&
      emptyCells.contains(1) &&
      emptyCells.contains(4) &&
      emptyCells.contains(9)) {
    return 1;
  }
  if (cpu.isLocatedAt(5) &&
      cpu.isLocatedAt(3) &&
      emptyCells.contains(1) &&
      emptyCells.contains(2) &&
      emptyCells.contains(9)) {
    return 1;
  }
  if (cpu.isLocatedAt(5) &&
      cpu.isLocatedAt(1) &&
      emptyCells.contains(2) &&
      emptyCells.contains(3) &&
      emptyCells.contains(7)) {
    return 3;
  }
  if (cpu.isLocatedAt(5) &&
      cpu.isLocatedAt(9) &&
      emptyCells.contains(3) &&
      emptyCells.contains(6) &&
      emptyCells.contains(7)) {
    return 3;
  }
  if (cpu.isLocatedAt(1) &&
      cpu.isLocatedAt(5) &&
      emptyCells.contains(3) &&
      emptyCells.contains(4) &&
      emptyCells.contains(7)) {
    return 7;
  }
  if (cpu.isLocatedAt(5) &&
      cpu.isLocatedAt(9) &&
      emptyCells.contains(3) &&
      emptyCells.contains(7) &&
      emptyCells.contains(8)) {
    return 7;
  }
  if (cpu.isLocatedAt(5) &&
      cpu.isLocatedAt(7) &&
      emptyCells.contains(1) &&
      emptyCells.contains(8) &&
      emptyCells.contains(9)) {
    return 9;
  }
  if (cpu.isLocatedAt(5) &&
      cpu.isLocatedAt(3) &&
      emptyCells.contains(6) &&
      emptyCells.contains(1) &&
      emptyCells.contains(9)) {
    return 9;
  }
  if (emptyCells.length == 8 &&
      (player.isLocatedAt(1) ||
          player.isLocatedAt(3) ||
          player.isLocatedAt(7) ||
          player.isLocatedAt(9))) {
    return 5;
  }
  if (emptyCells.length == 6 &&
      cpu.isLocatedAt(5) &&
      ((player.isLocatedAt(1) && player.isLocatedAt(9)) ||
          (player.isLocatedAt(3) && player.isLocatedAt(7)))) {
    return 2;
  }
  if (player.isLocatedAt(2) &&
      player.isLocatedAt(4) &&
      emptyCells.contains(1)) {
    return 1;
  }
  if (player.isLocatedAt(2) &&
      player.isLocatedAt(6) &&
      emptyCells.contains(3)) {
    return 3;
  }
  if (player.isLocatedAt(4) &&
      player.isLocatedAt(8) &&
      emptyCells.contains(7)) {
    return 7;
  }
  if (player.isLocatedAt(6) &&
      player.isLocatedAt(8) &&
      emptyCells.contains(9)) {
    return 9;
  }
  // if you faild to find the best move, then try to choose the center or the corners, if they are occupied, then choose the first empty cell
  if (emptyCells.contains(5)) {
    return 5;
  }
  if (emptyCells.contains(1)) {
    return 1;
  }
  if (emptyCells.contains(3)) {
    return 3;
  }
  if (emptyCells.contains(7)) {
    return 7;
  }
  if (emptyCells.contains(9)) {
    return 9;
  }
  return emptyCells[0];
}
