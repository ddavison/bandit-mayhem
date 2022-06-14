# frozen_string_literal: true

require 'item'

describe BanditMayhem::Item do
  let(:character) { BanditMayhem::Character.new({}) }
  context 'when using an item' do
    context 'when item is a weapon' do
      let(:weapon) { BanditMayhem::Item.new({weapon: true})}
      let(:consumable) { BanditMayhem::Item.new }


    end

    context 'when item is a consumable' do

    end
  end
end
