# frozen_string_literal: true

module BanditMayhem
  module Characters
    # Tristo Ultrath (brief lore here)
    class TristoUltrath < Npc
      attribute :avatar, <<~AVATAR
               .#####.
               |_____|
              (\\#/ \\#/)
               |  U  |
               \\  _  /
                \\___/
            .---'   `---.
           /  #########  \\
          /  |####|####|  \\
         /  /\\ ####### /\\  \\
        (  \\  \\  ###  /  /  )
         \\  \\  \\_###_/  /  /
          \\  \\ |\\   /| /  /
           'uuu| \\_/ |uuu'
               |  |  |
               |  |  |
               |  |  |
               |  |  |
               |  |  |
               )  |  (
             .oooO Oooo.
      AVATAR

      def interact_with(player)
        super # start dialog

        context "#{name.cyan} shoves you out of the door" do
          player.down # send player back through the door
        end
      end
    end
  end
end
