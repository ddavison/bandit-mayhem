# frozen_string_literal: true

require 'spec_helper'

module BanditMayhem
  RSpec.describe Attributable do
    subject(:attributed_class) do
      Class.new do
        include Attributable

        attribute :health, 100
        attribute :str, 10
      end.new
    end

    describe 'reader' do
      it 'has the default value' do
        expect(attributed_class.health).to eq(100)
        expect(attributed_class.str).to eq(10)
      end
    end

    describe '#attributes' do
      it 'returns all attributes' do
        expect(attributed_class.attributes).to include(health: 100, str: 10)
      end
    end

    describe '#merge_attributes' do
      it 'merges attributes in' do
        attributed_class.merge_attributes(str: 20)

        expect(attributed_class.str).to eq(20)
      end
    end

    describe '#current_attributes' do
      it 'has all calculated attributes' do
        expect(attributed_class.current_attributes).to eq({
          health: 100, str: 10
        })
      end
    end

    describe '#[]' do
      it 'returns an attribute', :aggregate_failures do
        expect(attributed_class[:health]).to eq(100)
        expect(attributed_class[:str]).to eq(10)
      end
    end
  end
end
