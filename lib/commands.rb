# frozen_string_literal: true

module BanditMayhem
  # yes
  module Commands
    extend self

    # Help menu
    def help(args = nil); end

    # Quit the game
    #
    # @note this does not save the game
    def quit
      Game.engine.draw(Game.engine.markdown.parse('# Goodbye!'))
      Kernel.exit
    end
    alias q quit
    alias exit quit

    # Warp the character to a coordinate
    #
    # @param [String] x the X coordinate
    # @param [String] y the Y coorinate
    # @note this is a CHEAT
    def warp(x, y)
      # TODO add sanitization
      Game.player.warp(x: x.to_i, y: y.to_i)
    end

    # Save the game
    def save
      Game.save

      puts 'Game saved.'.magenta
    end
  end
end
