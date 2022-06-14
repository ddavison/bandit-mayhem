# frozen_string_literal: true

require 'colorize'
require 'symbolized'

require 'commands'
require 'item'
require 'weapon'

module BanditMayhem
  class Shop
    class Commands < BanditMayhem::Commands
      def initialize(rec)
        @rec = rec
        @descriptions = {
          '/exit' => 'Leave the shop',
          '/buy [item_number]' => 'Buy an item',
          '/sell [ItemName]' => 'Sell an item from your inventory'
        }
        @player = rec.player
        @shop = rec.shop
      end

      def exit(args)
        @rec.shopping = false
        @player.location[:map].exit_location(@player)
      end

      def buy(args)
        # TODO: buy logic from IN-GAME
        # if Integer(args.first)
        #   item_index = args.first.to_i - 1
        #   begin
        #     itm = BanditMayhem::Item.by_name(@shop['inventory'][item_index])
        #   rescue
        #     itm = BanditMayhem::Weapon.by_name(@shop['inventory'][item_index])
        #   end
        #
        #   buy_value = itm.attributes[:buy_value]
        #
        #   if @player.get_av('gold').to_i < buy_value
        #     puts 'You cant afford that!'.red
        #   else
        #     @player.give(itm)
        #     @player.set_av('gold',
        #       @player.get_av('gold').to_i - buy_value
        #     )
        #   end
        # else
        #   puts "you can't buy #{args}. try again using the item code: /buy 1".red
        # end
      end

      def sell(args)
        # TODO: implement shop selling
        puts 'not implemented'.red
      end
    end

    attr_accessor :shopping,
                  :player,
                  :shop

    attr_reader :inventory

    def initialize(shop={}, player)
      @shop = shop.to_symbolized_hash
      @inventory = @shop[:inventory]
      @player = player
      @shopping = true
      @command_proc = Commands.new(self)
    end

    def shop
      Utils.cls

      puts <<-END
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$#{"   #{@shop[:name]}   " if @shop[:name] }$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
      END

      puts
      puts 'You have ' + '$'.yellow + @player.get_av('gold').to_s.yellow + ' - Buy an item using ' + '/buy'.magenta + '. Sell an item using ' + '/sell'.magenta + '. Leave using ' + '/exit'.magenta
      puts '------------Inventory-------------'
      print_inventory
      puts '----------------------------------'

      if Utils.in_game?
        cmd = gets.chomp
        @command_proc&.execute(cmd)
      end
    end

    # return the ::Item instance. no calculations are done here
    def buy!(index_or_name)
      if index_or_name.is_a? Integer
        item_index = index_or_name.to_i - 1

        begin
          item = BanditMayhem::Item.by_name(@shop[:inventory][item_index])
        rescue
          item = BanditMayhem::Weapon.by_name(@shop[:inventory][item_index])
        end

      elsif index_or_name.is_a? Array
        index_or_name.each {|a| buy!(a) }
      elsif index_or_name.is_a? String
        item = BanditMayhem::Item.by_name(index_or_name)
      end

      item
    end

    def print_inventory
      Dir['./lib/items/*'].each { |file| require file }
      Dir['./lib/weapons/*'].each { |file| require file }

      item_number = 1
      @inventory.uniq.each do |item|
        begin
          itm = BanditMayhem::Item.by_name(item)
        rescue
          p item
          itm = BanditMayhem::Weapon.by_name(item)
        end
        puts item_number.to_s + '. ' + "[$#{itm.attributes[:buy_value]}]".to_s.yellow + " #{itm.attributes[:name]}".to_s.green + " (#{itm.attributes[:description]})".to_s.blue
        item_number += 1
      end
    end
  end
end
