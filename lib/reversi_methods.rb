# frozen_string_literal: true

require_relative './position'
require 'debug'

module ReversiMethods
  WHITE_STONE = 'W'
  BLACK_STONE = 'B'
  BLANK_CELL = '-'

  def build_initial_board
    # boardは盤面を示す二次元配列
    board = Array.new(8) { Array.new(8, BLANK_CELL) }
    board[3][3] = WHITE_STONE # d4
    board[4][4] = WHITE_STONE # e5
    board[3][4] = BLACK_STONE # d5
    board[4][3] = BLACK_STONE # e4
    board
  end

  def output(board)
    puts "  #{Position::COL.join(' ')}"
    board.each_with_index do |row, i|
      print Position::ROW[i]
      row.each do |cell|
        case cell
        when WHITE_STONE then print ' ○'
        when BLACK_STONE then print ' ●'
        else print ' -'
        end
      end
      print "\n"
    end
  end

  def copy_board(to_board, from_board)
    from_board.each_with_index do |cols, row|
      cols.each_with_index do |cell, col|
        to_board[row][col] = cell
      end
    end
  end



  def put_stone(board, cell_ref, stone_color, dry_run:false)
      pos = Position.new(cell_ref)
      raise '無効なポジションです' if pos.invalid?
      raise '既に石が置かれています' unless pos.stone_color(board) == BLANK_CELL

      copied_board = Marshal.load(Marshal.dump(board))
      copied_board[pos.row][pos.col] = stone_color
      turn_succeded = false
      Position::DIRECTIONS.each do |direction|
        next_pos = pos.next_position(direction)
        turn_succeded = true if turn(copied_board, next_pos, stone_color, direction)
      end

      copy_board(board, copied_board) if !dry_run && turn_succeded
      print "turn_succeded: #{turn_succeded}\n"

      turn_succeded
  end

  def turn(board, target_pos, attack_stone_color, direction)
    return false if target_pos.out_of_board?
    return false if target_pos.stone_color(board) == attack_stone_color

    next_pos = target_pos.next_position(direction)
    if (next_pos.stone_color(board) == attack_stone_color) || turn(board, next_pos, attack_stone_color, direction)
      board[target_pos.row][target_pos.col] = attack_stone_color
      true
    else
      false
    end
  end

  def finished?(board)
    !placeable?(board, WHITE_STONE) && !placeable?(board, BLACK_STONE)
  end
  
  def placeable?(board, attack_stone_color)
    board.each_with_index do |cols, row|
      cols.each_with_index do |cell, col|
        next unless cell == BLANCK_CELL
        position = Position.new(row, col)
        return true if put_stone(board, position.to_cell_ref, attack_stone_color, dry_run: true)
      end
    end
  end

  def finished?(board)
    !placeable?(board, WHITE_STONE) && !placeable?(board, BLACK_STONE)
  end

  def placeable?(board, attack_stone_color)
    board.each_with_index do |cols, row|
      cols.each_with_index do |cell, col|
        next unless cell == BLANK_CELL
        position = Position.new(row, col)
        return true if put_stone(board, position.to_cell_ref, attack_stone_color, dry_run: true)
      end
    end
  end

  def count_stone(board, stone_color)
    board.flatten.count { |cell| cell == stone_color }
  end
end
