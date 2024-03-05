#ensure_gem "dead_end"
#ensure_gem "stackprof"
#ensure_gem "rubyprof"
#ensure_gem "rubyprof-flamegraph"

if RUBY_VERSION >= "3.1.0"
  ensure_gem "reline", ">= 0.3.7"
end

if RUBY_VERSION < "3.1"
  ensure_gem "pry", "~> 0.13.x", "< 0.14"
  ensure_gem "pry-byebug"
  ensure_gem "pry-doc"
  ensure_gem "pry-rails"
  ensure_gem "pry-theme"
end

ensure_gem "syntax_suggest"
