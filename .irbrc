begin
  require 'pry'
  Pry.start
  exit
rescue LoadError

# The following is derived from MacOSX /etc/irbrc
unless defined? HOME_IRBRC_LOADED
  require 'rubygems'
  require 'irb/completion'

  # Use the simple prompt.
  # IRB.conf[:PROMPT_MODE] = :SIMPLE if IRB.conf[:PROMPT_MODE] == :DEFAULT

  # Setup permanent history.
  HISTFILE = File.expand_path("~/.pry_history")
  MAXHISTSIZE = 10000
  begin
    if File.exists?(HISTFILE)
      lines = File.read(HISTFILE).lines.collect(&:chomp)
      puts "Read #{lines.length} saved history commands from '#{HISTFILE}'." if $VERBOSE
      Readline::HISTORY.push(*lines)
    else
      puts "History file '#{HISTFILE}' was empty or non-existant." if $VERBOSE
    end
    Kernel.at_exit do
      lines = Readline::HISTORY.to_a
      lines.pop if lines.last == "exit" || lines.last == "quit"
      lines = lines.reverse.uniq.reverse
      lines = lines[-MAXHISTSIZE, MAXHISTSIZE] if lines.length > MAXHISTSIZE
      puts "Saving #{lines.length} history lines to '#{HISTFILE}'." if $VERBOSE
      File.write(HISTFILE, lines.join("\n"))
    end
  rescue => e
    puts "Error when configuring permanent history: #{e}" if $VERBOSE
  end

  HOME_IRBRC_LOADED=true
end

end
