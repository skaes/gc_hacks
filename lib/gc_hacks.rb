module GCHacks

  RAILS_ROOT = File.expand_path(File.dirname(__FILE__)+'/../../../..') unless defined? RAILS_ROOT

  def self.install_signal_handlers
    # WINCH is the only signal we can receive without mongrel/passenger side effects
    trap("WINCH"){ check_and_run_commands }
  end

  def self.send_command(cmd, pid)
    File.open(CMD_FILE, "w"){|f| f.puts cmd}
    Process.kill("WINCH", pid)
  end

  def self.check_and_run_commands
    read_command_file.each do |cmd|
      case cmd.chomp
      when 'HEAPDUMP' then heap_dump
      when 'STARTTRACE' then start_trace
      when 'STOPTRACE' then stop_trace
      else
        RAILS_DEFAULT_LOGGER.info "unknown gc command: '#{cmd}'"
      end
    end
  ensure
    remove_command_file
  end

  CMD_FILE = File.expand_path("#{RAILS_ROOT}/tmp/gc_command.txt")

  def self.read_command_file
    File.exist?(CMD_FILE) ? File.read(CMD_FILE) : []
  end

  def self.remove_command_file
    File.exist?(CMD_FILE) && File.unlink(CMD_FILE)
  end

  def self.can_trace?
    GC.respond_to?(:log_file)
  end

  def self.can_dump?
    GC.respond_to?(:dump_file_and_line_info)
  end

  def self.log_dir
    @log_dir ||= File.expand_path("#{RAILS_ROOT}/log")
  end

  def self.log_dir=(dir)
    @log_dir = File.expand_path(dir)
  end

  def self.tmp_dir
    @tmp_dir ||= File.expand_path("#{RAILS_ROOT}/tmp")
  end

  def self.tmp_dir=(dir)
    @tmp_dir = File.expand_path(dir)
  end

  def self.start_trace
    unless can_trace?
      RAILS_DEFAULT_LOGGER.info "cannot start GC trace. GC.enable_trace is undefined"
      return
    end
    GC.log_file "#{log_dir}/gctrace-#{Process.pid}.log" unless GC.log_file
    GC.enable_trace
    RAILS_DEFAULT_LOGGER.info "GC-tracing: enabled"
  end

  def self.stop_trace
    unless can_trace?
      RAILS_DEFAULT_LOGGER.info "cannot stop GC trace. GC.disable_trace is undefined"
      return
    end
    GC.disable_trace
    RAILS_DEFAULT_LOGGER.info "GC-tracing: disabled"
  end

  def self.heap_dump
    unless can_dump?
      RAILS_DEFAULT_LOGGER.info "cannot dump heap. GC.dump_file_and_line_info is undefined"
      return
    end
    @heap_dump_count ||= 0
    filename = "#{tmp_dir}/heap.#{Process.pid}.#{@heap_dump_count}.dump"
    msg = "** Dumping heap ..."
    $stderr.puts msg; RAILS_DEFAULT_LOGGER.info msg
    GC.start;GC.start # two calls to get rid of finalizer created garbage
    GC.dump_file_and_line_info(filename, true)
    msg = "** Run 'railsbench analyze_heap_dump #{filename}' to analyze."
    $stderr.puts msg; RAILS_DEFAULT_LOGGER.info msg
    @heap_dump_count += 1
  end

end
