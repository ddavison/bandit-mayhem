# frozen_string_literal: true

module BanditMayhem
  module Map::Pois
    class Wall < Map::Poi
      # vert / horiz wall
      attribute :direction

      def rune
        return Map::Map::WALL_VERT if vertical?

        Map::Map::WALL_HORIZ if horizontal?
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
  end
end
