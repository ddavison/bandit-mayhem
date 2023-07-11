# frozen_string_literal: true

FactoryBot.define do
  factory :map, class: 'BanditMayhem::Map::Map' do
    name { nil }
    width { 1 }
    height { 1 }

    initialize_with { new(name, **attributes) }
  end
end
