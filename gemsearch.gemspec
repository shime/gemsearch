
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "gemsearch/version"

Gem::Specification.new do |spec|
  spec.name          = "gemsearch"
  spec.version       = Gemsearch::VERSION
  spec.authors       = ["Hrvoje Šimić"]
  spec.email         = ["shime@twobucks.co"]

  spec.summary       = %q{A CLI tool for searching Ruby gems.}
  spec.homepage      = "https://github.com/shime/gemsearch"
  spec.license       = "MIT"

  spec.required_ruby_version = '>= 2.0'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "tty-prompt", "~> 0.16"
  spec.add_dependency "tty-spinner", "~> 0.8"
  spec.add_dependency "humanize-number", "~> 0.3"
  spec.add_dependency "bun", "~> 1.2"

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "pry", "~> 0.11.3"
end
