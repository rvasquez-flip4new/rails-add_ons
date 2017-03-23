$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rails/add_ons/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rails-add_ons"
  s.version     = Rails::AddOns::VERSION
  s.authors     = ["Roberto Vasquez Angel"]
  s.email       = ["roberto@vasquez-angel.de"]
  s.summary     = "Rails Add Ons."
  s.description = "The missing bits."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0.2"

  s.add_development_dependency "sqlite3"
  
  s.add_dependency "haml-rails"
  s.add_dependency "font-awesome-rails"
  s.add_dependency "simple_form"
  s.add_dependency "responders"
  s.add_dependency "rails-i18n"
  s.add_dependency "resource_renderer"
end
