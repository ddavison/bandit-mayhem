# frozen_string_literal: true

require 'weapon'

module BanditMayhem
  module Weapons
    class Stick < Weapon
      def initialize(add_props)
        props = {
          str: 25,
          name: 'Stick',
          moniker: 'stick',
          description: 'A simple wooden stick used to beat heads in'
        }.merge(add_props)

        super(props)
      end
    end
  end
end
