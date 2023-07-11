# frozen_string_literal: true

require 'spec_helper'

module BanditMayhem
  RSpec.describe Character do
    subject(:character) do
      described_class.new(name: 'Some Dude')
    end

    let(:map) do
      Map::Map.new('qasmoke', file: File.absolute_path(File.join('spec', 'fixtures', 'maps', 'qasmoke.yml')))
    end

    before do
      character.map = map

      map.generate
      puts map.render
    end

    describe 'attributes' do
      it 'has all defaulted attributes', :aggregate_failures do
        expect(character.name).to eq('Some Dude')
        expect(character.health).to eq(100)
        expect(character.max_health).to eq(100)
        expect(character.str).to eq(10)
        expect(character.def).to eq(0)
        expect(character.gold).to eq(0)

        expect(character.map).to eq(map)
        expect(character.x).to eq(-1)
        expect(character.y).to eq(-1)
      end

      context 'when changing attributes' do
        before do
          character.name = 'Butch'
          character.gold = 10
          character.health = 50
        end

        it 'retains base attributes', :aggregate_failures do
          expect(character.name).to eq('Butch')
          expect(character.attributes[:name]).to eq('Somebody')

          expect(character.gold).to eq(10)
          expect(character.attributes[:gold]).to eq(0)

          expect(character.health).to eq(50)
          expect(character.attributes[:health]).to eq(100)
        end
      end

      it 'starts with an empty inventory' do
        expect(character.items).to be_empty
      end
    end

    describe '#dead?' do
      it 'actor is dead when health is less-than or equal-to 0', :aggregate_failures do
        expect(character).not_to be_dead
        character.health = 0
        expect(character).to be_dead

        character.health = 3
        expect(character).not_to be_dead

        character.health = -47
        expect(character).to be_dead
      end

      it 'actor is not dead when health is greater-than 0', :aggregate_failures do
        character.health = 1
        expect(character).not_to be_dead

        character.health = character.max_health
        expect(character).not_to be_dead
      end
    end

    describe 'movement' do
      let(:map) do
        Map::Map.new('empty map', width: 3, height: 3)
      end

      before do
        character.x = character.y = 2 # set character to (2, 2)
      end

      context 'when walls are in the way' do
        let(:map) do
          Map::Map.new('map with walls', width: 3, height: 3, pois: [
                    { type: 'wall', direction: 'horiz', x: 2, y: 1 }, # north
                    { type: 'wall', direction: 'horiz', x: 2, y: 3 }, # south
                    { type: 'wall', direction: 'vert', x: 1, y: 2 }, # west
                    { type: 'wall', direction: 'vert', x: 3, y: 2 } # east
                  ])
        end

        it 'cannot move up, down, left or right', :aggregate_failures do
          character.up # attempt to go up

          expect(character.y).to eq(2) # y doesn't change

          character.down # attempt to go down

          expect(character.y).to eq(2) # y doesn't change

          character.left # attempt to go left

          expect(character.x).to eq(2) # x doesn't change

          character.right # attempt to go right

          expect(character.x).to eq(2) # x doesn't change
        end
      end

      describe '#up' do
        before do
          character.up
        end

        it 'moves north' do
          expect(character.y).to eq(1)
        end
      end

      describe '#down' do
        before do
          character.down
        end

        it 'moves south' do
          expect(character.y).to eq(3)
        end
      end

      describe '#left' do
        before do
          character.left
        end

        it 'moves west' do
          expect(character.x).to eq(1)
        end
      end

      describe '#right' do
        before do
          character.right
        end

        it 'moves east' do
          expect(character.x).to eq(3)
        end
      end

      describe 'when map has borders' do
        let(:map) do
          Map::Map.new('with borders', file: File.absolute_path(File.join('spec', 'fixtures', 'maps', 'with_borders.yml')))
        end

        before do
          character.x = character.y = 1
        end

        it 'moves north' do
          character.up
          expect(character.map).to eq(map.north_map)
        end

        it 'moves south' do
          character.down
          expect(character.map).to eq(map.south_map)
        end

        it 'moves west' do
          character.left
          expect(character.map).to eq(map.west_map)
        end

        it 'moves east' do
          character.right
          expect(character.map).to eq(map.east_map)
        end
      end

      describe 'when at map boundary' do
        let(:map) do
          Map::Map.new('jail map', width: 1, height: 1)
        end

        before do
          character.x = character.y = 1
        end

        it 'cannot move in any direction', :aggregate_failures do
          # up
          character.up

          expect(character.map).to eq(map)
          expect(character.y).to eq(1)

          # down
          character.down

          expect(character.map).to eq(map)
          expect(character.y).to eq(1)

          # east
          character.right

          expect(character.map).to eq(map)
          expect(character.x).to eq(1)

          # west
          character.left

          expect(character.map).to eq(map)
          expect(character.x).to eq(1)
        end
      end

      describe 'when there is a door at the boundary' do
        let(:map) do
          Map::Map.new('all doors', width: 1, height: 1, pois: [
                    { type: 'door', x: 1, y: 0, destination: { map: '../../spec/fixtures/maps/qasmoke', x: 9, y: 1 } }, # north
                    { type: 'door', x: 1, y: 2, destination: { map: '../../spec/fixtures/maps/qasmoke', x: 9, y: 2 } }, # south
                    { type: 'door', x: 0, y: 1, destination: { map: '../../spec/fixtures/maps/qasmoke', x: 9, y: 3 } }, # west
                    { type: 'door', x: 2, y: 1, destination: { map: '../../spec/fixtures/maps/qasmoke', x: 9, y: 4 } }  # east
                  ])
        end

        before do
          character.x = character.y = 1

          puts map.render
        end

        it '#up allows the character to move into the location of the door' do
          character.up

          expect(character.y).to eq(1)
        end

        it '#down allows the character to move into the location of the door' do
          character.down

          expect(character.y).to eq(2)
        end

        it '#left allows the character to move into the location of the door' do
          character.left

          expect(character.y).to eq(3)
        end

        it '#right allows the character to move into the location of the door' do
          character.right

          expect(character.y).to eq(4)
        end
      end

      describe 'when character is out of bounds' do
        pending 'it resets the character safely'
      end
    end

    describe 'adjacency' do
      let(:map) do
        Map::Map.new('adjacency', width: 3, height: 3, pois: [
                  { type: 'door', x: 2, y: 1 }, # .north
                  { type: 'item', x: 3, y: 2 }, # .east
                  { type: 'shop', x: 1, y: 2 }  # .west
                ], npcs: [
                  { name: 'test', x: 2, y: 3 }  # .south
                ])
      end

      before do
        character.x = character.y = 2 # set character to (2, 2)
      end

      describe '#north' do
        it 'returns the door above the character' do
          expect(character.north).to be_a(Map::Pois::Door)
        end
      end

      describe '#south' do
        it 'returns the npc below the character' do
          expect(character.south).to be_a(Npc)
        end
      end

      describe '#east' do
        it 'returns the item to the right of the character' do
          expect(character.east).to be_a(Map::Pois::Item)
        end
      end

      describe '#west' do
        it 'returns the shop to the left of the character' do
          expect(character.west).to be_a(Map::Pois::Shop)
        end
      end
    end

    describe 'interactions' do
      before do
        character.x = character.y = 2
      end

      let(:map) do
        Map::Map.new('interactions', width: 3, height: 3, pois: [
                  { type: 'door', x: 2, y: 1, destination: { x: 9, y: 9 } }, # .north
                  { type: 'item', name: 'baton', x: 3, y: 2 }, # .east
                  { type: 'shop', x: 1, y: 2 }  # .west
                ], npcs: [
                  { name: 'test', x: 2, y: 3 }  # .south
                ])
      end

      context 'when specifying directions' do
        it '#up accepts a block' do
          character.up do |entity|
            expect(entity).to be_a(Map::Pois::Door)
          end
        end

        it '#down accepts a block' do
          character.down do |entity|
            expect(entity).to be_a(Npc)
          end
        end

        it '#left accepts a block' do
          character.left do |entity|
            expect(entity).to be_a(Map::Pois::Shop)
          end
        end

        it '#right accepts a block' do
          character.right do |entity|
            expect(entity).to be_a(Map::Pois::Item)
          end
        end
      end

      context 'when interacting with a door' do
        before do
          character.up
        end

        it 'warps the player', :aggregate_failures do
          expect(character.x).to eq(9)
          expect(character.y).to eq(9)
        end
      end
    end

    describe '#say' do
      before do
        allow(Game.player).to receive(:await_interaction).and_return(nil)
      end

      it 'says something' do
        expect { character.say('hi') }.to output(/#{character.name}/).to_stdout
        expect { character.say('hi') }.to output(/hi/).to_stdout
      end
    end

    describe '#warp' do
      let(:blank_map) do
        Map::Map.new('blank', name: 'blank', width: 1, height: 1)
      end

      context 'when warping between maps' do
        it 'warps between maps' do
          expect(character.map).to eq(map)

          character.warp(map: blank_map)
          expect(character.map).to eq(blank_map)
        end

        context 'when coordinates are specified' do
          before do
            character.warp(map: blank_map, x: 9, y: 9)
          end

          it 'warps to the coordinates', :aggregate_failures do
            expect(character.x).to eq(9)
            expect(character.y).to eq(9)
          end

          it 'warps to the new map' do
            expect(character.map).to eq(blank_map)
          end
        end

        context 'when coordinates are not specified' do
          before do
            character.x = character.y = 9
            character.warp(map: blank_map)
          end

          it 'retains the existing character\'s coordinates', :aggregate_failures do
            expect(character.x).to eq(9)
            expect(character.y).to eq(9)
          end
        end
      end

      it 'warps to the new coordinates' do
        character.warp(x: 9, y: 9)

        expect(character.x).to eq(9)
        expect(character.y).to eq(9)
      end

      context 'when warping onto an item' do
        it 'interacts with that item' do
          character.warp(x: 4, y: 1)

          expect(character.items).to have_a(Items::Baton)
        end
      end
    end
  end
end
