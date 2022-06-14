# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
require 'bandit_mayhem'

RSpec.configure do |rspec|
  rspec.order = :random

  rspec.disable_monkey_patching!
end
