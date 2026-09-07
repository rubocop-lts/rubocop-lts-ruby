# frozen_string_literal: true

require "rubocop"
require "rubocop/lts/ruby/catalog"

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
          MSG = "%<owner>s#%<method>s is unavailable before Ruby %<version>s."

          RESTRICT_ON_SEND = RuboCop::Lts::Ruby::Catalog::BY_METHOD.keys.freeze

          def on_send(node)
            return unless node.receiver

            entries = RuboCop::Lts::Ruby::Catalog.lookup(node.method_name)
            return unless entries

            applicable_entries = entries.select { |entry| entry_applies?(node, entry) }
            applicable_entries.group_by(&:introduced_in).each_value do |same_version_entries|
              report_unavailable(node, same_version_entries)
            end
          end

          private

          def target_ruby_version
            @target_ruby_version ||= Gem::Version.new(super.to_s)
          end

          def allowed_methods
            Array(cop_config.fetch("AllowedMethods", [])).map(&:to_s)
          end

          def method_keys(entries)
            entries.map { |entry| "#{entry.owner}##{entry.method_name}" }
          end

          def entry_applies?(node, entry)
            case entry.receiver_type
            when :instance
              !node.receiver.const_type?
            when :constant
              node.receiver.const_type? && node.receiver.const_name == entry.owner
            when :constructed_instance
              constructed_instance_of?(node.receiver, entry.owner)
            else
              false
            end
          end

          # A local receiver has no reliable static class in RuboCop's AST. Restrict
          # constructor-only APIs to a directly visible `Owner.new` expression rather
          # than treating every nonconstant receiver as an instance of that owner.
          def constructed_instance_of?(receiver, owner)
            receiver.send_type? && receiver.method?(:new) &&
              receiver.receiver&.const_type? && receiver.receiver.const_name == owner
          end

          def report_unavailable(node, entries)
            return unless target_ruby_version < entries.first.introduced_in
            return if method_keys(entries).any? { |key| allowed_methods.include?(key) }

            add_offense(node.selector, message: offense_message(entries))
          end

          def offense_message(entries)
            owners = entries.map(&:owner).uniq.join("/")
            format(MSG, owner: owners, method: entries.first.method_name, version: entries.first.introduced_in)
          end
        end
      end
    end
  end
end
