# frozen_string_literal: true

# Main game class
class Game
  def start
    puts 'Welcome to hangman! Will you hang or cut free?'
    # load_game
    game_loop
  end

  # rubocop: disable Metrics/MethodLength
  def game_loop
    tries = 0
    random_word = pick_random_word
    letters = random_word.split(//)

    while tries <= 12
      letter = gets.chomp
      if letters.include? letter
        guessed << letter
        won = game_board(letters, guessed)

        if won
          puts 'Victory!'
          break
        end
      else
        tries += 1
        puts "You have (12 - #{tries}) guesses left."
      end
    end
  end
  # rubocop: enable Metrics/MethodLength

  def pick_random_word
    File.readlines('google-10000-english-no-swears.txt').sample
  end

  def game_board(letters, guessed)
    won = true

    letters.each do |l|
      if guessed.include? l
        print l
      elsif print '_ '
        won = false
      end
    end

    puts '\n \n'

    won
  end
end
