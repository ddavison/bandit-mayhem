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

    def interact_with(what)
      super

      what.items << self if what.respond_to?(:items)
    end
  end
end
