# frozen_string_literal: true

module BanditMayhem
  module Items
    module Lynwood
      class ArmoryKey < Item
        include Consumable

        attribute :description, 'The key to the Lynwood Armory'

        def interact_with(character)
          character.items << self
        end
      end
    end
  end
end
