# frozen_string_literal: true

Encoding.default_external = 'UTF-8'

require 'zeitwerk'
require 'core_ext/string/inflections'
require 'symbolized'

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
    end

    # Start a new game with a specific player name
    #
    # @param [String] player_name the name of the player
    # @return [Game]
    def initialize(player_name)
      # Load the game on game start
      Game.load_save if File.exist?(DEFAULT_SAVE)
      Game.player = Player.new(name: player_name, health: 30, x: 1, y: 5, map: BanditMayhem::Map::Map.new('lynwood/strick_household'))

      @quit = false
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
      cls

      Game.map.draw_map

      trap('SIGINT') { puts 'Goodbye!'; exit }

      Game.player.await_interaction(Game.player.ui)
    end
  end
end
