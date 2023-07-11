# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

require 'bandit_mayhem'
require 'rspec-parameterized'
require 'factory_bot'

RSpec.configure do |rspec|
  rspec.include FactoryBot::Syntax::Methods

  rspec.order = :random

  rspec.disable_monkey_patching!

  FactoryBot.find_definitions
end

def fixture_file(path)
  File.absolute_path(File.join('spec', 'fixtures', path))
end

def map_fixture(map)
  fixture_file("maps/#{map}")
end
