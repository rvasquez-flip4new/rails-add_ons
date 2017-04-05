module Rails
  module AddOns
    class Engine < ::Rails::Engine
      isolate_namespace Rails::AddOns
    end
  end
end
