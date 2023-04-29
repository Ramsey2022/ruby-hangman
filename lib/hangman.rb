# frozen_string_literal: true

# class Game
class Game
  attr_accessor :random_word, :solved_letters, :incorrect_letters, :available_letters

  def initialize
    @solved_letters = []
    @incorrect_letters = []
    @available_letters = ('a'..'z').to_a
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
    @letters = random_word.delete("\n").split(//)
    letter_blanks
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

  def letter_blanks
    @letters.each { solved_letters << '_' }
  end

  def update_solved_letters
    @letters.each_with_index do |item, index|
      solved_letters[index] = item if item.match(@letter_regex)
    end
  end

  def player_turn
    loop do
      puts solved_letters.join(' ')
      player_guess_letter
      break if @player_guess.length > 1

      turn_update
      break if game_over? || game_solved?
    end
  # save_game if @player_guess == 'save'
  end

  def turn_update
    incorrect_guess unless random_word.match(@letter_regex)
    update_solved_letters if random_word.match(@letter_regex)
    available_letters.delete(@player_guess.downcase)
  end

  def user_input(prompt, regex)
    loop do
      print prompt
      input = gets.chomp
      input.match(regex) ? (return input) : puts('Wrong input, try again')
    end
  end

  def player_guess_letter
    loop do
      incorrect_guess_list
      @player_guess = user_input('Choose a letter.  ', /^[a-z]$|^exit$|^save$/i)
      break if @player_guess.length > 1
      break if available_letters.include?(@player_guess.downcase)
    end
    @letter_regex = /#{@player_guess}/i
  end

  def incorrect_guess_list
    incorrect_list = incorrect_letters.join(' ')
    puts "You have already guessed: #{incorrect_list}" unless incorrect_letters.empty?
    puts 'Last turn, try your best!' if incorrect_letters.length == 8
  end

  def incorrect_guess
    incorrect_letters << @player_guess
    puts 'Incorrect'
  end

  def game_over?
    incorrect_letters.length == 9
  end

  def game_solved?
    solved_letters.all? { |item| item.match?(/[a-z]/i) }
  end

  def end_game
    puts "Victory!, your word was: #{@letters.join}" if game_solved?
    puts "Defeat!, your word was: #{@letters.join}" if game_over?
    play_again = user_input('Play again? 1 or 2 to exit. ', /^[1-2]$/)
    puts ('Thanks for playing.') if play_again == '2'
    Game.new if play_again == '1'
  end
end

Game.new
