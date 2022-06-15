# frozen_string_literal: true

Encoding.default_external = 'UTF-8'

require 'zeitwerk'
require 'core_ext/string/inflections'

# Main game object
module BanditMayhem
  loader = Zeitwerk::Loader.new
  loader.push_dir(__dir__, namespace: BanditMayhem)

  loader.setup

  # Main Game object
  class Game
    class << self
      attr_writer :map

      def player
        @player ||= Player.new(name: 'Nigel', x: 1, y: 5, map:)
      end

      def map
        @map ||= Map.new('lynwood/strick_household')
      end
    end

    # Start a new game with a specific player name
    #
    # @param [String] player_name the name of the player
    # @return [Game]
    def initialize(player_name)
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

    # Save the game file
    def save; end

    # Load a game save file
    def load; end

    # Main game loop
    def update
      # Utils.cls
      Game.map.draw_map

      trap('SIGINT') { puts 'Goodbye!'; exit }

      Game.player.await_interaction
    end
  end
end
