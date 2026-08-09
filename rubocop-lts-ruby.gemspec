# frozen_string_literal: true

require_relative 'lib/rubocop/lts/ruby/version'

Gem::Specification.new do |spec|
  spec.name = 'rubocop-lts-ruby'
  spec.version = RuboCop::Lts::Ruby::VERSION
  spec.authors = ['Peter H. Boling']
  spec.email = ['floss@galtzo.com']
  spec.summary = 'Std Lib Gating Cops-per-each Version of Ruby'
  spec.description = <<~DESCRIPTION
    RuboCop cops that detect use of Ruby core and standard library APIs that are
    unavailable for the configured TargetRubyVersion.
  DESCRIPTION
  spec.homepage = 'https://github.com/rubocop-lts/rubocop-lts-ruby'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.2.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata['bug_tracker_uri'] = "#{spec.homepage}/issues"
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.metadata['default_lint_roller_plugin'] = 'RuboCop::Lts::Ruby::Plugin'

  spec.files = Dir[
    'CHANGELOG.md',
    'LICENSE.md',
    'README.md',
    'Rakefile',
    'config/**/*.yml',
    'lib/**/*.rb',
    'rubocop-lts-ruby.gemspec'
  ]
  spec.require_paths = ['lib']

  spec.add_dependency 'lint_roller', '~> 1.1'
  spec.add_dependency 'rubocop', '>= 1.72.1', '< 2.0'
end
