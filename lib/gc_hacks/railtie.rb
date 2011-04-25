module GCHacks
  class Railtie < Rails::Railtie

    initializer "gc_hacks" do
      require File.expand_path('../../../init.rb', __FILE__)
    end

  end
end
