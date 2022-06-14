# frozen_string_literal: true

require_relative '../item'

module BanditMayhem
  module Items
    class LuckPotion < Item
      def initialize
        props = {
            moniker: 'luck_potion',
            name: 'Luck Potion',
            description: 'Ups your luck',
            sell_value: 30,
            buy_value: 60
        }
        super(props)
      end

      def use(actor)
        return if actor.get_av('luck') >= 100

        actor.set_av('luck',
          actor.get_av('luck') + 15
        )
      end
    end
  end
end
