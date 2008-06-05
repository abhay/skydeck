require File.dirname(__FILE__) + '/../lib/skydeck'
require 'spec'

Spec::Runner.configure do |config|
  def s(*args)
    Sexp.new(*args)
  end
end