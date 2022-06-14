# frozen_string_literal: true

require 'media/audite'

module BanditMayhem
  class MediaPlayer
    def initialize
    end

    def stop
    end

    def play_song(audio_file)
    end

    def play_level_song(map_name)
      begin
        play_song("./lib/media/maps/#{map_name}.mp3")
      rescue
        play_song("./lib/media/soundtrack.mp3")
      end
    end

    def playing_level?(map_name)
    end

    def playing?
    end
  end
end
