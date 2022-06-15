# frozen_string_literal: true

module BanditMayhem
  module Characters
    # Gabbi Strick
    class GabbiStrick < Npc
      attribute :avatar, <<~AVATAR
                        ___
                       ////
                     @@@@/
          . - .     @,, @@@
        . \ |./ .  @(<  ?@@@
        .__\|/__. @@ ~  /@@@
           |//   __@_:::_@@@
           -\ ) (((  ~  ((())
            : \/=(((((((((\=\
            |_*\/ ###X#### \=\
             \./  ###x###   \_\_
                  ######    | */
                 #((()))#   :_/
                #(((())))#  | \
               (##((())))## '\)
               (##((()))###)
               ((##(()))###)
                ((##(()##))))
                ((((####))))))
                (((((###))))))
                ((((((###))))))
                 (((((####)))))
                 #*#*#*#*#*#*#*
                   /.)     (.\
                 _//(       )\\_
      AVATAR

      def interact_with(player)
        super

        if player.items.has_a?(Items::Baton) && player.gold >= 10
          # player has all the items necessary. Continue

          say 'Good luck out there! (ideally some dialog here, to fill in lore.)'
        else
          say 'You shouldnt leave here without your items!'
          player.y += 1 # move player back away from Gabbi
        end
      end
    end
  end
end
