# frozen_string_literal: true

$: << File.join(File.expand_path(File.dirname(__FILE__)), 'lib')

require_relative 'lib/commands'
require_relative 'lib/settings'
require_relative 'lib/characters/player'

require 'colorize'
require 'yaml'

module BanditMayhem
  class Game
    class Commands < BanditMayhem::Commands
      def initialize(game_obj)
        @game = game_obj
        @descriptions = {
          '/save_game (save_name)' => 'Save your game',
          '/load_game (save_name)' => 'Load your save game',
          '/quit' => 'Quit out of the game',
          '/history' => 'Show the history of commands you\'ve used',
          # '/get_av (av)' => 'Get an attribute value',
          # '/set_av (av)' => 'Set an attribute value',
          '/use (item_id_or_name)' => 'Use an item',
          '/inv' => 'Shows your items',
          '/help' => 'Shows this menu',
          '/stats' => 'List the stats of your character'
        }

        @descriptions << {
          '/test_fight [bandit]' => 'Fight an enemy. Defaults to a Bandit',
          '/test_shop' => 'Visit the shop to buy supplies.'
        } if @game.devmode
      end

      # === COMMANDS ===
      # quit out of the game
      def quit(args)
        @game.quit = true
      end

      # quit out of the game
      def exit(args)
        quit(args)
      end

      # show the history of commands.
      def history(args)
        puts @game.cmds
      end

      def save_game(args)
        save_name = args.first.to_s
        save_name = 'savegame' if save_name == ''

        _loc = @game.player.location

        save = {
          location: {map: _loc[:map].attributes['name'], x: _loc[:x], y: _loc[:y] },
          player: @game.player,
          maps: {}
        }

        File.open("#{save_name}.yml", 'w') { |s| s.write(save.to_yaml) }

        puts 'Game Saved'.light_blue
      end

      def load_game(args)
        puts 'loading'
      end

      # use an item.
      def use(args)
        @game.player.use_item(args.first.to_i)
      end

      # show the player's current items.
      def inv(args)
        @game.player.items.each do |item|
          puts @game.player.items.index(item).to_s + '. ' + item.attributes[:name].green + ' : ' + item.attributes[:description].green
        end
      end

      # list the player's statistics.
      def stats(args)
        puts @game.player.to_yaml
      end
    end

    attr_accessor :player, :quit, :cmds, :devmode, :media_player

    # game initialization
    def initialize(name)
      @cmds = []
      @settings = BanditMayhem::Settings.new
      @player = BanditMayhem::Characters::Player.new({name: name})
      @command_proc = Commands.new(self)

      @devmode = true

      @quit = false

      Utils.cls
    end

    # This is the main game loop.
    def main
      update
    end

    def draw
    end

    def update
      # show health

      # Utils.cls
      @player.location[:map].draw_map(@player)
      puts '-----' + @player.get_av('name').to_s.blue + '-----'
      puts @player.get_av('health').to_s.red + 'hp'
      puts '$' + @player.get_av('gold').to_s.yellow
      puts 'Weapon: ' + @player.weapon.get_property('name').to_s.green if @player.weapon
      puts ''
      puts "Enter a command (type #{'/help'.magenta} for commands) (#{'w'.magenta},#{'a'.magenta},#{'s'.magenta},#{'d'.magenta} to move)"

      cmd = gets.chomp
      # cmd = '/save test'

      if cmd[0] == '/'
        @command_proc.execute(cmd)
      else
        # move the character
        dirs = cmd.split ' '
        dirs.each do |direction|
          @player.move(direction)
        end
      end
    end
  end
end

if __FILE__ == $0
  if $2
    game = BanditMayhem::Game.new $2
  else
    game = BanditMayhem::Game.new 'Nigel'
  end

  while true
    break if game.quit
    game.main # loop
  end

  puts 'thanks for playing bandit mayhem!'.green
end
