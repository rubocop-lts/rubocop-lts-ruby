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
      "Array#intersect?" => ["values.intersect?(other_values)", "intersect?"],
      "Class#subclasses" => ["klass.subclasses", "subclasses"],
      "Dir#children" => ["Dir.children(path)", "children"],
      "Dir#each_child" => ["Dir.each_child(path) { |entry| entry }", "each_child"],
      "Exception#full_message" => ["error.full_message", "full_message"],
      "Enumerable#chain" => ["values.chain(other_values)", "chain"],
      "Enumerable/Enumerator::Lazy#compact" => ["values.compact", "compact"],
      "Enumerator#+" => ["enumerator + other_enumerator", "+"],
      "Enumerator::Lazy#eager" => ["values.lazy.eager", "eager"],
      "Hash#except" => ["values.except(:key)", "except"],
      "KeyError#key" => ["error.key", "key"],
      "MatchData#byteoffset" => ["match.byteoffset(0)", "byteoffset"],
      "MatchData#match" => ["match.match(pattern)", "match"],
      "MatchData#match_length" => ["match.match_length(0)", "match_length"],
      "Object#then" => ["value.then { |item| item }", "then"],
      "Method/Proc#<<" => ["callable << other_callable", "<<"],
      "Method/Proc#>>" => ["callable >> other_callable", ">>"],
      "Range#overlap?" => ["range.overlap?(other_range)", "overlap?"],
      "Array/Range#minmax" => ["range.minmax", "minmax"],
      "String#byteindex" => ["value.byteindex(pattern)", "byteindex"],
      "String#byterindex" => ["value.byterindex(pattern)", "byterindex"],
      "String#bytesplice" => ["value.bytesplice(0, 1, replacement)", "bytesplice"],
      "String#delete_prefix!" => ["value.delete_prefix!(prefix)", "delete_prefix!"],
      "String#undump" => ["value.undump", "undump"],
      "Thread#fetch" => ["thread.fetch(:name)", "fetch"],
      "Thread#native_thread_id" => ["thread.native_thread_id", "native_thread_id"]
    }.each do |api, (source, selector)|
      introduced_in = RuboCop::Lts::Ruby::Catalog::ENTRIES.find { |entry| "#{entry.owner}##{entry.method_name}" == api }&.introduced_in ||
        RuboCop::Lts::Ruby::Catalog::ENTRIES.find { |entry| entry.method_name.to_s == selector }.introduced_in
      marker = " " * source.rindex(selector) + "^" * selector.length

      expect_offense(<<~RUBY)
        #{source}
        #{marker} #{api} is unavailable before Ruby #{introduced_in}.
      RUBY
    end
  end

  it "reports the constant APIs in the catalog" do
    {
      "Data#define" => ["Data.define(:amount)", "define"],
      "GC#measure_total_time" => ["GC.measure_total_time", "measure_total_time"],
      "GC#measure_total_time=" => ["GC.measure_total_time = true", "measure_total_time"],
      "GC#total_time" => ["GC.total_time", "total_time"],
      "Integer#try_convert" => ["Integer.try_convert(value)", "try_convert"],
      "Fiber#blocking?" => ["Fiber.blocking?", "blocking?"],
      "Random#bytes" => ["Random.bytes(1)", "bytes"],
      "Process#warmup" => ["Process.warmup", "warmup"],
      "Regexp#timeout" => ["Regexp.timeout", "timeout"],
      "Regexp#timeout=" => ["Regexp.timeout = 1.0", "timeout"],
      "Thread::Backtrace#limit" => ["Thread::Backtrace.limit", "limit"],
      "Thread#ignore_deadlock" => ["Thread.ignore_deadlock", "ignore_deadlock"],
      "TracePoint#allow_reentry" => ["TracePoint.allow_reentry", "allow_reentry"],
      "Warning#[]" => ["Warning.[](:deprecated)", "[]"]
    }.each do |api, (source, selector)|
      introduced_in = RuboCop::Lts::Ruby::Catalog::ENTRIES.find { |entry| "#{entry.owner}##{entry.method_name}" == api }.introduced_in
      marker = " " * source.rindex(selector) + "^" * selector.length

      expect_offense(<<~RUBY)
        #{source}
        #{marker} #{api} is unavailable before Ruby #{introduced_in}.
      RUBY
    end
  end

  it "combines indistinguishable Method and UnboundMethod APIs" do
    expect_offense(<<~RUBY)
      callable.public?
               ^^^^^^^ Method/UnboundMethod#public? is unavailable before Ruby 3.1.
    RUBY
  end

  context "when the target supports the API" do
    let(:ruby_version) { 2.7 }

    it "does not report an API available in the target Ruby" do
      expect_no_offenses("values.filter_map { |value| value }")
    end
  end

  context "when the target predates the catalog" do
    let(:ruby_version) { 1.9 }

    it "reports GC::Profiler.raw_data" do
      expect_offense(<<~RUBY)
        GC::Profiler.raw_data
                     ^^^^^^^^ GC::Profiler#raw_data is unavailable before Ruby 2.0.
      RUBY
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

  it "keeps each catalog entry uniquely identified" do
    entries = RuboCop::Lts::Ruby::Catalog::ENTRIES
    keys = entries.map { |entry| [entry.owner, entry.method_name, entry.receiver_type] }

    expect(keys).to eq(keys.uniq)
    expect(entries.map(&:introduced_in)).to all(be_a(Gem::Version))
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
      expect_no_offenses("Settings.timeout = 1.0")
    end
  end
end
