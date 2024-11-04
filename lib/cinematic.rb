# frozen_string_literal: true

module BanditMayhem
  class Cinematic
    attr_reader :name

    PATH = File.absolute_path(File.join(Dir.pwd, 'lib', 'cinematics'))

    # New cinematic object
    # @param [String] name the name of the cinematic
    def initialize(name)
      @path = File.join(PATH, name)
      @name = name
      @page = 0
      @number_of_pages = Dir["#{@path}/*.md"].size
      @played = false
    end

    # Load a specific page from lib/cinematics/*/*.md
    def load_page
      Game.engine.markdown.parse_file(File.join(@path, "#{@page}.md"))
    end

    def play
      return if played? # player has already seen cinematic

      while @page < @number_of_pages
        Game.engine.draw(
          Game.engine.box.frame(load_page, align: :center, title: { top_left: "#{@name.upcase} #{@page}" })
        )
        Game.player.await_interaction
        next_page
      end

      @played = true
    end

    def played?
      @played
    end

    def next_page
      @page += 1
    end

    def previous_page
      @page -= 1
    end
  end
end
