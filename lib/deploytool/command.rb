require 'deploytool/version'

class DeployTool::Command
  COMMANDS = ["to", "logs", "import", "export", "config", "run"]
  
  def self.print_help
      puts "Deploytool Version #{DeployTool::VERSION} Usage Instructions"
      puts ""
      puts "Add a target:"
      puts "  deploy add production young-samurai-4@example.org"
      puts "  deploy add staging green-flower-2@example.org"
      puts ""
      puts "Deploy the current directory to the target:"
      puts "  deploy production"
      puts ""
      puts "Run a command on the server:"
      puts "  deploy run production rake db:migrate"
  end

  def self.find_target(target_name)
    unless (target = DeployTool::Config[target_name]) && !target.nil? && target.size > 0
      puts "ERROR: Target \"#{target_name}\" is not configured"
      puts ""
      print_help
      exit
    end
    [target_name, DeployTool::Target.from_config(target)]
  end

  def self.handle_target_exception(e)
    $logger.debug e.inspect
    $logger.debug e.backtrace
    $logger.info "\nAn Error (%s) occured. Please contact %s support: %s" % [e.inspect, DeployTool::Target::HostingStack.cloud_name, DeployTool::Target::HostingStack.support_email]
    exit 2
  end

  def self.run(command, args)
    if args.include?("--debug")
      args.delete("--debug")
      $logger.level = Logger::DEBUG
    elsif args.include?("-d")
      args.delete("-d")
      $logger.level = Logger::DEBUG
    elsif args.include?("-v")
      args.delete("-v")
      $logger.level = Logger::DEBUG
    else
      $logger.level = Logger::INFO
    end

    change_to_toplevel_dir!

    DeployTool::Config.load(".deployrc")
    
    if command == "help"
      print_help
    elsif command == "add"
      if args[0].nil?
        puts "ERROR: Missing target name."
        puts ""
        puts "Use \"deploy help\" if you're lost."
        exit
      end
      if args[1].nil?
        puts "ERROR: Missing target specification."
        puts ""
        puts "Use \"deploy help\" if you're lost."
        exit
      end
      unless target = DeployTool::Target.find(args[1])
        puts "ERROR: Couldn't find provider for target \"#{args[1]}\""
        puts ""
        puts "Use \"deploy help\" if you're lost."
        exit
      end
      if target.respond_to?(:verify)
        target.verify
      end
      DeployTool::Config[args[0]] = target.to_h
    elsif command == "list"
      puts "Registered Targets:"
      DeployTool::Config.all.each do |target_name, target|
        target = DeployTool::Target.from_config(target)
        puts "  %s%s" % [target_name.ljust(15), target.to_s]
      end
    elsif command == "run"
      target_name, target = find_target args.shift
      begin
        command = args.join(' ').strip
        if command.empty?
          puts "ERROR: Must specify command to be run.\n\n"
          print_help
          exit 2
        end
        target.exec(command)
      rescue => e
        handle_target_exception e
      end
    else
      args.unshift command unless command == "to"
      target_name, target = find_target args.shift
      
      opts = {}
      opts[:timing] = true if args.include?("--timing")

      begin
        target.push(opts)
      rescue => e
        handle_target_exception e
      end
    end

    if target_name and target
      DeployTool::Config[target_name] = target.to_h
    end

    DeployTool::Config.save
  rescue Net::HTTPServerException => e
    $logger.info "ERROR: HTTP call returned %s %s" % [e.response.code, e.response.message]
    if target
      $logger.debug "\nTarget:"
      target.to_h.each do |k, v|
        next if k.to_sym == :password
        $logger.debug "  %s = %s" % [k, v]
      end
    end
    $logger.debug "\nBacktrace:"
    $logger.debug "  " + e.backtrace.join("\n  ")
    $logger.debug "\nResponse:"
    e.response.each_header do |k, v|
      $logger.debug "  %s: %s" % [k, v]
    end
    $logger.debug "\n  " + e.response.body.gsub("\n", "\n  ")
    $logger.info "\nPlease run again with \"--debug\" and report the output at http://bit.ly/deploytool-new-issue"
    exit 2
  end
  
  # Tries to figure out if we're running in a subdirectory of the source,
  # and switches to the top-level if that's the case
  def self.change_to_toplevel_dir!
    indicators = [".git", "Gemfile", "LICENSE", "test"]
    
    timeout = 10
    path = Dir.pwd
    begin
      indicators.each do |indicator|
        next unless File.exists?(File.join(path, indicator))
        
        $logger.debug "Found correct top-level directory %s, switching working directory." % [path] unless path == Dir.pwd
        Dir.chdir path
        return
      end
    end until (path = File.dirname(path)) == "/" || (timeout -= 1) == 0

    $logger.debug "DEBUG: Couldn't locate top-level directory (traversed until %s), falling back to %s" % [path, Dir.pwd]
  end
end
