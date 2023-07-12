# frozen_string_literal: true

module BanditMayhem
  # Item
  class Item
    include Attributable
    include Interactable

    attribute :name
    attribute :description
    attribute :value

    def initialize(attrs)
      merge_attributes attrs
    end

    # Interaction with item
    #
    # @param [Character] character
    def interact_with(character)
      super

      context "#{character.name} has found a #{name}" do
        character.items << self
      end
      Game.player.await_interaction
    end

    def to_s
      name
    end
  end
end
