# frozen_string_literal: true

Encoding.default_external = 'UTF-8'

require 'zeitwerk'

require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/hash/indifferent_access'
require 'colorize'

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

      attr_accessor :player, :save_name

      def map
        @map ||= player.map
      end

      # Save the game
      #
      # @note this loads the game first, if a save exists
      def save
        File.write(
          save_name,
          YAML.dump(
            load_save(save_name).tap do |save|
              save[:name] = save_name

              save[:player] = player

              save[:maps] = (save[:maps] || {}).merge!(Game.map.file => Game.map)
            end
          )
        )
      end

      # Load the game save
      # @return [Hash] the game save
      def load_save(file)
        return {} unless File.exist?(file)

        save_file_contents = YAML.unsafe_load_file(file)
        save_file_contents ||= {} # if game save file is empty

        raise GameSaveError, 'Invalid game save format.' unless save_file_contents.is_a?(Hash)

        save_file_contents.deep_symbolize_keys!
      end

      def engine
        @engine ||= Engine.new
      end

      # Game Cinematics
      # @example
      #   Game.cinematics['intro'] #=> return the intro cinematic
      #   Game.cinematics.cinematics #=> return the raw array of all cinematics loaded
      #   Game.cinematics['intro'].played? #=> has the intro cinematic played?
      def cinematics
        # load all cinematic objects to be played
        @cinematics ||= Struct.new(:cinematics) do
          def [](name)
            cinematics.find { |c| c.name == name }
          end
        end.new(Dir[File.join(Cinematic::PATH, '/*')].map { |cin| Cinematic.new(File.basename(cin)) })
      end
    end

    # Start a new game with a specific player name
    #
    # @return [Game]
    def initialize
      Game.engine.draw(Game.engine.markdown.parse('# Bandit Mayhem'))
      selection = Game.engine.prompt.select('Select an option', 'New game', 'Load game', 'Quit')

      case selection
      when 'New game'
        Game.save_name = ".#{Game.engine.prompt.ask('Enter save name:', default: 'bandit-mayhem')}.save"
        Game.player = Player.new(name: 'Nigel', health: 30, x: 1, y: 5,
                                 map: BanditMayhem::Map::Map.new('lynwood/strick_household'))
        Game.save

        # intro
        Game.cinematics['intro'].play

        @quit = false
      when 'Load game'
        Game.save_name = Game.engine.prompt.select('Load which game', Dir['.*.save'].map { |f| File.basename(f) })
        game = Game.load_save(Game.save_name)
        Game.player = game[:player]

        @quit = false
      when 'Quit'
        @quit = true
      else
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
      trap('SIGINT') do
        Game.engine.draw('Goodbye!')
        exit
      end

      cls

      Game.engine.draw(
        Game.engine.box.frame(width: 100, height: 30, border: :thick, title: { top_left: Game.map.name.green }) do
          # map
          Game.map.generate
          Game.map.render +
          Game.engine.markdown.parse(Game.player.ui) +
          <<~PROMPT
              ⎧ #{'w'.green} (up), #{'a'.green} (left), #{'s'.green} (down), #{'d'.green} (right), #{'<tab>'.green} (inventory) ⎭
            #{'☞'.magenta}
          PROMPT
        end
      )
      Game.player.await_interaction
    end
  end
end
