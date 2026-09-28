# frozen_string_literal: true

require "spec_helper"

RSpec.describe RuboCop::Cop::Lint::LtsRuby::UnavailableMethod, :config do
  let(:ruby_version) { 2.0 }
  let(:cop_config) { {"Enabled" => true, "AllowedMethods" => []} }

  it "registers an offense for an API introduced after the target Ruby" do
    expect_offense(<<~RUBY)
      Enumerable.new.filter_map { |value| value }
                     ^^^^^^^^^^ Enumerable#filter_map is unavailable before Ruby 2.7.
    RUBY
  end

  it "reports the instance APIs in the catalog" do
    expect_offense(<<~RUBY)
      Array.new.prepend(value)
                ^^^^^^^ Array#prepend is unavailable before Ruby 2.5.
    RUBY
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

  context "with the standard library APIs cataloged from Ruby NEWS" do
    let(:ruby_version) { 1.9 }

    it "reports newly cataloged instance APIs" do
      expect_offense(<<~RUBY)
        Set.new.to_s
                ^^^^ Set#to_s is unavailable before Ruby 2.5.
      RUBY
    end

    it "reports newly cataloged constant APIs" do
      {
        "Coverage#peek_result" => ["Coverage.peek_result", "peek_result"],
        "Coverage#line_stub" => ["Coverage.line_stub", "line_stub"],
        "Coverage#supported?" => ["Coverage.supported?", "supported?"],
        "ENV#except" => ["ENV.except(:HOME)", "except"],
        "ERB::Escape#html_escape" => ["ERB::Escape.html_escape(value)", "html_escape"],
        "Etc#confstr" => ["Etc.confstr(name)", "confstr"],
        "Etc#nprocessors" => ["Etc.nprocessors", "nprocessors"],
        "Etc#sysconf" => ["Etc.sysconf(name)", "sysconf"],
        "Etc#uname" => ["Etc.uname", "uname"],
        "FileUtils#cp_lr" => ["FileUtils.cp_lr(source, destination)", "cp_lr"],
        "Matrix#hstack" => ["Matrix.hstack(matrix)", "hstack"],
        "Matrix#independent?" => ["Matrix.independent?(matrix)", "independent?"],
        "Matrix#vstack" => ["Matrix.vstack(matrix)", "vstack"],
        "Net::IMAP#default_port" => ["Net::IMAP.default_port", "default_port"],
        "Net::IMAP#default_imap_port" => ["Net::IMAP.default_imap_port", "default_imap_port"],
        "Net::IMAP#default_tls_port" => ["Net::IMAP.default_tls_port", "default_tls_port"],
        "Net::IMAP#default_ssl_port" => ["Net::IMAP.default_ssl_port", "default_ssl_port"],
        "Net::IMAP#default_imaps_port" => ["Net::IMAP.default_imaps_port", "default_imaps_port"],
        "ObjectSpace#reachable_objects_from" => ["ObjectSpace.reachable_objects_from(object)", "reachable_objects_from"],
        "Readline#quoting_detection_proc" => ["Readline.quoting_detection_proc", "quoting_detection_proc"],
        "Readline#quoting_detection_proc=" => ["Readline.quoting_detection_proc=(proc {})", "quoting_detection_proc"],
        "SecureRandom#alphanumeric" => ["SecureRandom.alphanumeric(8)", "alphanumeric"],
        "Vector#basis" => ["Vector.basis(3, 0)", "basis"],
        "Zlib#gzip" => ["Zlib.gzip(value)", "gzip"],
        "Zlib#gunzip" => ["Zlib.gunzip(value)", "gunzip"]
      }.each do |api, (source, selector)|
        entry = RuboCop::Lts::Ruby::Catalog::ENTRIES.find { |candidate| "#{candidate.owner}##{candidate.method_name}" == api } ||
          RuboCop::Lts::Ruby::Catalog::ENTRIES.find { |candidate| candidate.method_name.to_s == selector }
        introduced_in = entry.introduced_in
        marker = " " * source.rindex(selector) + "^" * selector.length

        expect_offense(<<~RUBY)
          #{source}
          #{marker} #{api} is unavailable before Ruby #{introduced_in}.
        RUBY
      end
    end

    context "when an older API shares a method name" do
      let(:ruby_version) { 2.4 }

      it "still reports the newer standard library API" do
        expect_no_offenses("scanner.size")
      end
    end
  end

  it "does not guess the owner of a local receiver" do
    expect_no_offenses("callable.public?")
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
      expect_no_offenses("Hash.new.except(:key)")
    end
  end

  it "does not report an implicit receiver" do
    expect_no_offenses("filter_map { |value| value }")
  end

  it "does not guess the owner of an untyped local receiver" do
    expect_no_offenses("values.filter_map { |value| value }")
    expect_no_offenses("scanner.size")
    expect_no_offenses("hash.fetch(:key)")
  end

  context "with a constructor-only instance API" do
    let(:ruby_version) { 3.2 }

    it "reports a directly constructed WeakMap" do
      expect_offense(<<~RUBY)
        ObjectSpace::WeakMap.new.delete(key)
                                 ^^^^^^ ObjectSpace::WeakMap#delete is unavailable before Ruby 3.3.
      RUBY
    end

    it "does not infer a WeakMap from an arbitrary local receiver" do
      expect_no_offenses("values.delete(key)")
    end
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
      expect_no_offenses("Enumerable.new.filter_map { |value| value }")
    end
  end

  it "does not apply an API to a different constructed owner" do
    expect_no_offenses("Object.new.filter_map { |value| value }")
  end

  context "with a non-owning constant receiver" do
    let(:ruby_version) { 3.1 }

    it "does not report a singleton API by method name alone" do
      expect_no_offenses("Settings.timeout = 1.0")
    end
  end
end
