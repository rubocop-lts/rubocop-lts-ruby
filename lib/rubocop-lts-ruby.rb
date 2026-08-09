# frozen_string_literal: true

require_relative "rubocop/lts/ruby/plugin"
require "version_gem"
require_relative "rubocop/lts/ruby/version"

RuboCop::Lts::Ruby::Version.class_eval do
  extend VersionGem::Basic
end
