# frozen_string_literal: true

require 'colorize'
require 'yaml'

module BanditMayhem
  class Commands
    @descriptions = []

    # list the help menu.
    def help(args)
      @descriptions.each do |cmd, description|
        puts "\t#{cmd}".magenta + ': ' + "#{description}".light_magenta
      end
    end

    # this subroutine will decide what to do with cmd
    def execute(cmd)
      if cmd.include? '/'
        cmd.downcase!

        full_cmd = cmd.gsub(/\//, '')
        command_name = full_cmd.split(' ').first # the actual command name.
        params = full_cmd.split(' ') # the parameters passed to the command.
        params.shift

        begin
          send("#{command_name}", params)
        rescue NoMethodError => e
          puts "unknown command [#{command_name}]".red
          $stderr.puts e
        rescue TypeError, Exception
          puts "you have an issue in your code for [#{command_name}]".red
        end
      else
        puts 'type /help for help'.green
      end
    end
  end
end
