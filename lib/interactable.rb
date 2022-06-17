# frozen_string_literal: true

module BanditMayhem
  # Interactable
  module Interactable
    def interact_with(what)
      what.interact_with(self) if what.respond_to?(:interact_with)
    end

    # Perform some actions under some context
    #
    # @param [String] context
    def context(context, await: true)
      puts context.light_black.italic

      Game.player.await_interaction if await

      yield if block_given?
    end
  end
end
