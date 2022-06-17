# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.expand_path(File.dirname(__FILE__)), 'lib'))

require 'yaml'
require 'bandit_mayhem'

namespace :maps do
  desc 'Validate existing maps in maps/ dir'
  task :validate do
    errors = []

    Dir['lib/maps/**.yml'].each do |map|
      map_yaml = YAML.load_file(map)
      map_name = File.basename(map)

      errors << "#{map_name} must have a 'name'" unless map_yaml['name']
      errors << "#{map_name} must have a 'width'" unless map_yaml['width']
      errors << "#{map_name} must have a 'height'" unless map_yaml['height']
    rescue => e
      raise e, "Error loading map #{map}. Bad YAML?"
    end

    warn errors.join("\n") if errors.any?
  end

  desc 'Generate a map'
  task :generate, [:name, :x, :y] do |_, args|
    map = BanditMayhem::Map.new(args[:name], width: args[:x].to_i, height: args[:y].to_i)
    map.generate
    puts map.render
  end

  desc 'Render an existing map'
  task :render, [:name] do |_, args|
    map_file = File.expand_path(File.join('.', 'lib', 'maps', "#{args[:name]}.yml"))

    raise ArgumentError, "Map `#{args[:name]}` does not exist" unless File.exist?(map_file)

    map = BanditMayhem::Map.new(args[:name], skip_load: true) # don't load from save file
    map.generate

    puts map.render
  end
end
