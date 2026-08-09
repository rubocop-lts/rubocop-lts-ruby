# frozen_string_literal: true

require 'rubygems/version'

module RuboCop
  module Lts
    module Ruby
      # Runtime APIs whose availability is tied to the Ruby release that added them.
      # Keep entries explicit until a versioned API source can be made authoritative.
      module Catalog
        Entry = Data.define(:owner, :method_name, :introduced_in)

        ENTRIES = [
          Entry.new('Array', :append, Gem::Version.new('2.5')),
          Entry.new('Array', :difference, Gem::Version.new('2.6')),
          Entry.new('Array', :intersection, Gem::Version.new('2.6')),
          Entry.new('Array', :union, Gem::Version.new('2.6')),
          Entry.new('Enumerable', :filter_map, Gem::Version.new('2.7')),
          Entry.new('Enumerable', :tally, Gem::Version.new('2.7')),
          Entry.new('Hash', :except, Gem::Version.new('2.5')),
          Entry.new('Hash', :slice, Gem::Version.new('2.5')),
          Entry.new('Hash', :transform_keys, Gem::Version.new('2.5')),
          Entry.new('Hash', :transform_values, Gem::Version.new('2.4')),
          Entry.new('Integer', :digits, Gem::Version.new('2.4')),
          Entry.new('Object', :then, Gem::Version.new('2.6')),
          Entry.new('Object', :yield_self, Gem::Version.new('2.5')),
          Entry.new('String', :delete_prefix, Gem::Version.new('2.5')),
          Entry.new('String', :delete_suffix, Gem::Version.new('2.5')),
          Entry.new('String', :match?, Gem::Version.new('2.4'))
        ].freeze

        BY_METHOD = ENTRIES.group_by(&:method_name).transform_values(&:freeze).freeze

        module_function

        def lookup(method_name)
          BY_METHOD[method_name]
        end
      end
    end
  end
end
