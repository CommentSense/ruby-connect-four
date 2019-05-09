# Ruby Assignment Code Skeleton
# Nigel Ward, University of Texas at El Paso
# April 2015, April 2019 
# borrowing liberally from Gregory Brown's tic-tac-toe game

#------------------------------------------------------------------
class Board
  def initialize
    @board = [[nil, nil, nil, nil, nil, nil, nil],
              [nil, nil, nil, nil, nil, nil, nil],
              [nil, nil, nil, nil, nil, nil, nil],
              [nil, nil, nil, nil, nil, nil, nil],
              [nil, nil, nil, nil, nil, nil, nil],
              [nil, nil, nil, nil, nil, nil, nil]]
  end

  def copy
    newBoard = Board.new
    newBoard.setBoard(Marshal.load(Marshal.dump(@board)))
    return newBoard
  end

  def setBoard(board)
    @board = board
  end

  # process a sequence of moves, each just a column number
  def addDiscs(first_player, moves)
    players = if first_player == :R
      [:R,:O].cycle
    else
      [:O, :R].cycle
    end
    moves.each {|c| addDisc(players.next, c)}
  end
  
  def addDisc(player, column)
    if column >= 7 || column < 0
      puts "  addDisc(#{player},#{column}): out of bounds; move forfeit"
    end
    first_free_row = @board.transpose.slice(column).index(nil)
    if first_free_row == nil
      puts "  addDisc(#{player},#{column}): column full already; move forfeit"
    end
    update(first_free_row, column, player)
  end

  def update(row, col, player)
    @board[row][col] = player
  end

  def print
    puts @board.reverse_each.map {|row| row.map {|e| e || " "}.join("|")}.join("\n")
    puts "\n"
  end

  def hasWon? (player)
    return verticalWin?(player) | horizontalWin?(player) |
        diagonalUpWin?(player) | diagonalDownWin?(player)
  end

  def verticalWin? (player)
    (0..6).any? {|c| (0..2).any? {|r| fourFromTowards?(player, r, c, 1, 0)}}
  end

  def horizontalWin? (player)
    (0..3).any? {|c| (0..5).any? {|r| fourFromTowards?(player, r, c, 0, 1)}}
  end

  def diagonalUpWin? (player)
    (0..3).any? {|c| (0..2).any? {|r| fourFromTowards?(player, r, c, 1, 1)}}
  end

  def diagonalDownWin? (player)
    (0..3).any? {|c| (3..5).any? {|r| fourFromTowards?(player, r, c, -1, 1)}}
  end

  def fourFromTowards?(player, r, c, dx, dy)
    return (0..3).all? {|step| @board[r + step * dx][c + step * dy] == player}
  end

end # Board
#------------------------------------------------------------------
=begin
  The strategy for the robot is fairly simple, first we check for winning moves
  then we worry about blocking the players moves, after we avoid helping them win, 
  and lastly add Discs to build a win
=end
def robotMove(board) # stub
  block = block(board)
  # detect any moves to avoid and remove them
  avoid = avoidMoves(board)
  moves = [0,1,2,3,4,5,6]
  moves -= avoid if !avoid.nil?
  # check for winning moves
  winMove = buildWin(board, moves)
  
  if !winMove.nil?
    board.addDisc(:O, winMove)
  elsif !block.nil? # move to block detected
    board.addDisc(:O, block)
  else
    board.addDisc(:O, moves.sample)
  end
  #return rand(7)   
end

=begin
  We duplicate the board and we check for every move if any will
  cause a win for the opponent. If so we insert our disc there to block
=end

def block(board)
  i = 0
  while i < 7
    # duplicate the board
    testBoard = board.copy
    # add the index you want to test for 
    testBoard.addDisc(:R, i)
    # if index you are test for wins then return index to block
    return i if testBoard.hasWon?(:R)
    # clear the test board
    testBoard = Board.new
    i += 1
  end
  # no wins detected return -1
  return nil   
end

=begin 
 The only way that you can 'help' the opponenet win is if their 
 disc is placed on top of yours. Horizantaly your disc has no helpful 
 value, and only verticaly can you help the opponent win so we check for that.
=end
def avoidMoves(board)
  i = 0
  avoid = Array.new
  while i < 7
    # duplicate the board
    testBoard = board.copy
    # add the index you want to test for 
    testBoard.addDisc(:O, i)
    testBoard.addDisc(:R, i)
    # if index you are test for wins then add index to avoid list
    avoid.push(i) if testBoard.hasWon?(:R)
    # clear the test board
    testBoard = Board.new
    i += 1
  end
  # no wins detected return nil
  return nil
end

=begin
  Builds moves to achieve vertical and diagonal wins
  first checks if a win is clearly available if not it
  adds disc at a random available moveset
=end
def buildWin(board, moves)
  moveSet = moves.each {|move| # for each available move
    testBoard = board.copy # duplicate original board
    testBoard.addDisc(:O, move) # add move to the board
    move if (testBoard.diagonalDownWin?(:O) || # then add if it generates a win
      testBoard.diagonalUpWin?(:O) || 
      testBoard.verticalWin?(:O))
  }
  if !moveSet.nil? # select a moveset that allows for win
    return moveSet.sample
  else # if not take a random move from the available moves
    return nil
  end
end

#------------------------------------------------------------------
def testResult(testID, move, targets, intent)
  if targets.member?(move)
    puts("testResult: passed test #{testID}")
  else
    puts("testResult: failed test #{testID}: \n moved to #{move}, which wasn't one of #{targets}; \n failed: #{intent}")
  end
end

#loop to play the game
board = Board.new
while !board.hasWon?(:R) && !board.hasWon?(:O)
  move = gets.chomp.to_i
  # If the input is not within range redo loop
  board.addDisc(:R, move)
  robotMove(board)
  board.print
end

#------------------------------------------------------------------
# test some robot-player behaviors
# testboard1 = Board.new
# testboard1.addDisc(:R,4)
# testboard1.addDisc(:O,4)
# testboard1.addDisc(:R,5)
# testboard1.addDisc(:O,5)
# testboard1.addDisc(:R,6)
# testboard1.addDisc(:O,6)
# testResult(:hwin, robotMove(:R, testboard1),[3], 'robot should take horizontal win')
# testboard1.print
#
# testboard2 = Board.new
# testboard2.addDiscs(:R, [3, 1, 3, 2, 3, 4]);
# testResult(:vwin, robotMove(:R, testboard2), [3], 'robot should take vertical win')
# testboard2.print
#
# testboard3 = Board.new
# testboard3.addDiscs(:O, [3, 1, 4, 5, 2, 1, 6, 0, 3, 4, 5, 3, 2, 2, 6 ]);
# testResult(:dwin, robotMove(:R, testboard3), [3], 'robot should take diagonal win')
# testboard3.print
#
# testboard4 = Board.new
# testboard4.addDiscs(:O, [1,1,2,2,3])
# testResult(:preventHoriz, robotMove(:R, testboard4), [4], 'robot should avoid giving win')
# testboard4.print