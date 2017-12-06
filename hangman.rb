require_relative 'graphics'
require 'yaml'

class Hangman

  def initialize()
    @timer = 6
    @image = Graphics.new
    @kill = false
    @answer = []
    @correct_guesses = []
    @incorrect_guesses = []
    select_word()
    @secret_word.size.times { @answer << "_" }
    menu()
  end

  def start_game
    while !@kill
      # receive input, which is either a guess or save data
      game_state()
      input = get_input()
      # analyze guess
      # change timer if guess is wrong -- do it in analyze
      analyze(input)
      game_over("lose") if @timer == 0
    end
  end

  private

  def select_word
    dict = File.readlines("./5desk.txt")
    dict.select! { |word| word.strip.size.between?(5, 12) }
    @secret_word = dict.sample.strip.downcase
  end

  def menu
    puts "    --------------------------"
    puts "    |   WELCOME TO HANGMAN   |"
    puts "    --------------------------"
    puts "    | 1. Start New Game      |"
    puts "    | 2. Load Game           |"
    puts "    | 3. HALP                |"
    puts "    | 4. Quit                |"
    puts "    --------------------------"
    choice = 0
    while !choice.between?(1, 4)
      puts "Please enter a valid option." if choice != 0
      print "> "
      choice = gets.chomp.to_i
    end
    case choice
    when 1 then start_game()
    when 2 then load_game()
    when 3 then help()
    when 4 then exit
    end
  end

  def game_state
    puts @image.state[6-@timer]
    print "| "
    @answer.each { |letter| print "#{letter} "}
    print "|\n"
    puts "======================="
    print "| Incorrect Guesses: "
    @incorrect_guesses.each { |letter| print "#{letter }" }
    print "|\n"
  end

  def get_input
    puts "Guess a letter, or enter 'save' to save your game."
    input = ""
    while (input.downcase.size != 1) && (input.downcase != 'save')
      print "> "
      input = gets.chomp
    end
    input
  end

  def retry_input
    puts "You have already guessed that letter."
    analyze(get_input)
  end

  def analyze(input)
    if input == "save"
      save_game()
    else
      if @secret_word.include?(input)
        if !@correct_guesses.include?(input)
          correct_guess(input)
        else
          retry_input()
        end
      else
        if !@incorrect_guesses.include?(input)
          incorrect_guess(input)
        else
          retry_input()
        end
      end
    end

  end

  def save_game
    File.open("game.save", "w") { |file| file.puts YAML::dump(self) }
    puts "Game saved successfully!  We'll see you again soon to finish this game!"
    exit
  end

  def load_game
    if File.exist?("game.save")
      hangman = YAML.load_file("game.save")
      hangman.start_game
    else
      puts "No game save data found."
      menu()
    end
  end

  def correct_guess(input)
    @secret_word.size.times do |idx|
      @answer[idx] = input if @secret_word[idx] == input
      game_over("win") if @answer.join('') == @secret_word
    end
    @correct_guesses << input
  end

  def incorrect_guess(input)
    @incorrect_guesses << input
    @timer -= 1
  end

  def game_over(condition)
    @kill = true
    game_state()
    puts "The secret word was #{@secret_word.upcase}"
    puts "You #{condition}!"
    puts "[ENTER] to continue"
    gets
    File.delete("game.save") if File.exist?("game.save")
    system("clear") || system("cls")
    initialize()
    menu()
  end

  def help
    puts "HANGMAN is a word-guessing game."
    puts "Every new game has a different word between 5 and 12 letters."
    puts "Each round, you will guess a letter."
    puts "If the letter you guessed is in the word, it will fill in."
    puts "If not, the hangman will slowly draw in."
    puts "When the hangman is completely drawn, the game is over, so guess quick!"
    puts "Note that there is a SAVE functionality, but it's not for cheating!"
    puts "Upon reaching a GAME OVER, your save will be deleted."
    puts "HAVE FUN!!"
    menu()
  end
end

hangman = Hangman.new
