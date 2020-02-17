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

require File.expand_path("~/.ruby_tools.rb")
