# frozen_string_literal: true

module BanditMayhem
  # Interactable
  module Interactable
    def interact_with(what)
      what.interact_with(self) if what.respond_to?(:interact_with)
    end
  end
end
