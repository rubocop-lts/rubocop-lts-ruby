# frozen_string_literal: true

require 'rubocop/lts/ruby'
require 'rubocop/lts/ruby/catalog'
require 'rubocop/lts/ruby/cop/lint_lts_ruby/unavailable_method'
require 'rubocop/lts/ruby/plugin'
require 'rubocop/rspec/support'

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.raise_errors_for_deprecations!
  config.raise_on_warning = true
  config.order = :random
  Kernel.srand config.seed
end
