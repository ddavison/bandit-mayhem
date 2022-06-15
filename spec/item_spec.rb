# frozen_string_literal: true

require 'spec_helper'

module BanditMayhem
  RSpec.describe Item do
    subject(:item) do
      described_class.new(name: 'test item')
    end

    describe 'attributes' do
      it { is_expected.to respond_to(:name) }
      it { is_expected.to respond_to(:value) }
    end
  end
end
