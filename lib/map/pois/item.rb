# frozen_string_literal: true

module BanditMayhem
  module Map::Pois
    # Map Item
    class Item < Map::Poi
      include Consumable

      RUNE = 'ꕺ'

      attribute :description

      # Add item to inventory
      def interact_with(what)
        item = Items.const_get(name.underscore.classify).new(current_attributes)

        context "#{what.name.bold} has found a #{item.name.bold}", await: false do
          what.items << item
        end
      end

      def rune
        RUNE.blue
      end
    end
  end
end
