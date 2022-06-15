# frozen_string_literal: true

require 'spec_helper'

module BanditMayhem
  RSpec.describe Npc do
    subject(:npc) do
      described_class.new(name: 'Test NPC')
    end

    describe 'dialog' do
      subject(:npc) do
        described_class.new(name: 'Test NPC with Dialog', dialog: [
          'Hi there': 'Hi'
        ])
      end

      it 'works' do
        expect(true).to eq(true)
      end
    end
  end
end
