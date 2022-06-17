# frozen_string_literal: true

require 'io/console'

module BanditMayhem
  # Player
  class Player < Character
    # Get input from the player
    def await_interaction(prompt = '⋯'.magenta)
      puts prompt

      char = $stdin.getch
      # char = 'w'

      return yield char if block_given?

      case char
      when '/'
        print '/'.magenta

        command = gets
        puts command

        exit if /q|quit|exit/.match?(command)
        Game.save if /save/.match?(command)

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
      context 'This bed looks comfy', await: false if what.is_a?(Map::Poi::Bed)

      super(what)
    end

    def ui
      <<~PROMPT
        Health: #{health.to_s.red}/#{max_health.to_s.red}
        Wallet: $#{gold.to_s.yellow}

        Enter a command or move (#{'/help'.magenta} for options). (move: #{'w'.magenta}, #{'a'.magenta}, #{'s'.magenta}, #{'d'.magenta})
      PROMPT
    end

    def initialize(attrs)
      super(attrs)

      save_game = Game.load_save

      return unless save_game[:player]

      merge_attributes save_game[:player] # load Player
      merge_attributes map: save_game[:player][:map] # load map
    end

    def move(direction)
      super(direction)


      return if Game.map == map

      # autosave & change the map
      Game.save
      Game.map = map
    end

    # Player name
    def to_s
      name
    end
  end
end
