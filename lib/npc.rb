# frozen_string_literal: true

module BanditMayhem
  # Non-playable Character
  class Npc < Character
    def interact_with(what)
      if what.is_a? Player
        puts avatar if defined?(avatar)
      end
    end
  end
end
