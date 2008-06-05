require 'rubygems'
require 'thor/tasks'

class Default < Thor
  spec_task Dir["spec/**/*_spec.rb"]
  
  desc "console", "Start a console with the library for testing"
  def console
     exec "irb -rubygems -r ./lib/skydeck.rb"
  end
end