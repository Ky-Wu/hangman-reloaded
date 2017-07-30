require 'sinatra'
require 'sinatra/reloader' if development?

@@hangmen_won = 0
class Hangman
  attr_accessor :word, :incorrect_letters, :display, :countdown
  def initialize
    generate_word
    @incorrect_letters = []
    @countdown = 11
    @display = []
    @word.length.times { @display << '_'}
  end

  def generate_word
    word ||= ''
    words = File.open("./public/5desk.txt").readlines
    until word.length <= 12 && word.length >= 5
      word = words.sample.strip!
    end
    @word = word
  end

  def process(guess)
    if guess.nil?
      $message = "Welcome to Hangman! Guess one letter at a time and"\
                 " if you guess the whole word, you win!"
      return
    elsif !valid_input?(guess)
      $message = "Please guess a letter you have not guessed before."
      return
    end
    letters = @word.split('')
    letters.each_with_index do |letter, index|
      if letter.downcase == guess
        @display[index] = letter
        $message = "You got a letter right!"
      end
    end
    unless letters.include?(guess)
      @countdown -= 1
      @incorrect_letters << guess
      $message = "You didn't get that letter right."
    end
  end

  def game_over
    if @countdown == 0
      $message = "You ran out of guesses!"
      return true
    elsif @word == @display.join
      $message = "You correctly guessed the word #{@word}! "\
                 "Try to guess the new word."
      @@hangmen_won += 1
      return true
    end
  end

  def valid_input?(input)
    input = input.downcase
    if input.length != 1 || @incorrect_letters.include?(input) ||
      @display.include?(input) || !('a'..'z').include?(input)
      false
    else
      true
    end
  end
end

game ||= Hangman.new

get '/' do
  guess = params["guess"]
  game.process(guess)
  if game.game_over
    game = Hangman.new
  end
  erb :index, :locals => {
    word: game.word,
    incorrect_letters: game.incorrect_letters,
    countdown: game.countdown,
    display: game.display,
    message: $message,
    hangmen_won: @@hangmen_won
  }
end
