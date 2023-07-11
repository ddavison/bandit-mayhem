# frozen_string_literal: true

module BanditMayhem
  module Map::Pois
    class Coinpurse < Map::Poi
      include Consumable

      RUNE = '¢'

      attribute :value

      def rune
        RUNE.yellow
      end

      # Add gold to the character's wallet
      def interact_with(what)
        context "#{what.name} has found a coinpurse ($#{value.to_s.yellow})" do
          what.gold += value if what.respond_to?(:gold)
        end
      end
    end
  end
end
