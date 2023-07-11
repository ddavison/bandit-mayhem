# frozen_string_literal: true

module BanditMayhem
  module Map::Pois
    # Bed
    #
    # @note interacting with the bed will fill the characters health to max
    class Bed < Map::Poi
      RUNE = 'π'

      def interact_with(character)
        context "#{character.name.cyan}'s health has been filled", await: false do
          character.health = character.max_health
        end
      end

      def rune
        RUNE.light_blue
      end
    end
  end
end
