# frozen_string_literal: true

require "rubygems/version"

module RuboCop
  module Lts
    module Ruby
      # Runtime APIs whose availability is tied to the Ruby release that added them.
      # Keep entries explicit until a versioned API source can be made authoritative.
      module Catalog
        Entry = Data.define(:owner, :method_name, :introduced_in, :receiver_type)

        def self.entry(owner, method_name, introduced_in, receiver_type: :instance)
          Entry.new(owner, method_name, Gem::Version.new(introduced_in), receiver_type)
        end

        ENTRIES = [
          entry("Array", :append, "2.5"),
          entry("Array", :prepend, "2.5"),
          entry("Array", :difference, "2.6"),
          entry("Array", :intersection, "2.6"),
          entry("Array", :union, "2.6"),
          entry("Dir", :children, "2.5", receiver_type: :constant),
          entry("Dir", :each_child, "2.5", receiver_type: :constant),
          entry("Enumerable", :filter_map, "2.7"),
          entry("Enumerable", :tally, "2.7"),
          entry("Enumerable", :chain, "2.6"),
          entry("Enumerator", :+, "2.6"),
          entry("Enumerator::Lazy", :eager, "2.7"),
          entry("Exception", :full_message, "2.5"),
          entry("Hash", :except, "3.0"),
          entry("Hash", :slice, "2.5"),
          entry("Hash", :transform_keys, "2.5"),
          entry("Hash", :transform_values, "2.4"),
          entry("Integer", :digits, "2.4"),
          entry("MatchData", :byteoffset, "3.2"),
          entry("Object", :then, "2.6"),
          entry("Object", :yield_self, "2.5"),
          entry("Proc", :<<, "2.6"),
          entry("Proc", :>>, "2.6"),
          entry("Process", :warmup, "3.3", receiver_type: :constant),
          entry("Range", :overlap?, "3.3"),
          entry("Regexp", :timeout, "3.2", receiver_type: :constant),
          entry("Regexp", :"timeout=", "3.2", receiver_type: :constant),
          entry("String", :delete_prefix, "2.5"),
          entry("String", :delete_suffix, "2.5"),
          entry("String", :match?, "2.4"),
          entry("String", :byteindex, "3.2"),
          entry("String", :byterindex, "3.2"),
          entry("String", :bytesplice, "3.2"),
          entry("Data", :define, "3.2", receiver_type: :constant)
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
