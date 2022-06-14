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
      when 'w'
        up
      when 'a'
        left
      when 's'
        down
      when 'd'
        right
      else
        raise MovementError, "Cannot move in the direction `#{char}`"
      end
    end

    # Player name
    def to_s
      name
    end
  end
end
