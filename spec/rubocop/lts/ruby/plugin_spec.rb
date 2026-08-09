# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Lts::Ruby::Plugin do
  subject(:plugin) { described_class.new }

  it 'supports RuboCop' do
    context = instance_double(LintRoller::Context, engine: :rubocop)

    expect(plugin).to be_supported(context)
  end

  it 'selects the profile matching the target Ruby minor version' do
    context = instance_double(LintRoller::Context, engine: :rubocop, target_ruby_version: Gem::Version.new('2.5'))

    expect(plugin.rules(context).value.to_s).to end_with('config/ruby-2.5.yml')
  end

  it 'uses the 2.0 profile for adapter targets below RuboCop\'s floor' do
    context = instance_double(LintRoller::Context, engine: :rubocop, target_ruby_version: Gem::Version.new('1.8'))

    expect(plugin.rules(context).value.to_s).to end_with('config/ruby-2.0.yml')
  end

  it 'uses the newest available profile for a newer target' do
    context = instance_double(LintRoller::Context, engine: :rubocop, target_ruby_version: Gem::Version.new('9.0'))

    expect(plugin.rules(context).value.to_s).to end_with('config/ruby-4.0.yml')
  end
end
