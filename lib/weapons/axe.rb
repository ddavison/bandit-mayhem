# frozen_string_literal: true

require './lib/weapon'

module BanditMayhem
  module Weapons
    class Axe < Weapon
      def initialize
        props = {
            str: 45,
            name: 'Axe',
            moniker: 'axe',
            description: 'A sturdy axe'
        }

        super(props)
      end
    end
  end
end
