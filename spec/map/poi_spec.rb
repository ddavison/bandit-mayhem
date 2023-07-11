# frozen_string_literal: true

module BanditMayhem
  module Map
    RSpec.describe Poi do
      subject(:subclass) do
        Class.new(described_class).new(poi_hash)
      end

      let(:poi_hash) do
        {
          name: 'My Poi',
          x: 0,
          y: 0,
          type: 'test'
        }
      end

      describe 'validations' do
        it 'inherits all validations' do
          expect(subclass.validations).to eq(described_class.validations)
        end
      end
    end
  end
end
