require "pry"

Pry.config.theme_options = {:paint_key_as_symbol => true}
Pry.config.theme = "twilight"

PRY_FILTER = %r{/(?:gems/(?:pry|pry-byebug|irb)-\d|lib/ruby/\d\.\d\.\d/irb|bin/irb|.irbrc)}.freeze
Pry.config.exception_handler = proc do |output, exception, _|
  filter_paths =  Gem.path.map { |gem_path| File.join(gem_path, "gems") } # Gem paths
  filter_paths << File.dirname(RbConfig::CONFIG["prefix"]) # Ruby path

  lines = exception.full_message.lines.each_with_object([]) do |line, arr|
    next if line.match?(PRY_FILTER)

    # Shorten gem and Ruby paths
    # if path = filter_paths.find { |path| line.include?(path) }
    #   line.sub!(%r{#{path}/(.+?)/}, '(\1) ')
    # end
    line.sub!(ENV["HOME"], "~") if ENV["HOME"]

    arr << line
  end

  output.print lines.join
end

if defined?(Rails) && Rails.env
  extend Rails::ConsoleMethods
end

require File.expand_path("~/.ruby_tools.rb")
