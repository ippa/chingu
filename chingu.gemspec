# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{chingu}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["ippa"]
  s.cert_chain = ["/Documents and Settings/erik/.gem/gem-public_cert.pem"]
  s.date = %q{2009-08-07}
  s.description = %q{Game framework built on top of the opengl accelerated gamelib Gosu. "Chingu" means "Friend" in korean.}
  s.email = ["ippa@rubylicio.us"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt"]
  s.files = ["History.txt", "Manifest.txt", "README.rdoc", "Rakefile", "chingu.gemspec", "examples/example1.rb", "examples/example2.rb", "examples/example3.rb", "examples/media/Parallax-scroll-example-layer-0.png", "examples/media/Parallax-scroll-example-layer-1.png", "examples/media/Parallax-scroll-example-layer-2.png", "examples/media/Parallax-scroll-example-layer-3.png", "examples/media/background1.png", "examples/media/fire_bullet.png", "examples/media/spaceship.png", "examples/media/stickfigure.bmp", "examples/media/stickfigure.png", "lib/chingu.rb", "lib/chingu/actor.rb", "lib/chingu/advanced_actor.rb", "lib/chingu/animation.rb", "lib/chingu/assets.rb", "lib/chingu/data_structures.rb", "lib/chingu/fpscounter.rb", "lib/chingu/keymap.rb", "lib/chingu/named_resource.rb", "lib/chingu/paralaxx.rb", "lib/chingu/rect.rb", "lib/chingu/window.rb"]
  s.has_rdoc = true
  s.homepage = %q{SOURCE: http://github.com/ippa/chingu/tree/master}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{chingu}
  s.rubygems_version = %q{1.3.1}
  s.signing_key = %q{/Documents and Settings/erik/.gem/gem-private_key.pem}
  s.summary = %q{Game framework built on top of the opengl accelerated gamelib Gosu}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe>, [">= 2.3.2"])
    else
      s.add_dependency(%q<hoe>, [">= 2.3.2"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 2.3.2"])
  end
end
