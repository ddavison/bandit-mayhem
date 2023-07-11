# frozen_string_literal: true

module BanditMayhem
  module Map::Pois
    # Map Tree
    class Tree < Map::Poi
      RUNE = '∆'
      # Trees can contain items hidden within them

      attribute :items, []

      # Player collides with tree
      #
      # @param [Player] player
      def interact_with(player)
        return unless player.is_a? Player

        return unless items.any?

        context 'You found some items!' do
          items.each { player.items << _1 }
        end
      end

      def rune
        RUNE.light_green
      end
    end
  end
end
