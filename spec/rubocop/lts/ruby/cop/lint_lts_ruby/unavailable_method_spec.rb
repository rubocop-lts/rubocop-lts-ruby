# frozen_string_literal: true

require "spec_helper"

RSpec.describe RuboCop::Cop::Lint::LtsRuby::UnavailableMethod, :config do
  let(:ruby_version) { 2.0 }
  let(:cop_config) { {"Enabled" => true, "AllowedMethods" => []} }

  it "registers an offense for an API introduced after the target Ruby" do
    expect_offense(<<~RUBY)
      values.filter_map { |value| value }
             ^^^^^^^^^^ Enumerable#filter_map is unavailable before Ruby 2.7.
    RUBY
  end

  it "reports the instance APIs in the catalog" do
    {
      "Array#prepend" => ["values.prepend(value)", "prepend"],
      "Dir#children" => ["Dir.children(path)", "children"],
      "Dir#each_child" => ["Dir.each_child(path) { |entry| entry }", "each_child"],
      "Exception#full_message" => ["error.full_message", "full_message"],
      "Enumerable#chain" => ["values.chain(other_values)", "chain"],
      "Enumerator#+" => ["enumerator + other_enumerator", "+"],
      "Enumerator::Lazy#eager" => ["values.lazy.eager", "eager"],
      "Hash#except" => ["values.except(:key)", "except"],
      "MatchData#byteoffset" => ["match.byteoffset(0)", "byteoffset"],
      "Object#then" => ["value.then { |item| item }", "then"],
      "Proc#<<" => ["callable << other_callable", "<<"],
      "Proc#>>" => ["callable >> other_callable", ">>"],
      "Range#overlap?" => ["range.overlap?(other_range)", "overlap?"],
      "String#byteindex" => ["value.byteindex(pattern)", "byteindex"],
      "String#byterindex" => ["value.byterindex(pattern)", "byterindex"],
      "String#bytesplice" => ["value.bytesplice(0, 1, replacement)", "bytesplice"]
    }.each do |api, (source, selector)|
      introduced_in = RuboCop::Lts::Ruby::Catalog::ENTRIES.find { |entry| "#{entry.owner}##{entry.method_name}" == api }.introduced_in
      marker = " " * source.index(selector) + "^" * selector.length

      expect_offense(<<~RUBY)
        #{source}
        #{marker} #{api} is unavailable before Ruby #{introduced_in}.
      RUBY
    end
  end

  it "reports the constant APIs in the catalog" do
    {
      "Data#define" => ["Data.define(:amount)", "define"],
      "Process#warmup" => ["Process.warmup", "warmup"],
      "Regexp#timeout" => ["Regexp.timeout", "timeout"],
      "Regexp#timeout=" => ["Regexp.timeout = 1.0", "timeout"]
    }.each do |api, (source, selector)|
      introduced_in = RuboCop::Lts::Ruby::Catalog::ENTRIES.find { |entry| "#{entry.owner}##{entry.method_name}" == api }.introduced_in
      marker = " " * source.index(selector) + "^" * selector.length

      expect_offense(<<~RUBY)
        #{source}
        #{marker} #{api} is unavailable before Ruby #{introduced_in}.
      RUBY
    end
  end

  context "when the target supports the API" do
    let(:ruby_version) { 2.7 }

    it "does not report an API available in the target Ruby" do
      expect_no_offenses("values.filter_map { |value| value }")
    end
  end

  context "when the target supports a corrected catalog entry" do
    let(:ruby_version) { 3.0 }

    it "does not report Hash#except" do
      expect_no_offenses("values.except(:key)")
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

  context "with a non-owning constant receiver" do
    let(:ruby_version) { 3.1 }

    it "does not report a singleton API by method name alone" do
      expect_no_offenses("settings.timeout = 1.0")
    end
  end
end
