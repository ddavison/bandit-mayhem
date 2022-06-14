# frozen_string_literal: true

require './lib/weapon'

module BanditMayhem
  module Weapons
    class Sword < Weapon
      def initialize
        props = {
          str: 35,
          name: 'Sword',
          moniker: 'sword',
          description: 'A sword, fit for a... "knight"'
        }

        super(props)
      end
    end
  end
end
