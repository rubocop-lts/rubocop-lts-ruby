# rubocop-lts-ruby

RuboCop cops that gate Ruby core and standard library APIs by target Ruby
version. The plugin is intended for projects that run RuboCop on a modern Ruby
while maintaining compatibility with an older Ruby runtime.

## Installation

Add the gem to the development dependencies used by RuboCop:

```ruby
gem "rubocop-lts-ruby"
```

Then enable the plugin in `.rubocop.yml`:

```yaml
plugins:
  - rubocop-lts-ruby
```

The plugin selects the highest bundled API profile at or below
`AllCops/TargetRubyVersion`. For example, a target of Ruby 2.5 loads the Ruby
2.5 profile, while a target of Ruby 3.2 loads the Ruby 3.2 profile.

RuboCop itself cannot target Ruby versions earlier than 2.0. The
`rubocop-ruby1_8` and `rubocop-ruby1_9` adapters therefore use the 2.0 profile
as their API baseline and layer their version-specific compatibility rules on
top. The plugin runs on modern Ruby; `TargetRubyVersion` describes the Ruby
being supported by the checked project, not the Ruby running RuboCop.

## Configuration

The `Lint/LtsRuby/UnavailableMethod` cop is enabled by the plugin. It reports
explicit receiver calls for catalogued APIs that were introduced after the
target Ruby version. Since static analysis cannot prove the runtime type of
every receiver, a project can document a known-safe exception narrowly:

```yaml
Lint/LtsRuby/UnavailableMethod:
  AllowedMethods:
    - Enumerable#filter_map
```

The catalog is deliberately explicit. New entries should include the owning
core or standard-library class and the first Ruby version that provides the
method, with a spec covering the compatibility boundary.

## Basic Usage

Run RuboCop normally after enabling the plugin:

```bash
bundle exec rubocop
```

For a one-off check without editing `.rubocop.yml`:

```bash
bundle exec rubocop --plugin rubocop-lts-ruby
```

The plugin reports compatibility issues; it does not rewrite source code.
