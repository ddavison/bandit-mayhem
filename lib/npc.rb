# frozen_string_literal: true

module BanditMayhem
  # Non-playable Character
  class Npc < Character
    attribute :dialog

    def interact_with(what)
      return unless what.is_a? Player

      puts name.cyan
      puts avatar
    end
  end
end
