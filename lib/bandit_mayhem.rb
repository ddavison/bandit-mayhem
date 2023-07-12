# frozen_string_literal: true

Encoding.default_external = 'UTF-8'

require 'zeitwerk'

require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/hash/indifferent_access'

require 'yaml'

# Main game object
module BanditMayhem
  loader = Zeitwerk::Loader.new
  loader.push_dir(__dir__, namespace: BanditMayhem)

  # Game objects (classes) allowed to be loaded from YAML.safe_load_file
  loader.on_setup do
    loader.autoloads.values.map do |load|
      load.first.const_get(load.last)
    end
  end

  loader.setup

  GameSaveError = Class.new(IOError)

  # Main Game object
  class Game
    DEFAULT_SAVE = '.bandit-mayhem.save'

    class << self
      attr_writer :map
      attr_accessor :player

      def map
        @map ||= player.map
      end

      # Save the game
      #
      # @note this loads the game first, if a save exists
      def save
        File.write(
          DEFAULT_SAVE,
          YAML.dump(
            load_save.tap do |save|
              save[:name] = 'default'

              save[:player] = player

              save[:maps] = (save[:maps] || {}).merge!(Game.map.file => Game.map)
            end
          )
        )
      end

      # Load the game save
      def load_save
        return {} unless File.exist?(DEFAULT_SAVE)

        save_file_contents = YAML.unsafe_load_file(DEFAULT_SAVE)
        save_file_contents ||= {} # if game save file is empty

        raise GameSaveError, 'Invalid game save format.' unless save_file_contents.is_a?(Hash)

        save_file_contents.to_symbolized_hash
      end

      def engine
        @engine ||= Engine.new
      end
    end

    # Start a new game with a specific player name
    #
    # @param [String] player_name the name of the player
    # @return [Game]
    def initialize
      Game.engine.draw(Game.engine.markdown.parse('# Bandit Mayhem'))
      selection = Game.engine.prompt.select('Select an option', 'New game', 'Load game', 'Quit')

      case selection
      when 'New game'
        save_name = Game.engine.prompt.ask('Enter save name:', default: 'bandit-mayhem')

        Game.player = Player.new(name: 'Nigel', health: 30, x: 1, y: 5, map: BanditMayhem::Map::Map.new('lynwood/strick_household'))

        # intro
        Cinematic.new('intro').play

        @quit = false
      when 'Load game'
        Game.load_save if File.exist?(DEFAULT_SAVE)
        # TODO fix
        # Game.player = Player.new(name: 'Nigel', health: 30, x: 1, y: 5, map: BanditMayhem::Map::Map.new('lynwood/strick_household'))
        @quit = false
      when 'Quit'
        @quit = true
      end
    end

    # Game start point
    def play!
      update
    end

    def quit!
      @quit = true
    end

    def quit?
      @quit
    end

    def cls
      if RUBY_PLATFORM =~ /win32|win64|\.NET|windows|cygwin|mingw32/i
        system('cls')
      else
        system('clear')
      end
    end

    # Main game loop
    def update
      trap('SIGINT') { puts 'Goodbye!'; exit }

      cls
      Game.map.draw_map

      # GET INPUT
      Game.engine.draw(Game.engine.markdown.parse(Game.player.ui))
      Game.player.await_interaction(<<~PROMPT)
        ⎧ #{'w'.green} (up), #{'a'.green} (left), #{'s'.green} (down), #{'d'.green} (right), #{'<tab>'.green} (inventory) ⎭
        #{'☞ '.magenta}
      PROMPT
    end
  end
end
