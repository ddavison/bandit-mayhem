# frozen_string_literal: true

module BanditMayhem
  # Item
  class Item
    include Attributable

    attribute :name
    attribute :price

    def initialize(attrs)
      merge_attributes attrs
    end
  end
end
