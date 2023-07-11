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

    describe '#valid?' do
      subject(:validated_class) do
        Class.new do
          include Attributable

          attribute :attr, type: String
        end.new
      end

      context 'when attribute has an invalid type' do
        subject(:invalid_class) do
          Class.new do
            include Attributable

            attribute :attr, 10, type: String
          end.new
        end

        it 'is invalid' do
          expect(invalid_class).not_to be_valid
          expect(invalid_class.errors.first).to eq('attr is not a String')
        end
      end

      context 'when an attribute is required but not passed' do
        subject(:invalid_class) do
          Class.new do
            include Attributable

            attribute :attr, required: true
          end.new
        end

        it 'is invalid' do
          expect(invalid_class).not_to be_valid
          expect(invalid_class.errors.first).to eq('attr is required')
        end
      end

      context 'when an attribute is optional' do
        subject(:valid_class) do
          Class.new do
            include Attributable

            attribute :attr
          end.new
        end

        it 'is valid' do
          expect(valid_class).to be_valid
        end
      end
    end
  end
end
