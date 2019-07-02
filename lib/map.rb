require 'yaml'
require 'colorize'
require 'symbolized'

module BanditMayhem
  module Maps
    WALL_VERT          = '│'
    WALL_HORIZ         = '─'
    DOOR               = '¤'.light_black
    CAVE               = 'O'.light_black
    CORNER_UPPER_RIGHT = '┐'
    CORNER_UPPER_LEFT  = '┌'
    CORNER_LOWER_LEFT  = '└'
    CORNER_LOWER_RIGHT = '┘'
    SURFACE_STONE      = '.'
    SURFACE_GRASS      = ','
    MARKET             = '$'.yellow
    PLAYER             = '@'.cyan
    COINPURSE          = '¢'.yellow
    ITEM               = '!'.blue
    BANDIT             = '■'.red
    OTHER              = '?'
    TREE               = '∆'.green
  end

  class Map

    def to_s
      @attributes['name']
    end

    attr_reader :attributes,
                :width,
                :height,
                :north,
                :east,
                :south,
                :west,
                :poi

    def initialize(args)
      @attributes = {}.to_symbolized_hash

      raise 'map name is required' unless args[:name]

      begin
        @attributes.merge!(YAML.load_file(args[:file])) if args[:file]
        @attributes.merge!(args[:attributes]) if args[:attributes]

        default_map_to_load = File.absolute_path(File.join('lib', 'maps', "#{args[:name]}.yml"))
        @attributes.merge!(YAML.load_file(default_map_to_load)) unless !!(args[:attributes] || args[:file])
      rescue
        puts "mapfile [#{args[:name]}.yml] is invalid"
      end

      @width  = @attributes['width']
      @height = @attributes['height']

      @boundary_width = @width.to_i * 2
      @boundary_height = @height.to_i * 2

      @north = @attributes['north']
      @south = @attributes['south']
      @east  = @attributes['east']
      @west  = @attributes['west']

      @area = width * height
      @perimeter = 2 * @area

      @locations = []

      @poi = @attributes['poi']
    end

    def build!(player)
      # the map string
      map = String.new
      map_surface = get_surface

      @boundary_height.times do |y|  # columns
        @boundary_width.times do |x| # rows
          non_surface = false
          case x
            when 0
              if y == 0
                map += Maps::CORNER_UPPER_LEFT
                next
              elsif y == @boundary_height
                map += Maps::CORNER_LOWER_LEFT
                next
              else
                map += Maps::WALL_VERT
                next
              end
            when @boundary_width - 1
              if y == 0
                map += Maps::CORNER_UPPER_RIGHT
                next
              elsif y == @boundary_height
                map += Maps::CORNER_LOWER_RIGHT
                next
              else
                map += Maps::WALL_VERT
                next
              end
            else
              if y == 0 || y == @boundary_width
                map += Maps::WALL_HORIZ
                next
              end

              # if x == player.location[:x] && y == player.location[:y]
              #   map += Maps::PLAYER
              #   non_surface = true
              #   next
              # end

              # if @poi.any?
              #   @poi.each do |poi|
              #     @locations << [poi['x'], poi['y']] unless @locations.include? [poi['x'], poi['y']]
              #     if player.location[:x] == poi['x'] && player.location[:y] == poi['y']
              #       if poi['type'] == 'item' || poi['type'] == 'weapon' || poi['type'] == 'coinpurse'
              #         @poi.delete(poi)
              #       end
              #       if poi['consumable']
              #         if poi['consumable'].is_a? Hash
              #           # there is a condition.
              #           @poi.delete(poi) if player.get_av(poi['consumable']['unless'], false)
              #         else
              #           @poi.delete(poi) if @poi.include? poi
              #         end
              #       end
              #
              #       return player.interact_with poi
              #     end
              #     if x == poi['x'] && y == poi['y']
              #       case poi['type']
              #         when 'market'
              #           map += Maps::MARKET
              #           non_surface = true
              #         when 'coinpurse'
              #           map += Maps::COINPURSE
              #           non_surface = true
              #         when 'item', 'weapon'
              #           map += Maps::ITEM
              #           non_surface = true
              #         when 'bandit'
              #           map += Maps::BANDIT
              #           non_surface = true
              #         when 'tree'
              #           map += Maps::TREE
              #           non_surface = true
              #         when 'cave'
              #           map += Maps::CAVE
              #           non_surface = true
              #         when 'door'
              #           map += Maps::DOOR
              #           non_surface = true
              #         when 'wall'
              #           non_surface = true
              #           case poi['direction']
              #             when 'vertical', 'vert'
              #               map += Maps::WALL_VERT
              #             when 'horizontal', 'horiz'
              #               map += Maps::WALL_HORIZ
              #           end
              #         else
              #           map += Maps::OTHER
              #           non_surface = true
              #       end
              #       next
              #     end
              #   end
              # end
              map += map_surface unless non_surface
          end
          non_surface = false
        end
        map += "\n"
      end

      map
    end
    # render the map
    # @param player - because we need the players position.
    def render_map(player)
      player.location[:x] = @width - 2 if player.location[:x] > @width - 2
      player.location[:y] = @height- 2 if player.location[:y] > @height- 2

      puts 'You are currently in ' + @attributes['name'].to_s.green

      puts build!(player)
    end

    # exit a location
    def exit_location(player)
      # first we should favor the map's `exits` attribute.  otherwise, calculate the nearest free space
      current_location = [player.location[:x], player.location[:y]]

      @poi.each do |poi|
        if [poi['x'], poi['y']] == current_location
          if poi['exits']
            player.location[:x] = poi['exits']['x'] || player.location[:x]
            player.location[:y] = poi['exits']['y'] || player.location[:y]
          else
            player.location[:y] += 1
          end
        end
      end
    end

    def get_entity_at(*args)
      ret = nil
      if args[0].is_a? Hash
        @poi.each do |poi|
          ret = poi if poi['x'] == args[0][:x] && poi['y'] == args[0][:y]
        end
      end
      ret
    end

    def remove_entity(*args)
      if args[0].is_a? Hash
        @poi.each do |poi|
          if poi['x'] == args[0][:x] && poi['y'] == args[0][:y]
            @poi.delete(poi)
          end
        end
      end
    end

    def get_surface
      case @attributes['type']
        when 'town'
          Maps::SURFACE_STONE
        when 'plains'
          Maps::SURFACE_GRASS
        else
          Maps::SURFACE_GRASS
      end
    end
  end
end
