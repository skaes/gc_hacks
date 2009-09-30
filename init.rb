if defined?(PhusionPassenger)
  class PhusionPassenger::AbstractRequestHandler
    alias_method :original_reset_signal_handlers, :reset_signal_handlers

    def reset_signal_handlers
      original_reset_signal_handlers
      GCHacks.install_signal_handlers
    end

    protected :original_reset_signal_handlers, :reset_signal_handlers
  end

else
  GCHacks.install_signal_handlers
end



