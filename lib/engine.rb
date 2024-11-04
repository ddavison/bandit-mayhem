# frozen_string_literal: true

require 'tty-prompt'
require 'tty-reader'
require 'tty-markdown'
require 'tty-box'
require 'tty-table'

module BanditMayhem
  class Engine
    attr_reader :reader,
                :prompt,
                :markdown,
                :box,
                :table
    def initialize(out = $stdout)
      @reader = TTY::Reader.new
      @prompt = TTY::Prompt.new
      @box = TTY::Box
      @markdown = TTY::Markdown
      @table = TTY::Table
      @out = out
    end

    def draw(text)
      @out.print(text + "\r")
      @out.flush
    end
  end
end
