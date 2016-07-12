source 'https://rubygems.org'

# Specify your gem's dependencies in likeno.gemspec
gemspec

# Active Support 5 drops Ruby < 2.2.2 support. We still want to support it, so
# manually add a maximum version bound for incompatible Ruby versions.
if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.2.2')
    gem 'activesupport', '< 5'
end
