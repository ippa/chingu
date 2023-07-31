
require_relative 'lib/chingu/version'

Gem::Specification.new do |s|
  s.name = 'chingu'
  s.version = Chingu::VERSION
  s.authors = ['ippa']
  s.email = 'ippa@rubylicio.us'
  s.homepage = 'http://ippa.se/chingu'
  s.description = <<~DESC
                     OpenGL accelerated 2D game framework for Ruby. Builds on
                     Gosu (Ruby/C++) which provides all the core functionality.
                     Chingu adds simple yet powerful game states, prettier
                     input handling, deployment safe asset-handling, a basic
                     re-usable game object and stackable game logic.
                  DESC
  s.summary = 'OpenGL accelerated 2D game framework for Ruby.'

  s.required_ruby_version = '>= 2.5.0'

  s.files = Dir.glob('{lib, examples, benchmarks, spec}/**/*') + %w(LICENSE README.md Rakefile)
  s.extra_rdoc_files = ['LICENSE', 'README.md']
  s.require_paths = ['lib']
  s.license = 'LGPL-2.1'

  s.add_runtime_dependency('gosu', ['~> 1.4.0'])
  s.add_development_dependency('rspec', ['~> 2.1.0'])
  s.add_development_dependency('rubocop', ['~> 1.50'])
end
