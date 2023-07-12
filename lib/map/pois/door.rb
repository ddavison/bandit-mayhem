# frozen_string_literal: true

module BanditMayhem
  module Map::Pois
    class Door < Map::Poi
      RUNE = '¤'

      attribute :destination
      attribute :locked, false
      attribute :key

      # Is this door unlocked?
      #
      # @return [Boolean] true if unlocked
      def unlocked?
        !locked?
      end

      # Is this door locked?
      #
      # @return [Boolean] true if locked
      def locked?
        locked
      end

      def lock
        self.locked = true
      end

      def unlock
        self.locked = false
      end

      def rune
        # require 'pry-byebug'
        # binding.pry
        return RUNE.green if unlocked?
        return RUNE.yellow if Game.player.items.has_a?(key)

        RUNE.light_red
      end

      # Traverse through the door
      # @param [Character] character
      def interact_with(character)
        character.warp(**destination) if unlocked? || character.items.has_a?(key)
      end
    end
  end
end
