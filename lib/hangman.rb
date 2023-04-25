# frozen_string_literal: true

# class Game
class Game
  attr_accessor :random_word, :solved_letters, :incorrect_letters

  def initialize
    @solved_letters = []
    @incorrect_letters = []
    start_game
  end

  def start_game
    puts 'Welcome to hangman! Press 1 for new game, 2 to reload a game.'
    game_type = gets.chomp
    new_game if game_type == '1'
    load_game if game_type == '2'
  end

  def new_game
    @random_word = pick_random_word
    @letters = random_word.split(//)
    letter_board
    player_turn
    end_game
  end

  # def save_game
  # end

  # def load_game
  # end

  def pick_random_word
    File.readlines('google-10000-english-no-swears.txt').sample
  end

  def letter_board
    @letters.each do |letter|
      if @solved_letters.include? letter
        print letter
      else
        print '_ '
      end
    end

    puts "\n You have x guesses left."
  end

  def player_turn
    loop do
      player_guess_letter
      break if @player_guess.length > 1

      turn_update
      break if game_over? || game_solved?
    end
  end
  save_game if @player_guess == 'save'
end

def turn_update
  incorrect_guess unless random_word.match?(@player_guess)
  correct_guess if random_word.match?(@player_guess)
end

def player_guess_letter
  loop do
    guess_list
    @player_guess = gets.chomp.downcase
  end
end

def guess_list
  puts incorrect_letters unless incorrect_letters.empty?
  puts 'Last turn, try your best!' if incorrect_letters.length == 11
end

def correct_guess
  solved_letters << @player_guess
  puts 'correct'
end

def incorrect_guess
  incorrect_letters << @player_guess
  puts 'Incorrect'
end

def game_over?
  incorrect_letters.length == 12
end

def game_solved?
  solved_letters.all? == random_word
end

def end_game
  puts 'Victory!' if game_solved?
  puts 'Defeat.' if game_over?
end

Game.new
