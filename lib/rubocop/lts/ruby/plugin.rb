# frozen_string_literal: true

require 'lint_roller'
require 'pathname'
require 'rubygems/version'
require_relative 'version'

module RuboCop
  module Lts
    module Ruby
      # LintRoller adapter that selects the API profile for the target Ruby.
      class Plugin < LintRoller::Plugin
        PROFILE_VERSIONS = %w[
          2.0 2.1 2.2 2.3 2.4 2.5 2.6 2.7
          3.0 3.1 3.2 3.3 3.4 4.0
        ].map { |version| Gem::Version.new(version) }.freeze

        def about
          LintRoller::About.new(
            name: 'rubocop-lts-ruby',
            version: VERSION,
            homepage: 'https://github.com/rubocop-lts/rubocop-lts-ruby',
            description: 'RuboCop cops that gate Ruby core and standard library APIs by target Ruby version.'
          )
        end

        def supported?(context)
          context.engine == :rubocop
        end

        def rules(context)
          LintRoller::Rules.new(
            type: :path,
            config_format: :rubocop,
            value: Pathname.new(__dir__).join("../../../../config/ruby-#{profile_version(context)}.yml")
          )
        end

        private

        def profile_version(context)
          target = Gem::Version.new((context.target_ruby_version || RUBY_VERSION).to_s)
          PROFILE_VERSIONS.select { |version| version <= target }.last || PROFILE_VERSIONS.first
        end
      end
    end
  end
end
