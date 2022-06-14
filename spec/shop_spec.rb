# frozen_string_literal: true

require 'shop'
require 'character'

describe BanditMayhem::Shop do
  subject { BanditMayhem::Shop.new({inventory: ['HealthPotion']}, character) }

  let(:character) { BanditMayhem::Character.new }

  it 'has HealthPotion in stock' do
    expect(subject.inventory).to include('HealthPotion')
  end

  context '#buy!' do
    before(:each) do
      character.set_av('gold', 100)
    end

    context 'can buy an item' do
      it 'by name' do
        expect(subject.inventory.size).to eq(1)

        expect(subject.buy!('HealthPotion')).to be_a(BanditMayhem::Items::HealthPotion)
      end

      it 'by index' do
        expect(subject.inventory.size).to eq(1)

        expect(subject.buy!(0)).to be_a(BanditMayhem::Items::HealthPotion)
      end
    end
  end
end
