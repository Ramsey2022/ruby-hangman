# frozen_string_literal: true

require 'yaml'

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
    save_game if @player_guess == 'save'
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
      @player_guess = user_input('Choose a letter. Or type save to save.  ',
                                 /^[a-z]$|^exit$|^save$/i)
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
    puts 'Thanks for playing.' if play_again == '2'
    Game.new if play_again == '1'
  end
end

# save & loading functions

def save_game
  Dir.mkdir('saved_games') unless Dir.exist?('saved_games')
  puts 'Enter name of your save file: '
  save_name = gets.chomp
  @filename = "#{save_name}_game.yaml"
  File.open("saved_games/#{@filename}", 'w') { |file| file.write save_to_yaml }
end

def save_to_yaml
  YAML.dump(
    'random_word' => @random_word,
    'available_letters' => @available_letters,
    'solved_letters' => @solved_letters,
    'incorrect_letters' => @incorrect_letters
  )
end

def find_save_file
  file_number = user_input('Enter index of save file, or exit to leave ', /\d+|^exit$/)
  @saved_game = file_list[file_number.to_i - 1] unless file_number == 'exit'
end

def file_list
  files = []
  Dir.entries('saved_games').each do |name|
    files << name if name.match(/(game)/)
  end
  files
end

def load_game
  find_save_file
  load_file
  player_turn
  File.delete("saved_games/#{@saved_game}") if File.exist?
  end_game
rescue StandardError
  puts 'Load Error'
end

def load_file
  file = YAML.safe_load(File.read("saved_games/#{@saved_game}"))
  @random_word = file['random_word']
  @letters = random_word.delete("\n").split(//)
  @available_letters = file['available_letters']
  @solved_letters = file['solved_letters']
  @incorrect_letters = file['incorrect_letters']
end

Game.new
