# frozen_string_literal: true

require 'yaml'
require 'colorize'
require 'symbolized'

module BanditMayhem
  # Bandit Mayhem Map
  class Map
    include Attributable

    MapError = Class.new(RuntimeError)

    attribute :name
    attribute :width
    attribute :height

    # Points of Interests
    attribute :pois, []

    # NPCs
    attribute :npcs, []

    attribute :type
    attribute :interiors, []

    attribute :north
    attribute :south
    attribute :east
    attribute :west

    attr_accessor :matrix

    WALL_VERT          = '│'
    WALL_HORIZ         = '─'
    CORNER_UPPER_RIGHT = '┐'
    CORNER_UPPER_LEFT  = '┌'
    CORNER_LOWER_LEFT  = '└'
    CORNER_LOWER_RIGHT = '┘'

    INTERIOR_WALL_VERT          = '║'
    INTERIOR_WALL_HORIZ         = '═'
    INTERIOR_CORNER_UPPER_RIGHT = '╗'
    INTERIOR_CORNER_UPPER_LEFT  = '╔'
    INTERIOR_CORNER_LOWER_LEFT  = '╚'
    INTERIOR_CORNER_LOWER_RIGHT = '╝'

    DOOR               = '¤'.magenta
    CAVE               = 'O'.magenta
    SURFACE_DEFAULT    = ' '
    SURFACE_STONE      = '.'.light_black
    SURFACE_GRASS      = ','.green
    SURFACE_MARBLE     = '␣'.white
    SHOP               = '$'.yellow
    PLAYER             = '@'.cyan
    COINPURSE          = '¢'.yellow
    ITEM               = 'ꕺ'.blue
    BANDIT             = '■'.red
    OTHER              = '?'
    TREE               = '∆'.light_green
    NPC                = '¶'.cyan

    BED                = 'π'.light_blue

    SUN = '꥟'.yellow

    # Point of Interest
    class Poi
      include Attributable
      include Interactable

      attribute :name
      attribute :x
      attribute :y
      attribute :type

      # Instantiate a new Point of Interest (POI)
      #
      # @param [Hash] poi_hash well-formed hash, probably from a map YAML file
      # @return [Poi]
      def initialize(poi_hash)
        merge_attributes poi_hash
      end

      # Rune to draw on the Map
      def rune
        Map.const_get(type.upcase)
      end

      def to_s
        "(#{x}, #{y})"
      end

      # Map Wall
      class Wall < Poi
        # vert / horiz wall
        attribute :direction

        def rune
          return WALL_VERT if vertical?

          WALL_HORIZ if horizontal?
        end

        # Is this wall vertical?
        # @return [Boolean] true if vertical
        def vertical?
          /vert|vertical/.match?(direction)
        end

        # Is this wall horizontal?
        # @return [Boolean] true if horizontal
        def horizontal?
          /horiz|horizontal/.match?(direction)
        end
      end

      # Map Door
      class Door < Poi
        attribute :destination

        # Is this door unlocked?
        #
        # @return [Boolean] true if unlocked
        def unlocked?
          true
        end

        # Traverse through the door
        # @param [Character] character
        def interact_with(character)
          character.warp(**destination) if unlocked?

          return warn "Teleporting #{character} to #{destination}" if unlocked?

          warn 'Cant teleport as the door is locked'
        end
      end

      # Map Coinpurse
      class Coinpurse < Poi
        attribute :value

        # Add gold to the character's wallet
        def interact_with(what)
          what.gold += value if what.respond_to?(:gold)
        end
      end

      # Map Shop
      class Shop < Poi
        attribute :inventory, []
      end

      # Map Item
      class Item < Poi
        attribute :description

        # Add item to inventory
        def interact_with(what)
          what.items << Items.const_get(name.underscore.classify).new(current_attributes) if what.respond_to?(:items)
        end
      end

      # Map Tree
      class Tree < Poi
        # Trees can contain items hidden within them
        attribute :items
      end

      # Bed
      #
      # @note interacting with the bed will fill the characters health to max
      class Bed < Poi
        def interact_with(character)
          character.health = character.max_health
        end
      end
    end

    # Map Interior
    class Interior
      include Attributable

      attribute :name
      attribute :width
      attribute :height
      attribute :x
      attribute :y

      attribute :pois, []

      attribute :surface, Map::SURFACE_MARBLE

      attribute :door

      def initialize(interior_attrs)
        merge_attributes interior_attrs
      end

      def to_s
        name
      end
    end

    # Load a new map
    #
    # @return [Map]
    # @overload new(name)
    #   Load a map with a given name
    # @overload new(name, **attrs)
    #   @param [String] name the name of the map to load
    #   @param [Hash] attrs all additional attributes to load into the map
    #   @note use :file to load a specific map file
    def initialize(name, **attrs)
      merge_attributes load_attributes_from_map(name, attrs.delete(:file))
      merge_attributes attrs

      load_pois
      load_interiors
      load_npcs

      @boundary_width = width + 2
      @boundary_height = height + 2

      # @area = width * height
      # @perimeter = 2 * @area

      @locations = []

      @matrix = [[]]
    end

    # Generate the map
    def generate
      raise 'cannot generate an empty map' unless width && height

      # prefill map with empty elements
      @boundary_height.times do |y|
        @matrix[y] = []

        @boundary_width.times do |x|
          @matrix[y][x] = ''
        end
      end

      draw_boundary_corners
      draw_boundary_walls
      draw_surface

      draw_interiors

      draw_pois

      draw_npcs

      draw_player if Game.player.x != -1 && Game.player.y != -1
    end

    # Check if this map has been generated yet.
    #
    # @note this checks if the matrix has elements within to detect generation
    # @return [Boolean] true when generated
    def generated?
      @matrix&.first&.any?
    end

    def render
      map = String.new

      @matrix.each do |line|
        map += line.join('')
        map += "\n"
      end

      map
    end

    # Return the map to the north. nil if none
    #
    # @return [Map,nil]
    def north
      return unless @north

      @north_map ||= Map.new(@north)
    end

    # Return the map to the south. nil if none
    #
    # @return [Map,nil]
    def south
      return unless @south

      @south_map ||= Map.new(@south)
    end

    # Return the map to the east. nil if none
    #
    # @return [Map,nil]
    def east
      return unless @east

      @east_map ||= Map.new(@east)
    end

    # Return the map to the west. nil if none
    #
    # @return [Map,nil]
    def west
      return unless @west

      @west_map ||= Map.new(@west)
    end

    # draw the @render
    def draw_map
      puts 'You are currently in ' + name.green

      # build the map
      generate

      # render the map
      puts render
    end

    # exit a location
    def exit_location
      # first we should favor the @render's `exits` attribute.  otherwise, calculate the nearest free space
      current_location = [Game.player.location[:x], Game.player.location[:y]]

      pois.each do |point|
        if [point['x'], point['y']] == current_location
          if point['exits']
            Game.player.location[:x] = point['exits']['x'] || Game.player.location[:x]
            Game.player.location[:y] = point['exits']['y'] || Game.player.location[:y]
          else
            Game.player.location[:y] += 1
          end
        end
      end
    end

    # Get an entity at a specific coordinate
    #
    # @param [Integer] x the X coordinate
    # @param [Integer] y the Y coordinate
    # @return [Poi,Character::Npc,nil] the entity at a specific coordinate
    def at(x:, y:)
      return if pois.empty? && npcs.empty? && interiors.empty?

      poi = pois.select { |point| point.x == x && point.y == y }.first
      npc = npcs.select { |point| point.x == x && point.y == y }.first

      return poi unless poi.nil?
      return npc unless npc.nil?

      interior = interior_at(x: x, y: y)

      return unless interior

      # try to get the poi from inside an interior
      interior.pois.select do |point|
        point.x == (x / 2 - interior.width) &&
          point.y == (y - interior.height)
      end.first
    end

    # Get an interior at an intersection of coords
    #
    # @param [Integer] x the X coordinate
    # @param [Integer] y the Y coordinate
    # @return [Map::Interior,nil] the interior if found. nil if not
    def interior_at(x:, y:)
      interiors.each do |interior|
        intercept = [(interior.x..interior.x + interior.width), (interior.y..interior.y + interior.height)]

        return interior if intercept[0].include?(x) && intercept[1].include?(y)
      end

      nil
    end

    # Get a character from the map's matrix if exists
    #
    # @param [Integer] x the x coordinate
    # @param [Integer] y the y coordinate
    # @return [String,nil] the character rendered at the coordinate
    def char_at(x:, y:)
      generate unless generated?

      @matrix[y][x]
    end

    # Map name
    def to_s
      name
    end

    private

    # Load map data from a YAML file
    #
    # @overload load_attributes_from_map(name)
    #   @param [String] the name of the map file (without yaml suffix)
    # @overload load_attributes_from_map(name, file)
    #   @param [String] the name of the map file (without yaml suffix)
    #   @param [String] the explicit map file to load
    def load_attributes_from_map(name, file = nil)
      map_file = file || File.expand_path(File.join('lib', 'maps', "#{name}.yml"))
      return {} unless File.exist?(map_file)

      map = YAML.load_file(map_file)

      # check formatting of map file
      raise MapError, 'Invalid map format' unless map.is_a? Hash

      map
    end

    # Take map pois and convert in-place to their respective data structure
    def load_pois
      pois.each_with_index do |poi, i|
        pois[i] = if poi[:type]
                    Poi.const_get(poi[:type].underscore.classify).new(poi)
                  else
                    Poi.new(poi)
                  end
      end
    end

    # Take map interiors and convert in-place to their respective data structure
    def load_interiors
      interiors.each_with_index do |interior, i|
        new_interior = Interior.new(interior)

        new_interior.pois.each_with_index do |poi, i|
          new_interior.pois[i] = if poi[:type]
                                   Poi.const_get(poi[:type].classify).new(poi)
                                 else
                                   Poi.new(poi)
                                 end
        end

        interiors[i] = new_interior
      end
    end

    # Load NPCs into the map
    def load_npcs
      npcs.each_with_index do |npc, i|
        npcs[i] = begin
                    Characters.const_get(npc[:name].underscore.classify).new(npc)
                  rescue NameError
                    warn "NPC doesn't exist. #{npc[:name]}"
                    Npc.new(npc)
                  end
      end
    end

    # Draw the corners of the map
    def draw_boundary_corners
      # four boundary corners
      @matrix[0][0] = CORNER_UPPER_LEFT
      @matrix[0][-1] = CORNER_UPPER_RIGHT
      @matrix[-1][0] = CORNER_LOWER_LEFT
      @matrix[-1][-1] = CORNER_LOWER_RIGHT
    end

    # Draw the walls of the map
    def draw_boundary_walls
      # top / bottom walls
      (1..width).each do |x|
        @matrix[0][x] = WALL_HORIZ
        @matrix[-1][x] = WALL_HORIZ
      end

      # left / right walls
      (1..height).each do |y|
        @matrix[y][0] = WALL_VERT
        @matrix[y][-1] = WALL_VERT
      end
    end

    # Draw the surface of the map
    #
    # @see .surface
    def draw_surface
      (1..height).each do |y|
        (1..width).each do |x|
          @matrix[y][x] = surface
        end
      end
    end

    # Draw interiors specified in the map file
    def draw_interiors
      interiors.each do |interior|

        interior_width = interior.width + 2
        interior_height = interior.height + 2

        interior_height.times do |y|
            _y = interior.y + y
          interior_width.times do |x|
            _x = interior.x + x

            if interior.door
              next if x == (interior.door[:x] - 1) && y == (interior.door[:y] - 1)
            end

            case _x
            when interior.x
              if _y == interior.y
                @matrix[_y][_x] = INTERIOR_CORNER_UPPER_LEFT

                next
              elsif _y == (interior.y + interior_height - 1)
                @matrix[_y][_x] = INTERIOR_CORNER_LOWER_LEFT

                next
              else
                @matrix[_y][_x] = INTERIOR_WALL_VERT

                next
              end
            when (interior.x + interior_width - 1)
              if _y == interior.y
                @matrix[_y][_x] = INTERIOR_CORNER_UPPER_RIGHT

                next
              elsif _y == (interior.y + interior_height - 1)
                @matrix[_y][_x] = INTERIOR_CORNER_LOWER_RIGHT

                next
              else
                @matrix[_y][_x] = INTERIOR_WALL_VERT
              end
            else
              # if y == interior.y || y == interior[:height] - 1
              if _y == interior.y || _y == (interior.y + interior_height - 1)
                @matrix[_y][_x] = INTERIOR_WALL_HORIZ

                next
              end

            end
          end
        end
      end
    end

    # Draw POIs on the map
    def draw_pois
      # draw map pois
      pois.each do |poi|
        @matrix[poi.y][poi.x] = poi.rune
      end

      interiors.each do |interior|
        interior.pois.each do |poi|
          @matrix[interior.y + poi.y][interior.x + poi.x] = poi.rune
        end
      end
    end

    # Draw non-playable characters on the map
    def draw_npcs
      npcs.each do |npc|
        @matrix[npc.y][npc.x] = NPC
      end
    end

    # Draw the player on the map
    def draw_player
      @matrix[Game.player.y][Game.player.x] = PLAYER
    end

    def remove_entity(*args)
      if args[0].is_a? Hash
        poi.each do |poi|
          if poi['x'] == args[0][:x] && poi['y'] == args[0][:y]
            poi.delete(poi)
          end
        end
      end
    end

    # The surface of the map that the player walks on
    #
    # @return [String]
    # @example
    #   Map.new('town').surface #=> '.'
    #   Map.new('field').surface #=> ','
    def surface
      case type
      when 'town'
        SURFACE_STONE
      when 'grass'
        SURFACE_GRASS
      else
        SURFACE_DEFAULT
      end
    end
  end
end
