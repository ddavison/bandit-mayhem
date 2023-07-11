# frozen_string_literal: true

module BanditMayhem
  module Map::Pois
    # Map Shop
    class Shop < Map::Poi
      RUNE = '$'

      attribute :inventory, []

      def rune
        RUNE.yellow
      end

      def interact_with(what); end
    end
  end
end
