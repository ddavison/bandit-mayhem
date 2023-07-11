# frozen_string_literal: true

module BanditMayhem
  module Map::Pois
    class Door < Map::Poi
      RUNE = '¤'

      attribute :destination
      attribute :locked, false

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
        unlocked? ? RUNE.magenta : RUNE.light_red
      end

      # Traverse through the door
      # @param [Character] character
      def interact_with(character)
        character.warp(**destination) if unlocked?
      end
    end
  end
end
