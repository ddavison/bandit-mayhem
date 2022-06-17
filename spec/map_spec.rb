# frozen_string_literal: true

require 'spec_helper'

module BanditMayhem
  RSpec.describe Map do
    let(:player) { Player.new(name: 'test player') }

    subject(:map) do
      Map.new('qasmoke', file: File.absolute_path(File.join('spec', 'fixtures', 'maps', 'qasmoke.yml')))
    end

    before do
      allow(Game).to receive(:player).and_return(player)
    end

    describe 'attributes' do
      it { is_expected.to respond_to(:name) }
      it { is_expected.to respond_to(:width) }
      it { is_expected.to respond_to(:height) }

      it { is_expected.to respond_to(:pois) }

      it { is_expected.to respond_to(:type) }
      it { is_expected.to respond_to(:interiors) }

      it { is_expected.to respond_to(:north) }
      it { is_expected.to respond_to(:south) }
      it { is_expected.to respond_to(:east) }
      it { is_expected.to respond_to(:west) }
    end

    describe '#at' do
      before do
        map.generate
        puts map.render
      end

      it 'returns the door at 1,1 in qasmoke', :aggregate_failures do
        poi = map.at(x: 1, y: 1)

        expect(poi).to be_a(Map::Poi)
        expect(poi.type).to eq('door')
        expect(poi.x).to eq(1)
        expect(poi.y).to eq(1)
      end

      context 'when point is intersecting an interior' do
        it 'returns a poi in the context of that interior' do
          expect(map.at(x: 9, y: 6)).to be_a(Map::Poi::Coinpurse)
        end
      end
    end

    describe '#remove_at' do
      before do
        map.generate
      end

      it 'removes an entity at a coordinate', :aggregate_failures do
        expect(map.at(x: 2, y: 1)).to be_a(Map::Poi::Coinpurse)

        map.remove_at(x: 2, y: 1)

        expect(map.at(x: 2, y: 1)).to be_nil
      end

      it 'returns true when it was removed' do
        expect(map.remove_at(x: 2, y: 1)).to eq(true)
      end

      it 'returns false when nothing was removed' do
        expect(map.remove_at(x: 9, y: 9)).to eq(false)
      end
    end

    describe '#remove' do
      before do
        map.generate
      end

      it 'removes a poi from the map', :aggregate_failures do
        expect(map.at(x: 2, y: 1)).to be_a(Map::Poi::Coinpurse)

        map.remove(map.at(x: 2, y: 1))

        expect(map.at(x: 2, y: 1)).to be_nil
      end
    end

    describe '#render' do
      subject(:map) do
        Map.new('test', height: 1, width: 1)
      end

      context 'when map was generated' do
        before do
          map.generate
        end

        it 'renders the map' do
          expect(map.render).to eq("┌─┐\n│ │\n└─┘\n") # 1x1 map
        end
      end

      context 'when map was not yet generated' do
        it 'renders a newline' do
          expect(map.render).to eq("\n")
        end
      end
    end

    describe '#interior_at' do
      context 'when referring to a valid interior' do
        # (8,4) in qasmoke.yml is the middle of the Test Room
        it 'returns the interior at (8, 4)' do
          expect(map.interior_at(x: 8, y: 4)).to eq(map.interiors.first)
        end
      end

      context 'when not referring to a valid interior' do
        it 'returns nil' do
          expect(map.interior_at(x: 1, y: 1)).to be_nil
        end
      end
    end

    describe '#initialize' do
      it 'loads the attributes of the map' do
        expect(map.name).to eq('QA Smoke') # from qasmoke.yml fixture map
        expect(map.width).to eq(50)
        expect(map.height).to eq(10)
      end

      context 'when attributes are specified' do
        context 'when map exists' do
          subject(:map) do
            Map.new('qasmoke', height: 50, file: File.absolute_path(File.join('spec', 'fixtures', 'maps', 'qasmoke.yml')))
          end

          it 'merges the attributes' do
            expect(map.width).to eq(50)
            expect(map.height).to eq(50)
          end
        end

        context 'when map does not exist' do
          subject(:map) do
            Map.new('smoke', name: 'New Map', height: 1, width: 1)
          end

          it 'creates a brand new map' do
            expect(map.name).to eq('New Map')
            expect(map.width).to eq(1)
            expect(map.height).to eq(1)
          end

          it 'defaults pois to an empty array' do
            expect(map.pois).to eq([])
          end

          it 'defaults interiors to an empty array' do
            expect(map.interiors).to eq([])
          end
        end
      end
    end

    describe '#generate' do
      before do
        map.generate
        puts map.render
      end

      it 'generates the map' do
        expect(map).to be_generated
      end

      context '2x2 map' do
        subject(:map) { Map.new('sample',width: 2, height: 2) }

        it 'will render 4 characters total in width and height' do
          expect(map.matrix.size).to eq(4) # total level
        end

        it 'has corner bends' do
          expect(map.matrix.first[0]).to eq(Map::CORNER_UPPER_LEFT)
          expect(map.matrix.first[-1]).to eq(Map::CORNER_UPPER_RIGHT)

          expect(map.matrix.last[0]).to eq(Map::CORNER_LOWER_LEFT)
          expect(map.matrix.last[-1]).to eq(Map::CORNER_LOWER_RIGHT)
        end

        it 'left and right boundaries have vert walls' do
          # [1..-2] removes the first and the last X rows, as they are the top and bottom rows without walls.
          map.matrix[1..-2].each do |bound|
            expect(bound.first).to eq(Map::WALL_VERT)
            expect(bound.last).to eq(Map::WALL_VERT)
          end
        end

        it 'top and bottom boundaries are horiz walls' do
          expect(map.matrix.first[1..-2]).to eq([Map::WALL_HORIZ, Map::WALL_HORIZ])
          expect(map.matrix.last[1..-2]).to eq([Map::WALL_HORIZ, Map::WALL_HORIZ])
        end
      end

      context '4x4 smoke map fixture with pois' do
        before do
          map.generate
        end

        it 'renders a door' do
          expect(map.at(x: 1, y: 1)).to be_a(Map::Poi::Door)
        end

        it 'renders a coinpurse' do
          poi = map.at(x: 2, y: 1)

          expect(poi).to be_a(Map::Poi::Coinpurse)
          expect(poi.value).to eq(10)
        end

        it 'renders a shop' do
          expect(map.at(x: 3, y: 1)).to be_a(Map::Poi::Shop)
        end

        it 'renders an item' do
          expect(map.at(x: 4, y: 1)).to be_a(Map::Poi::Item)
        end

        it 'renders an NPC' do
          expect(map.at(x: 5, y: 1)).to be_a(Npc)
        end
      end

      context 'walls' do
        after do
          puts map.render
        end

        it 'renders a vert wall' do
          wall = map.at(x: 1, y: 2)

          expect(wall).to be_a(Map::Poi::Wall)
          expect(wall).to be_vertical
          expect(map.char_at(x: 1, y: 2)).to eq(Map::WALL_VERT)
        end

        it 'renders a horiz wall' do
          wall = map.at(x: 2, y: 2)

          expect(wall).to be_a(Map::Poi::Wall)
          expect(wall).to be_horizontal
          expect(map.char_at(x: 2, y: 2)).to eq(Map::WALL_HORIZ)
        end

        context 'interiors' do
          let(:matrix) { map.matrix }

          context 'boundaries' do
            it 'draws an interior' do
              expect(matrix[3][5]).to eq(Map::INTERIOR_CORNER_UPPER_LEFT)
              expect(matrix[3][6]).to eq(Map::INTERIOR_WALL_HORIZ)
            end
          end
          context 'door'
        end
      end

      context 'floor' do
        subject(:map) { Map.new('default', width: 1, height: 1) }

        it 'by default, renders spaces' do
          expect(map.char_at(x: 1, y: 1)).to eq(' ')
        end
      end
    end

    describe '#char_at' do
      it 'returns the appropriate runes', :aggregate_failures do
        expect(map.char_at(x: 1, y: 1)).to eq(Map::DOOR)
        expect(map.char_at(x: 2, y: 1)).to eq(Map::COINPURSE)
        expect(map.char_at(x: 3, y: 1)).to eq(Map::SHOP)
        expect(map.char_at(x: 4, y: 1)).to eq(Map::ITEM)
        expect(map.char_at(x: 5, y: 1)).to eq(Map::NPC)
      end
    end

    describe 'borders' do
      subject(:map) do
        described_class.new('with borders', file: File.absolute_path(File.join('spec', 'fixtures', 'maps', 'with_borders.yml')))
      end

      describe '#north' do
        it 'returns the map to the north' do
          expect(map.north).to be_a(Map)
          expect(map.north.name).to eq('north_map')
        end
      end

      describe '#south' do
        it 'returns the map to the south' do
          expect(map.south).to be_a(Map)
          expect(map.south.name).to eq('south_map')
        end
      end

      describe '#west' do
        it 'returns the map to the west' do
          expect(map.west).to be_a(Map)
          expect(map.west.name).to eq('west_map')
        end
      end

      describe '#east' do
        it 'returns the map to the east' do
          expect(map.east).to be_a(Map)
          expect(map.east.name).to eq('east_map')
        end
      end
    end
  end
end
