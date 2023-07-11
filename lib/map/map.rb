# frozen_string_literal: true

require 'yaml'
require 'colorize'
require 'symbolized'

module BanditMayhem
  module Map
    # Bandit Mayhem Map
    class Map
      include Attributable

      MapError = Class.new(RuntimeError)

      attr_reader :errors

      attribute :name
      attribute :width
      attribute :height

      # The containing map file
      attribute :file

      # Points of Interests
      attribute :pois, []

      # NPCs
      attribute :npcs, []

      attribute :type
      attribute :interiors, []

      # Drawn paths
      attribute :paths, []

      attribute :north
      attribute :south
      attribute :east
      attribute :west

      attr_accessor :matrix

      WALL_VERT          = '│'
      WALL_HORIZ         = '─'
      WALL_VERT_BORDER   = '┇'
      WALL_HORIZ_BORDER  = '┅'
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

      PATH               = '▓'.light_black

      CAVE               = 'O'.magenta
      SURFACE_DEFAULT    = ' '
      SURFACE_STONE      = '.'.light_black
      SURFACE_GRASS      = ','.green
      SURFACE_MARBLE     = '␣'.white
      PLAYER             = '@'.cyan
      BANDIT             = '■'.red
      OTHER              = '?'

      SUN                = '꥟'.yellow

      BEACON             = 'Å'

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
        return name if name.is_a?(Map)

        file = attrs.delete(:file)
        skip_load = attrs.delete(:skip_load)

        self.file = name

        merge_attributes load_attributes_from_map(name, file)
        merge_attributes load_attributes_from_save(name) unless skip_load
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
        draw_paths

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

      # Get the map to the north
      #
      # @return [Map,nil]
      def north_map
        Map.new(north) if north
      end

      # Get the map to the south
      #
      # @return [Map,nil]
      def south_map
        Map.new(south) if south
      end

      # Get the map to the west
      #
      # @return [Map,nil]
      def west_map
        Map.new(west) if west
      end

      # Get the map to the east
      #
      # @return [Map,nil]
      def east_map
        Map.new(east) if east
      end

      # draw the @render
      def draw_map
        puts 'You are currently in ' + name.green

        # build the map
        generate

        # render the map
        puts render
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

        # get the poi from inside an interior
        interior.pois.select do |point|
          point.x == x - interior.width - (interior.x - interior.width) &&
            point.y == y - interior.height - (interior.y - interior.height)
        end.first
      end

      # Get an interior at an intersection of coords
      #
      # @param [Integer] x the X coordinate
      # @param [Integer] y the Y coordinate
      # @return [Map::Interior,nil] the interior if found. nil if not
      def interior_at(x:, y:)
        interiors.each do |interior|
          intercept = [(interior.x..interior.x + interior.width + 1), (interior.y..interior.y + interior.height + 1)]

          return interior if intercept[0].include?(x) && intercept[1].include?(y)
        end

        nil
      end

      # Get an interior by name
      #
      # @param [String] name the name of the interior to find
      # @return [Map::Interior, nil] the interior if found, nil if not
      def interior_by_name(name)
        interiors.select { |interior| interior.name == name }.first
      end

      # Remove an entity at a specific coordinate
      #
      # @param [Integer] x the X coordinate
      # @param [Integer] y the Y coordinate
      # @return [Boolean] true if at least one entity was removed
      def remove_at(x:, y:)
        return false unless at(x:, y:)

        entities = pois.select { _1.x == x && _1.y == y }.each do |poi|
          pois.delete(poi)

          @matrix[y][x] = surface
        end

        entities.any?
      end

      # Remove a POI
      #
      # @param [Poi] poi the Point of interest to remove from the map
      # @return [Boolean] true if this poi was removed
      def remove(poi)
        return false unless pois.include?(poi)

        remove_at(x: poi.x, y: poi.y)
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

      # Is this map valid?
      #
      # @return [Boolean] true if the map is invalid
      # @note Sets @errors if any exist
      def valid?
        @errors = [] # clear errors


      end

      def ==(other)
        return false unless other.is_a? Map

        other.name == name && other.file == file
      end

      private

      # Load map data from a YAML file
      #
      # @overload load_attributes_from_map(name)
      #   @param [String] name the name of the map file (without yaml suffix)
      # @overload load_attributes_from_map(name, file)
      #   @param [String] name the name of the map file (without yaml suffix)
      #   @param [String] file the explicit map file to load
      def load_attributes_from_map(name, file = nil)
        map_file = file || File.expand_path(File.join('lib', 'maps', "#{name}.yml"))
        return {} unless File.exist?(map_file)

        map = YAML.load_file(map_file)

        # check formatting of map file
        raise MapError, 'Invalid map format' unless map.is_a? Hash

        map
      end

      # The save files contain a maps key which contains the name
      #
      # @param [String] name
      def load_attributes_from_save(name)
        save_game = Game.load_save

        map = save_game[:maps][name] if save_game[:maps]

        return {} unless map

        map.current_attributes
      end

      # Take map pois and convert in-place to their respective data structure
      def load_pois
        pois.each_with_index do |poi, i|
          pois[i] = if poi[:type]
                      BanditMayhem::Map::Pois.const_get(poi[:type].underscore.classify).new(poi)
                    else
                      BanditMayhem::Map::Pois.new(poi)
                    end
        end
      end

      # Take map interiors and convert in-place to their respective data structure
      def load_interiors
        interiors.each_with_index do |interior, i|
          new_interior = Interior.new(interior)

          new_interior.pois.each_with_index do |poi, i|
            new_interior.pois[i] = if poi[:type]
                                     BanditMayhem::Map::Pois.const_get(poi[:type].classify).new(poi)
                                   else
                                     BanditMayhem::Map::Pois.new(poi)
                                   end
          end

          interiors[i] = new_interior
        end
      end

      # Load NPCs into the map
      def load_npcs
        npcs.each_with_index do |npc, i|
          next npcs[i] = npc if npc.is_a?(Npc)

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
        # north / south walls
        (1..width).each do |x|
          @matrix[0][x]  = if north
                             WALL_HORIZ_BORDER
                           else
                             WALL_HORIZ
                           end

          @matrix[-1][x] = if south
                             WALL_HORIZ_BORDER
                           else
                             WALL_HORIZ
                           end
        end

        # west / east walls
        (1..height).each do |y|
          @matrix[y][0] = if west
                            WALL_VERT_BORDER
                          else
                            WALL_VERT
                          end

          @matrix[y][-1] = if east
                             WALL_VERT_BORDER
                           else
                             WALL_VERT
                           end
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

      # Draw paths on the map
      def draw_paths
        paths.each do |path|
          (path[:from][:y]..path[:to][:y]).each do |y|
            (path[:from][:x]..path[:to][:x]).each do |x|
              @matrix[y][x] = PATH
            end
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
          @matrix[npc.y][npc.x] = Npc.new(npc).rune
        end
      end

      # Draw the player on the map
      def draw_player
        @matrix[Game.player.y][Game.player.x] = PLAYER
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
        when 'interior'
          SURFACE_MARBLE
        else
          SURFACE_DEFAULT
        end
      end
    end
  end
end
