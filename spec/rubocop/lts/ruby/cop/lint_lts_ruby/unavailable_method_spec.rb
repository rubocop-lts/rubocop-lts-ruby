# frozen_string_literal: true

require "spec_helper"

RSpec.describe RuboCop::Cop::Lint::LtsRuby::UnavailableMethod, :config do
  let(:ruby_version) { 2.5 }
  let(:cop_config) { {"Enabled" => true, "AllowedMethods" => []} }

  it "registers an offense for an API introduced after the target Ruby" do
    expect_offense(<<~RUBY)
      values.filter_map { |value| value }
             ^^^^^^^^^^ Enumerable#filter_map is unavailable before Ruby 2.7.
    RUBY
  end

  context "when the target supports the API" do
    let(:ruby_version) { 2.7 }

    it "does not report an API available in the target Ruby" do
      expect_no_offenses("values.filter_map { |value| value }")
    end
  end

  it "does not report an implicit receiver" do
    expect_no_offenses("filter_map { |value| value }")
  end

  context "with a project-specific exception" do
    let(:cop_config) do
      {"Enabled" => true, "AllowedMethods" => ["Enumerable#filter_map"]}
    end

    it "allows project-specific receiver knowledge to suppress an entry" do
      expect_no_offenses("values.filter_map { |value| value }")
    end
  end
end
