module RubyTools
  def self.silence_warnings
    old_verbose, $VERBOSE = $VERBOSE, nil
    yield
  ensure
    $VERBOSE = old_verbose
  end

  module Formatter
    def self.pp(v, i = "", ignore_first_indent = false)
      require_without_bundler 'activesupport', 'active_support/core_ext/object/blank'

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

  module Profiler
    FLAMEGRAPH_EXE = File.expand_path("~/projects/external/FlameGraph/flamegraph.pl")

    def self.profile(file_prefix = "ruby_prof_profile")
      require_without_bundler "ruby-prof"
      data = RubyProf.profile { yield }
      dump(data, file_prefix)
    end

    def self.start
      require_without_bundler "ruby-prof"
      RubyProf.start
    end

    def self.stop(file_prefix = "ruby_prof_profile")
      data = RubyProf.stop
      dump(data, file_prefix)
    end

    def self.dump(data, file_prefix)
      base_path = defined?(Rails) ? Rails.root.join("tmp") : Pathname.new(Dir.pwd)
      base_path = base_path.join("ruby_prof_profile")
      FileUtils.mkdir_p(base_path)

      files = []

      file = base_path.join("#{file_prefix}_call_stack.html")
      File.open(file, "w") do |f|
        RubyProf::CallStackPrinter.new(data).print(f, :min_percent => 0.01, :min_time => 0.01, :print_file => true)
      end
      files << file

      file = base_path.join("#{file_prefix}_graph_html.html")
      File.open(file, "w") do |f|
        RubyProf::GraphHtmlPrinter.new(data).print(f, :min_percent => 0.01, :min_time => 0.01, :print_file => true)
      end
      files << file

      if FLAMEGRAPH_EXE.exist?
        have_gem =
          begin
            require_without_bundler 'ruby-prof-flamegraph'
            defined?(RubyProf::FlameGraphPrinter)
          rescue LoadError
            false
          end

        if have_gem
          Tempfile.open("flame_graph.out") do |f|
            RubyProf::FlameGraphPrinter.new(data).print(f, :min_percent => 0.01, :min_time => 0.01, :print_file => true)
            f.close

            file = base_path.join("#{file_prefix}_flame_graph.svg")
            `#{FLAMEGRAPH_EXE} --countname=ms '#{f.path}' > '#{file}'`
            files << file
          end
        end
      end

      files
    end

    def self.process_info(pid = Process.pid)
      h = nil
      begin
        h = process_list_linux("ps -p #{pid} -o pid,rss,vsize,%mem,%cpu,time,pri,ucomm", true)
      rescue
        raise Errno::ESRCH.new(pid.to_s)
      end
      h[pid]
    end

    def self.measure_memory
      3.times { GC.start }
      before = process_info[:memory_usage]
      3.times { GC.start }
      yield
    ensure
      return process_info[:memory_usage] - before
    end

    private

    def self.process_list_linux(cmd_str, skip_header = false)
      pl, i = {}, 0
      rc = `#{cmd_str}`
      rc.each_line do |ps_str|
        i += 1
        next if i == 1 && skip_header == true
        pinfo = ps_str.strip.split(' ')
        nh = parse_process_data(:linux, pinfo, perf = nil, os = nil)
        pl[nh[:pid]] = nh
        pl
      end
      pl
    end

    def self.parse_process_data(data_type, pinfo, perf = nil, os = nil)
      {
        :pid            => pinfo[0].to_i,
        :memory_usage   => pinfo[1].to_i * 1024,   # Memory in RAM
        :memory_size    => pinfo[2].to_i * 1024,   # Memory in RAM and swap
        :percent_memory => pinfo[3],
        :percent_cpu    => pinfo[4],
        :cpu_time       => str_time_to_sec(pinfo[5]),
        :priority       => pinfo[6],
        :name           => pinfo[7..-1].join(' '),
      }
    end

    def self.str_time_to_sec(time_str)
      # Convert format 00:00:00 to seconds
      t = time_str.split(':')
      (t[0].to_i * 3600) + (t[1].to_i * 60) + t[2].to_i
    end
  end

  module Debundle
    def self.require_without_bundler(gem_name, require_path = gem_name)
      begin
        gem gem_name
      rescue Gem::LoadError => e
        if e.message.include?("is not part of the bundle")
          debundle!
          retry
        end
        raise
      end

      require require_path
    end

    # Taken from https://github.com/janlelis/debundle.rb/blob/06cf36de53c5900a4a22c697a4604d59482762e2/debundle.rb
    def self.debundle!
      if Gem.post_reset_hooks.reject!{ |hook| hook.source_location.first =~ %r{/bundler/} }
        Bundler.preserve_gem_path if Bundler::VERSION < "1.12"
        Gem.clear_paths
        RubyTools.silence_warnings { load 'rubygems/core_ext/kernel_require.rb' }
        load 'rubygems/core_ext/kernel_gem.rb'
      end
    end
  end

  module ManageIQ
    def self.seed
      Zone.seed if Zone.default_zone.nil?
      MiqServer.seed if MiqServer.my_server.nil?
    end

    def self.ems_create(*args)
      if args.empty?
        puts "You must specify args:"
        puts "  :klass, :username, :password, :hostname, :ipaddress"
        puts "or a registry key:"
        puts "  #{ems_registry.keys.sort.map(&:inspect).join(", ")}"
        return false
      end

      if args.size == 1 && args[0].is_a?(String)
        ems_create_from_registry(*args)
      else
        ems_create_direct(*args)
      end
    end

    def self.ems_registry
      YAML.load_file(File.expand_path("~/.fryguy_ems_registry.yml")) rescue {}
    end

    private_class_method def self.ems_create_from_registry(name)
      args = ems_registry.fetch(name)
      ems_create_direct(args)
    end

    private_class_method def self.ems_create_direct(klass:, username:, password:, hostname: nil, ipaddress: nil, verify_ssl: 0)
      seed

      klass = Object.const_get(klass) if klass.is_a?(String)
      ems = klass.find_by(:name => hostname)
      ems ||= begin
        create_args = {
          :name       => hostname,
          :hostname   => hostname,
          :ipaddress  => ipaddress,
          :verify_ssl => verify_ssl,
          :zone       => Zone.default_zone
        }.compact
        klass.create!(create_args)
      end
      ems.update_authentication(:default => {:userid => username, :password => password})

      EmsRefresh.refresh(ems)
    end
  end
end

def format_object(*args)
  RubyTools::Formatter.pp(*args)
end

def ruby_prof_profile(*args)
  RubyTools::Profiler.profile(*args) { yield }
end

def require_without_bundler(*args)
  RubyTools::Debundle.require_without_bundler(*args)
end

def ems_create(*args)
  RubyTools::ManageIQ.ems_create(*args)
end

def ems_registry
  RubyTools::ManageIQ.ems_registry
end

def decrypt_string(s, base)
  s.split.map { |c| c.to_i(base).chr }.join
end

def decrypt_octal(s)
  decrypt_string(s, 8)
end
