# frozen_string_literal: true

require './lib/map'
require './lib/characters/player'

player = BanditMayhem::Characters::Player.new({})
player.location = {
    map: nil,
    x: -1,
    y: -1
}

map_to_render = ARGV[0]

map = BanditMayhem::Map.new(map_to_render)

map_data = map.build!(player)

File.open('map', map_data)
