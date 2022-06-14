# frozen_string_literal: true

module BanditMayhem
  module Utils
    extend self

    def shuffle_percent(percent)
      rand(100) <= percent
    end

    def cls
      if RUBY_PLATFORM =~ /win32|win64|\.NET|windows|cygwin|mingw32/i
        system('cls')
      else
        system('clear')
      end
    end

    def in_game?
      !ARGV[0]&.to_s.end_with?('spec')
    end

    class Printer

      def info(msg)

      end

      def warn(msg)

      end

      def err(msg)
      end

      def line(line)
        print("\n#{line}")
      end

      private
      def print(line)
        puts line
      end
    end
  end
end
