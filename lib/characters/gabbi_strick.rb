# frozen_string_literal: true

module BanditMayhem
  module Characters
    # Gabbi Strick (brief lore here)
    class GabbiStrick < Npc
      attribute :avatar, <<~AVATAR
                        ___
                       ////
                     @@@@/
          . - .     @,, @@@
        . \\ |./ .  @(<  ?@@@
        .__\\|/__. @@ ~  /@@@
           |//   __@_:::_@@@
           -\\ ) (((  ~  ((())
            : \\/=(((((((((\\=\\
            |_*\\/ ###X#### \\=\\
             \\./  ###x###   \\_\\_
                  ######    | */
                 #((()))#   :_/
                #(((())))#  | \\
               (##((())))## '\\)
               (##((()))###)
               ((##(()))###)
                ((##(()##))))
                ((((####))))))
                (((((###))))))
                ((((((###))))))
                 (((((####)))))
                 #*#*#*#*#*#*#*
                   /.)     (.\\
                 _//(       )\\\\_
      AVATAR

      def interact_with(player)
        super # start dialog

        if player.items.has_a?(Items::Baton) && player.gold >= 10
          # player has all the items necessary. Continue

          if player.health != player.max_health
            say "You should rest in the bed (#{Map::Pois::Bed::RUNE}) before you go, you're still weak."

            player.back
          else
            say 'Good luck out there!'

            self.x = 5 # Gabbi moves from the doorway
          end
        else
          say 'You shouldnt leave here without your items!'
          player.back # move player back away from Gabbi
        end
      end
    end
  end
end
