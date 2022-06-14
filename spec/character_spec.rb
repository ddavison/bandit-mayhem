# frozen_string_literal: true

require 'spec_helper'

module BanditMayhem
  RSpec.describe Character do
    subject(:character) do
      described_class.new(name: 'Some Dude')
    end

    let(:map) do
      Map.new('qasmoke', file: File.absolute_path(File.join('spec', 'fixtures', 'maps', 'qasmoke.yml')))
    end

    before do
      allow(Game).to receive(:player).and_return(Player.new(name: 'unused')) # prevent player from being rendered.
      allow(Game).to receive(:map).and_return(map)

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
      context 'when walls are in the way' do
        before do
          character.x = character.y = 2 # set character to (2, 2)
        end

        let(:map) do
          Map.new('map with walls', width: 3, height: 3, pois: [
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
    end

    describe 'adjacency' do
      let(:map) do
        Map.new('adjacency', width: 3, height: 3, pois: [
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
          expect(character.north).to be_a(Map::Poi::Door)
        end
      end

      describe '#south' do
        it 'returns the npc below the character' do
          expect(character.south).to be_a(Characters::Npc)
        end
      end

      describe '#east' do
        it 'returns the item to the right of the character' do
          expect(character.east).to be_a(Map::Poi::Item)
        end
      end

      describe '#west' do
        it 'returns the shop to the left of the character' do
          expect(character.west).to be_a(Map::Poi::Shop)
        end
      end
    end
  end
end
