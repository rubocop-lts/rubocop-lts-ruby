# frozen_string_literal: true

require 'rubocop'
require 'rubocop/lts/ruby/catalog'

module RuboCop
  module Cop
    module Lint
      module LtsRuby
        # Reports known Ruby APIs that were introduced after the configured target.
        #
        # RuboCop's TargetRubyVersion handles syntax and version-aware style rules,
        # but it does not provide a complete runtime API compatibility database.
        # This cop fills that gap for explicit receiver calls in the catalog.
        class UnavailableMethod < Base
          MSG = '%<owner>s#%<method>s is unavailable before Ruby %<version>s.'

          RESTRICT_ON_SEND = RuboCop::Lts::Ruby::Catalog::BY_METHOD.keys.freeze

          def on_send(node)
            return unless node.receiver

            entries = RuboCop::Lts::Ruby::Catalog.lookup(node.method_name)
            return unless entries

            entries.each { |entry| report_unavailable(node, entry) }
          end

          private

          def target_ruby_version
            @target_ruby_version ||= Gem::Version.new(super.to_s)
          end

          def allowed_methods
            Array(cop_config.fetch('AllowedMethods', [])).map(&:to_s)
          end

          def method_key(entry)
            "#{entry.owner}##{entry.method_name}"
          end

          def report_unavailable(node, entry)
            return unless target_ruby_version < entry.introduced_in
            return if allowed_methods.include?(method_key(entry))

            add_offense(node.selector, message: offense_message(entry))
          end

          def offense_message(entry)
            format(MSG, owner: entry.owner, method: entry.method_name, version: entry.introduced_in)
          end
        end
      end
    end
  end
end
