# frozen_string_literal: true

require 'spec_helper'

module BanditMayhem
  RSpec.describe Validatable do
    subject(:validated_class) do
      Class.new do
        include Validatable
        include Attributable

        attribute :name, 'test'
        validates :name, type: String
      end.new
    end

    context 'when class is valid'

    context 'when class is invalid' do
      before do
        validated_class.name = 1
      end

      it 'is invalid' do
        expect(validated_class).not_to be_valid
      end
    end

    it 'is valid'
  end
end
