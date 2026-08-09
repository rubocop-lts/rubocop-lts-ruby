# frozen_string_literal: true

require "spec_helper"

RSpec.describe RuboCop::Lts::Ruby::Plugin do
  subject(:plugin) { described_class.new }

  it "supports RuboCop" do
    context = instance_double(LintRoller::Context, engine: :rubocop)

    expect(plugin).to be_supported(context)
  end

  it "supplies its rule configuration without changing the target Ruby version" do
    context = instance_double(LintRoller::Context, engine: :rubocop, target_ruby_version: Gem::Version.new("2.5"))
    config = YAML.safe_load_file(plugin.rules(context).value)

    expect(plugin.rules(context).value.to_s).to end_with("config/base.yml")
    expect(config.dig("AllCops", "TargetRubyVersion")).to be_nil
  end
end
