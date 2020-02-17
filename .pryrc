require "pry"

Pry.config.theme_options = {:paint_key_as_symbol => true}
Pry.config.theme = "twilight"

Pry.config.exception_handler = proc do |output, exception, _|
  filter_paths =  Gem.path.map { |gem_path| File.join(gem_path, "gems") } # Gem paths
  filter_paths << File.dirname(RbConfig::CONFIG["prefix"]) # Ruby path

  lines = exception.full_message.lines
  reversed = lines[0]&.include?("Traceback")
  iter = reversed ? :reverse_each : :each

  saw_pry = nil
  lines = lines.send(iter).with_object([]) do |line, arr|
    # Shorten gem and Ruby paths
    #if path = filter_paths.find { |path| line.include?(path) }
    #  line.sub!(%r{#{path}/(.+?)/}, '(\1) ')
    #end
    line.sub!(ENV["HOME"], "~")

    # Suppress everything after the line: in `<main>'
    #next if saw_pry || (saw_pry = line =~ /in `<main>'$/)

    arr << line
  end

  lines.reverse! if reversed
  output.print lines.join
end

if defined?(Rails) && Rails.env
  extend Rails::ConsoleMethods
end

module FryguyFormatter
  def self.pp(v, i = "", ignore_first_indent = false)
    if v.kind_of?(Array)
      pp_array(v, i, ignore_first_indent)
    elsif v.kind_of?(Hash)
      pp_hash(v, i, ignore_first_indent)
    else
      pp_other(v, i, ignore_first_indent)
    end
  end

  private

  def self.pp_hash(h, i, ignore_first_indent = false)
    return "{}" if h.blank?
    str = ignore_first_indent ? "" : i.dup
    str << "{\n"
    new_i = "#{i}  "
    if h.values.none? { |v| v.kind_of?(Hash) || v.kind_of?(Array) }
      key_max_size =  h.keys.collect { |k| k.inspect.size }.max
    end
    h.each { |k, v| str << "#{new_i}#{k.inspect}#{" " * (key_max_size - k.inspect.size) if key_max_size} => #{pp(v, new_i, true)},\n" }
    str << "#{i}}"
  end

  def self.pp_array(a, i, ignore_first_indent = false)
    return "[]" if a.blank?
    str = ignore_first_indent ? "" : i.dup
    str << "[\n"
    new_i = "#{i}  "
    a.each { |v| str << "#{new_i}#{pp(v, new_i, true)},\n" }
    str << "#{i}]"
  end

  def self.pp_other(v, i, ignore_first_indent = false)
    str = ignore_first_indent ? "" : i.dup
    str << v.inspect
  end
end

def format_object(o)
  FryguyFormatter.pp(o)
end

module FryguyRubyProf
  def self.profile(filename = "ruby_prof_profile.html")
    require 'ruby-prof'
    data = RubyProf.profile { yield }
    dump(data, filename)
  end

  def self.dump(data, filename = "ruby_prof_profile.html")
    base_path = defined?(Rails) ? Rails.root.join("tmp") : Pathname.new(Dir.pwd)
    base_path = base_path.join("ruby_prof_profile")
    FileUtils.mkdir_p(base_path)

    files = []

    file = base_path.join(filename.sub(".html", "_call_stack.html"))
    File.open(file, "w") do |f|
      RubyProf::CallStackPrinter.new(data).print(f, :min_percent => 0, :print_file => true)
    end
    files << file

    file = base_path.join(filename.sub(".html", "_graph_html.html"))
    File.open(file, "w") do |f|
      RubyProf::GraphHtmlPrinter.new(data).print(f, :min_percent => 0, :print_file => true)
    end
    files << file

    if defined?(RubyProf::FlameGraphPrinter)
      file = base_path.join(filename.sub(".html", "_flame_graph.out"))
      File.open(file, "w") do |f|
        RubyProf::FlameGraphPrinter.new(data).print(f, :min_percent => 0, :print_file => true)
      end

      file2 = base_path.join(filename.sub(".html", "_flame_graph.svg"))
      `~/projects/external/FlameGraph/flamegraph.pl --countname=ms #{file} > #{file2}`
      files << file2
    end

    files
  end
end

def ruby_prof_profile(filename = "ruby_prof_profile.html")
  FryguyRubyProf.profile { yield }
end
