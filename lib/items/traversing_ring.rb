# frozen_string_literal: true

require_relative '../item'

module BanditMayhem
  module Items
    class TraversingRing < Item
      def initialize
        super({
          name: 'Traversing Ring',
          description: 'Allows you to traverse through walls.',
          sell_value: 20_000
        })
      end
    end
  end
end
