# frozen_string_literal: true

require 'spec_helper'

module BanditMayhem
  RSpec.describe Player do
    subject(:player) { described_class.new(name: 'Test') }

    let(:map) do
      Map.new('qasmoke', file: File.absolute_path(File.join('spec', 'fixtures', 'maps', 'qasmoke.yml')))
    end

    before do
      allow(Game).to receive(:player).and_return(player)
    end

    it 'inherits attributes from Character' do
      expect(player.name).to eq('Test')
      expect(player.str).to eq(10)
      expect(player.def).to eq(0)
      expect(player.gold).to eq(0)
    end

    it 'starts at a health of 100' do
      expect(player.health).to eq(100)
    end

    it 'has an empty inventory' do
      expect(player.items).to eq([])
    end

    describe 'dialog' do
      let(:npc) do
        Npc.new(name: 'NPC', dialog: {
                  'Hi there, how are you?': [
                    'Good, thanks': "That's good",
                    'Not great': "I'm sorry to hear that"
                  ]
                })
      end

      it 'works' do
        player.interact_with(npc)
      end
    end

    pending 'interactions'
  end
end
