# frozen_string_literal: true

module BanditMayhem
  # Non-playable Character
  class Npc < Character
    RUNE = '¶'

    def interact_with(what)
      if what.is_a? Player
        Game.engine.draw(avatar) if defined?(avatar)
      end
    end

    def rune
      RUNE.cyan
    end
  end
end
