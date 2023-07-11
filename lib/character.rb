# frozen_string_literal: true

require 'attributable'

module BanditMayhem
  # Character
  class Character
    include Attributable
    include Interactable

    attribute :name, 'Somebody'
    attribute :health, 100
    attribute :max_health, 100
    attribute :str, 10
    attribute :def, 0
    attribute :gold, 0

    # The avatar which to print (ASCII art)
    attribute :avatar

    # The factions to which this character belongs
    attribute :factions, []

    # What map this character belongs to
    attribute :map

    # character's position in the map
    attribute :x, -1
    attribute :y, -1

    # Items in inventory
    attribute :items, Inventory.new

    MovementError = Class.new(RuntimeError)

    # Create a new character
    #
    # @param [Hash] attrs player attributes
    # @option attrs [String] :name the name of the character
    # @option attrs [String] :health the health of the character
    # @option attrs [String] :max_health the max health of the character
    # @option attrs [String] :str the character's strength
    # @option attrs [String] :def the character's defense
    # @option attrs [String] :gold the character's gold
    # @option attrs [String] :x the X coordinate on the map where the character is located
    # @option attrs [String] :y the Y coordinate on the map where the character is located
    def initialize(attrs)
      merge_attributes attrs
    end

    # Is the character deceased?
    #
    # @return [Boolean] true if the character's health is less-than or equal-to zero
    def dead?
      health <= 0
    end

    # Move the character up if able
    def up
      yield north if block_given?

      move(:up) if can_move?(:up)
    end

    # Move the character down if able
    def down
      yield south if block_given?

      move(:down) if can_move?(:down)
    end

    # Move the character left if able
    def left
      yield west if block_given?

      move(:left) if can_move?(:left)
    end

    # Move the character right if able
    def right
      yield east if block_given?

      move(:right) if can_move?(:right)
    end

    # Get the entity, in the map, to the north of the character. nil if none
    #
    # @return [Map::Pois,Npc,nil]
    def north
      map.at(x:, y: y - 1)
    end

    # Get the entity, in the map, to the south of the character. nil if none
    #
    # @return [Map::Pois,Npc,nil]
    def south
      map.at(x:, y: y + 1)
    end

    # Get the entity, in the map, to the west of the character. nil if none
    #
    # @return [Map::Pois,Npc,nil]
    def west
      map.at(x: x - 1, y:)
    end

    # Get the entity, in the map, to the east of the character. nil if none
    #
    # @return [Map::Pois,Npc,nil]
    def east
      map.at(x: x + 1, y:)
    end

    # ==== MAIN BATTLE FUNC === #
    def battle(enemy)
      set_av('attacks', 0)
      enemy.set_av('attacks', 0)

      @in_battle = true

      # self will always go first.
      players_turn = true

      Utils.cls

      puts "\t\t\t\tBATTLING: #{enemy.get_av('name')}".green
      puts "\t\t" + enemy.get_av('avatar', '(no avatar)').to_s + "\n\n"

      while @in_battle
        puts 'Your health: ' + get_av('health').to_s.red
        puts enemy.get_av('name') + '\'s health: ' + enemy.get_av('health').to_s.red
        puts '------------------------'

        if players_turn
          puts 'Your turn...'.green
          fight_menu(enemy)

          loot(enemy) if enemy.dead?
          players_turn = false
          @location[:map].remove_entity(@location)
        else
          # for now, all the enemy will do, is attack.
          puts "#{enemy.get_av('name')}'s turn...".red

          attack(enemy)
          players_turn = true
        end
      end
    end

    # return hash
    def attack(target)
      total_dmg = (calculate_attack_damage)
      target_health_after = target.get_av('health') - total_dmg

      battle_aftermath = {
        damage_dealt: total_dmg,
        target_health_before: target.get_av('health'),
        target_health_after: target_health_after
      }.to_symbolized_hash

      target.set_av('health',
        target.get_av('health') - total_dmg
      )

      puts "\n" + get_av('name').to_s.red + ' attacked ' + target.get_av('name').to_s.blue + ' for ' + total_dmg.to_s.green + " dmg.\n-----------------"

      set_av('attacks',
        get_av('attacks', 0).to_i + 1
      )

      if target.dead?
        puts src.get_av('name').to_s.red + ' has slain ' + target.get_av('name').to_s.blue
        battle_aftermath[:target_died] = true
        @in_battle = false
      end

      battle_aftermath
    end

    def fight_menu(enemy)
      puts 'Fight options...'
      puts '----------------'
      puts '1. ' + 'Attack'.red
      puts '2. ' + 'Run'.green
      puts '3. ' + 'Use item'.blue
      puts 'Enter an option:'

      STDOUT.flush
      cmd = gets.chomp
      cmd = cmd.to_i

      if cmd.eql? 1
        # attack
        attack(enemy)
      elsif cmd.eql? 2
        if BanditMayhem::Utils.shuffle_percent(get_av('luck'))
          # run away
          @in_battle = false
          puts 'You ran away'.green
          # sleep(1)
          Utils.cls
        else
          puts 'The bandit grabs you by your gear and pulls you back into the fight.'.red
          # sleep(1)
          Utils.cls
        end
      elsif cmd.eql? 3
        # show the inventory, then let them choose.
        show_inventory
        puts 'Enter an item to use:'
        STDOUT.flush
        item = gets.chomp
        use_item(item.to_i)
      end
    end

    # Say something
    #
    # @param [String] message what to say
    def say(message)
      puts "#{name.cyan}: #{message}"

      Game.player.await_interaction
    end

    # Warp somewhere
    #
    # @param [Map] map the new map to warp to
    # @param [Integer] x the X coordinate
    # @param [Integer] y the Y coordinate
    def warp(x: self.x, y: self.y, map: self.map)
      self.map = if map.is_a?(Map::Map)
                   map
                 else
                   Map::Map.new(map)
                 end

      self.x = x
      self.y = y

      interact_with(self.map.at(x:, y:))
    end

    def interact_with(what)
      super

      map.remove(what) if what.is_a?(Consumable)
    end

    # Character's name
    def to_s
      name
    end

    private

    # Move the character in a specific direction
    #
    # @param [Symbol] direction
    # @option direction [Symbol] :up
    # @option direction [Symbol] :down
    # @option direction [Symbol] :left
    # @option direction [Symbol] :right
    def move(direction)
      case direction
      when :up, :w
        is_door = north.is_a?(Map::Pois::Door)

        if y == 1 && !is_door
          if map.north
            self.map = map.north_map

            self.y = map.height
          else
            puts "can't go north!".red
          end
        else
          interact_with(north) if north

          self.y -= 1 unless is_door
        end
      when :down, :s
        is_door = south.is_a?(Map::Pois::Door)

        if y == map.height && !is_door
          if map.south
            self.map = map.south_map

            self.y = 1
          else
            puts "can't go south!".red
          end
        else
          interact_with(south) if south

          self.y += 1 unless is_door
        end
      when :left, :a
        is_door = west.is_a?(Map::Pois::Door)

        if x == 1 && !is_door
          if map.west
            self.map = map.west_map

            self.x = map.width
          else
            puts "can't go west!".red
          end
        else
          interact_with(west) if west

          self.x -= 1 unless is_door
        end
      when :right, :d
        is_door = east.is_a?(Map::Pois::Door)

        if x == map.width && !is_door
          if map.east
            self.map = map.east_map

            self.x = 1
          else
            puts "can't go east!".red
          end
        else
          interact_with(east) if east

          self.x += 1 unless is_door
        end
      else
        raise MovementError, "Cannot move in the direction `#{direction}`"
      end
    end

    # Can this character move in a specific direction?
    #
    # @param [Symbol] direction the direction in which to check
    # @option direction [Symbol] :up Character Y - 1
    # @option direction [Symbol] :down Character Y + 1
    # @option direction [Symbol] :left Character X - 1
    # @option direction [Symbol] :right Character X + 1
    # @return [Boolean] true if can move in this direction
    def can_move?(direction)
      # if next move will not collide with a wall
      entity = case direction
               when :up
                 north
               when :down
                 south
               when :left
                 west
               when :right
                 east
               else
                 raise MovementError, "Cannot move in the direction `#{direction}`"
               end

      # TODO: add inability to move when colliding with an interior wall
      !entity.is_a?(Map::Pois::Wall)
    end

    def calculate_attack_damage
      # dmg = str + weapon.str + (level*5) + (luck / 3)
      weapon_str = 0 || weapon.attributes[:str].to_i
      (get_av('str').to_i + weapon_str + (get_av('level').to_i * 5) + (get_av('luck', 0).to_i / 3))
    end

    def calculate_defense(target)
      # def = player def + level + (luck / 5)
      (target.get_av('def').to_i + target.get_av('level').to_i + (target.get_av('luck', 0).to_i / 5))
    end
  end
end
