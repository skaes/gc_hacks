module GCHacks

  extend << self

  def logger
    @logger ||= defined?(Rails) ? Rails.logger : RAILS_DEFAULT_LOGGER
  end

  def root
    @root ||= defined?(Rails) ? Rails.root.to_s : RAILS_ROOT
  end

  def install_signal_handlers
    # WINCH is the only signal we can receive without mongrel/passenger side effects
    trap("WINCH"){ check_and_run_commands }
  end

  def send_command(cmd, pid)
    File.open(CMD_FILE, "w"){|f| f.puts cmd}
    Process.kill("WINCH", pid)
  end

  def check_and_run_commands
    read_command_file.each do |cmd|
      case cmd.chomp
      when 'HEAPDUMP'   then heap_dump
      when 'STARTTRACE' then start_trace
      when 'STOPTRACE'  then stop_trace
      else
        logger.info "unknown gc command: '#{cmd}'"
      end
    end
  ensure
    remove_command_file
  end

  CMD_FILE = File.expand_path("#{root}/tmp/gc_command.txt")

  def read_command_file
    File.exist?(CMD_FILE) ? File.read(CMD_FILE) : []
  end

  def remove_command_file
    File.exist?(CMD_FILE) && File.unlink(CMD_FILE)
  end

  def can_trace?
    GC.respond_to?(:log_file)
  end

  def can_dump?
    GC.respond_to?(:dump_file_and_line_info)
  end

  def log_dir
    @log_dir ||= File.expand_path("#{root}/log")
  end

  def log_dir=(dir)
    @log_dir = File.expand_path(dir)
  end

  def tmp_dir
    @tmp_dir ||= File.expand_path("#{root}/tmp")
  end

  def tmp_dir=(dir)
    @tmp_dir = File.expand_path(dir)
  end

  def start_trace
    unless can_trace?
      logger.info "cannot start GC trace. GC.enable_trace is undefined"
      return
    end
    GC.log_file "#{log_dir}/gctrace-#{Process.pid}.log" unless GC.log_file
    GC.enable_trace
    logger.info "GC-tracing: enabled"
  end

  def stop_trace
    unless can_trace?
      logger.info "cannot stop GC trace. GC.disable_trace is undefined"
      return
    end
    GC.disable_trace
    logger.info "GC-tracing: disabled"
  end

  def heap_dump
    unless can_dump?
      logger.info "cannot dump heap. GC.dump_file_and_line_info is undefined"
      return
    end
    @heap_dump_count ||= 0
    filename = "#{tmp_dir}/heap.#{Process.pid}.#{@heap_dump_count}.dump"
    msg = "** Dumping heap ..."
    $stderr.puts msg; logger.info msg
    GC.start;GC.start # two calls to get rid of finalizer created garbage
    GC.dump_file_and_line_info(filename, true)
    msg = "** Run 'railsbench analyze_heap_dump #{filename}' to analyze."
    $stderr.puts msg; logger.info msg
    @heap_dump_count += 1
  end

end
