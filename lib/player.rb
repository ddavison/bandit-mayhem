# frozen_string_literal: true

require 'io/console'

module BanditMayhem
  # Player
  class Player < Character
    # Get input from the player
    def await_interaction
      puts <<~PROMPT
        Health: #{health.to_s.red}
        Wallet: $#{gold.to_s.yellow}

        Enter a command or move (#{'/help'.magenta} for options). (move: #{'w'.magenta}, #{'a'.magenta}, #{'s'.magenta}, #{'d'.magenta})
      PROMPT

      char = $stdin.getch

      case char
      when '/'
        print '/'.magenta

        command = gets
        puts command

        exit if /q|quit|exit/.match?(command)

        # TODO: refactor later
        if command.start_with? 'warp'
          _, x, y = command.split(' ')

          warp(x: x.to_i, y: y.to_i)
        end
      when 'w'
        up
      when 'a'
        left
      when 's'
        down
      when 'd'
        right
      else
        # ignore
        # raise MovementError, "Cannot move in the direction `#{char}`"
      end
    end

    def interact_with(what)
      warn 'Teleporting through door' if what.is_a?(Map::Poi::Door)

      warn 'Engaging in conversation' if what.is_a?(Npc)

      puts "You found #{what.value}" if what.is_a?(Map::Poi::Coinpurse)

      puts "You found an item #{what}" if what.is_a?(Map::Poi::Item)

      super
    end

    def move(direction)
      super(direction)

      # change map
      Game.map = map unless Game.map == map
    end

    # Player name
    def to_s
      name
    end
  end
end
