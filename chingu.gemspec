# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{chingu}
  s.version = "0.4.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["ippa"]
  s.date = %q{2009-08-19}
  s.description = %q{Game framework built on top of the OpenGL accelerated game lib Gosu.  It adds simple yet powerfull game states, prettier inputhandling, deploymentsafe asset-handling, a basic re-usable game object and automation of common task.}
  s.email = ["ippa@rubylicio.us"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.rdoc", "Rakefile", "chingu.gemspec", "examples/example1.rb", "examples/example2.rb", "examples/example3.rb", "examples/example4.rb", "examples/media/Parallax-scroll-example-layer-0.png", "examples/media/Parallax-scroll-example-layer-1.png", "examples/media/Parallax-scroll-example-layer-2.png", "examples/media/Parallax-scroll-example-layer-3.png", "examples/media/background1.png", "examples/media/fire_bullet.png", "examples/media/spaceship.png", "examples/media/stickfigure.bmp", "examples/media/stickfigure.png", "lib/chingu.rb", "lib/chingu/animation.rb", "lib/chingu/assets.rb", "lib/chingu/chipmunk_object.rb", "lib/chingu/data_structures.rb", "lib/chingu/fpscounter.rb", "lib/chingu/game_object.rb", "lib/chingu/game_state.rb", "lib/chingu/game_state_manager.rb", "lib/chingu/helpers.rb", "lib/chingu/input.rb", "lib/chingu/named_resource.rb", "lib/chingu/parallax.rb", "lib/chingu/rect.rb", "lib/chingu/text.rb", "lib/chingu/window.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/ippa/chingu/tree/master}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{chingu}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Game framework built on top of the OpenGL accelerated game lib Gosu}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe>, [">= 2.3.3"])
    else
      s.add_dependency(%q<hoe>, [">= 2.3.3"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 2.3.3"])
  end
end
