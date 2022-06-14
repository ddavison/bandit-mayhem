# frozen_string_literal: true

require 'items/health_potion'

describe BanditMayhem::Items::HealthPotion do
  let(:character) { BanditMayhem::Character.new({health: 85}) }

  it 'heals the player by 25' do
    expect(character.get_av('health')).to eq(85)
    subject.use_on!(character)

    expect(character.get_av('health')).to eq(85+25)
  end
end
