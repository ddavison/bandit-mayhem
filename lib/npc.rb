# frozen_string_literal: true

module BanditMayhem
  # Non-playable Character
  class Npc < Character
    attribute :dialog

    def interact_with(player)
      return unless player.is_a? Player

      puts name.cyan
      puts avatar

      dialog.each do |line, req|
        req.each do |request, reply|
          say(line)

          request.keys.each do |l|
            player.await_interaction(prompt(l)) do |response|
              player.say(l)

              say(request[l][response.to_i - 1])
            end
          end

          puts reply
        end
      end
    end

    private

    def prompt(line)
      puts "#{'1'.light_magenta}) #{line}"

      print 'Enter your response: '
    end
  end
end
