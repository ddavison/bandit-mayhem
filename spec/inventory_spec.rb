# frozen_string_literal: true

require 'spec_helper'

module BanditMayhem
  RSpec.describe Inventory do
    describe 'extending from array' do
      subject(:inventory) do
        described_class.new(%w[foo bar])
      end

      it 'preserves normal array behavior' do
        expect(inventory).to be_a(Array)
      end
    end

    let(:item) do
      Item.new(name: 'test item')
    end

    describe '#include?' do
      subject(:inventory) do
        described_class.new([item, item])
      end

      it 'returns true if the item is included in the inventory' do
        expect(inventory).to include(item)
      end
    end

    describe '#has_a?' do
      let(:test_item) do
        Class.new(Item) do
        end
      end
      subject(:inventory) do
        described_class.new([item, test_item.new(name: 'test')])
      end

      it 'returns true when it has that item' do
        expect(inventory).to have_a(test_item)
      end
    end
  end
end
