if defined?(PhusionPassenger)
  if PhusionPassenger::VERSION_STRING < '4.0'
    class PhusionPassenger::AbstractRequestHandler
      alias_method :original_reset_signal_handlers, :reset_signal_handlers

      def reset_signal_handlers
        original_reset_signal_handlers
        GCHacks.install_signal_handlers
      end

      protected :original_reset_signal_handlers, :reset_signal_handlers
    end
  else
    PhusionPassenger.on_event(:after_installing_signal_handlers) do
      GCHacks.install_signal_handlers
    end
  end

else
  GCHacks.install_signal_handlers
end
