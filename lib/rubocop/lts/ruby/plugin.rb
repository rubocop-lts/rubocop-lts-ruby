# frozen_string_literal: true

require "lint_roller"
require "pathname"
require_relative "version"

module RuboCop
  module Lts
    module Ruby
      # LintRoller adapter that supplies this gem's API-gating rules.
      class Plugin < LintRoller::Plugin
        def about
          LintRoller::About.new(
            name: "rubocop-lts-ruby",
            version: VERSION,
            homepage: "https://github.com/rubocop-lts/rubocop-lts-ruby",
            description: "RuboCop cops that gate Ruby core and standard library APIs by target Ruby version."
          )
        end

        def supported?(context)
          context.engine == :rubocop
        end

        def rules(context)
          LintRoller::Rules.new(
            type: :path,
            config_format: :rubocop,
            value: Pathname.new(__dir__).join("../../../../config/base.yml")
          )
        end
      end
    end
  end
end
