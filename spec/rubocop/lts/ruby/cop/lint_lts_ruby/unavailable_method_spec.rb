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

  context "with the standard library APIs cataloged from Ruby NEWS" do
    let(:ruby_version) { 1.9 }

    it "reports newly cataloged instance APIs" do
      {
        "Date#jisx0301" => ["date.jisx0301", "jisx0301"],
        "FileUtils#cp_lr" => ["file_utils.cp_lr(source, destination)", "cp_lr"],
        "IO#cooked" => ["io.cooked", "cooked"],
        "IO#cooked!" => ["io.cooked!", "cooked!"],
        "IO#pathconf" => ["io.pathconf(name)", "pathconf"],
        "IO#wait_readable" => ["io.wait_readable", "wait_readable"],
        "IO#wait_writable" => ["io.wait_writable", "wait_writable"],
        "Matrix#adjugate" => ["matrix.adjugate", "adjugate"],
        "Matrix#antisymmetric?" => ["matrix.antisymmetric?", "antisymmetric?"],
        "Matrix#cofactor" => ["matrix.cofactor(row, column)", "cofactor"],
        "Matrix#first_minor" => ["matrix.first_minor(row, column)", "first_minor"],
        "Matrix#hstack" => ["matrix.hstack(other_matrix)", "hstack"],
        "Matrix#independent?" => ["matrix.independent?", "independent?"],
        "Matrix#laplace_expansion" => ["matrix.laplace_expansion(row_or_column: 0)", "laplace_expansion"],
        "Matrix/Vector#map!" => ["matrix.map! { |value| value }", "map!"],
        "Matrix#skew_symmetric?" => ["matrix.skew_symmetric?", "skew_symmetric?"],
        "Matrix#vstack" => ["matrix.vstack(other_matrix)", "vstack"],
        "Net::FTP#features" => ["ftp.features", "features"],
        "Net::FTP#option" => ["ftp.option(:name)", "option"],
        "Net::HTTP#local_host" => ["http.local_host", "local_host"],
        "Net::HTTP#local_port" => ["http.local_port", "local_port"],
        "Net::SMTP#rset" => ["smtp.rset", "rset"],
        "OpenStruct#each_pair" => ["object.each_pair { |key, value| [key, value] }", "each_pair"],
        "OpenStruct#eql?" => ["object.eql?(other)", "eql?"],
        "OpenStruct#hash" => ["object.hash", "hash"],
        "File/File::Stat/Pathname#birthtime" => ["path.birthtime", "birthtime"],
        "Pathname#binwrite" => ["path.binwrite(contents)", "binwrite"],
        "Pathname#write" => ["path.write(contents)", "write"],
        "Resolv::DNS#timeouts=" => ["dns.timeouts = values", "timeouts"],
        "Ripper#state" => ["ripper.state", "state"],
        "Method/Set#===" => ["set.=== value", "==="],
        "Set#reset" => ["set.reset", "reset"],
        "Set#to_s" => ["set.to_s", "to_s"],
        "StringScanner#captures" => ["scanner.captures", "captures"],
        "StringScanner#values_at" => ["scanner.values_at(0)", "values_at"],
        "Vector#angle_with" => ["vector.angle_with(other_vector)", "angle_with"],
        "Matrix/Vector#collect!" => ["vector.collect! { |value| value }", "collect!"],
        "Vector#cross" => ["vector.cross(other_vector)", "cross"],
        "Vector#cross_product" => ["vector.cross_product(other_vector)", "cross_product"],
        "Vector#dot" => ["vector.dot(other_vector)", "dot"],
        "Vector#round" => ["vector.round", "round"]
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
        expect_offense(<<~RUBY)
          scanner.size
                  ^^^^ StringScanner#size is unavailable before Ruby 2.5.
        RUBY
      end
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
