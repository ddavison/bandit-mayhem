# frozen_string_literal: true

module BanditMayhem
  # Non-playable Character
  class Npc < Character
    # Dialogs [Hash]
    attribute :dialogs

    # Player <-> NPC interaction
    # Engage in conversation with the NPC
    def interact_with(player)
      return unless player.is_a? Player

      puts name.cyan
      puts avatar

      dialogs.each do |request, reply|
        npc_line = request
        player_line = reply

        say(npc_line)

        if player_line.respond_to?(:each)
          # multiple options for response

          player_line.each_with_index do |line, i|
            puts "#{(i + 1).to_s.light_magenta}) #{line.first}"
          end
        end

        player.await_interaction do |response|
          if player_line.is_a?(String)
            player.say(player_line)
          else
            player.say(player_line.keys[response.to_i - 1])

            say(player_line[player_line.keys[response.to_i - 1]])
          end
        end
      end
    end
  end
end
