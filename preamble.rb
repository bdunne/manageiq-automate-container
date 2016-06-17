class AutomateMethodException < StandardError
end

begin
  require 'date'
  # require 'rubygems'
  # $:.unshift("#{Gem.loaded_specs['activesupport'].full_gem_path}/lib")
  # require 'active_support/all'
  require 'socket'
  Socket.do_not_reverse_lookup = true  # turn off reverse DNS resolution

  require 'drb'
  # require 'yaml'

  Time.zone = 'UTC'

  MIQ_OK    = 0
  MIQ_WARN  = 4
  MIQ_ERROR = 8
  MIQ_STOP  = 8
  MIQ_ABORT = 16

  DRbObject.send(:undef_method, :inspect)
  DRbObject.send(:undef_method, :id) if DRbObject.respond_to?(:id)

  DRb.start_service
  $evmdrb = DRbObject.new_with_uri("/drb_socket")
  raise AutomateMethodException,"Cannot create DRbObject for unix socket" if $evmdrb.nil?
  $evm = $evmdrb.find(ENV["MIQ_ID"])
  raise AutomateMethodException,"Cannot find Service" if $evm.nil?
  MIQ_ARGS = $evm.inputs
rescue Exception => err
  STDERR.puts('The following error occurred during inline method preamble evaluation:')
  STDERR.puts("  \#{err.class}: \#{err.message}")
  STDERR.puts("  \#{err.backtrace.join('\n')}") unless err.kind_of?(AutomateMethodException)
  raise
end

class Exception
  def backtrace_with_evm
    value = backtrace_without_evm
    value ? $evm.backtrace(value) : value
  end

  alias backtrace_without_evm backtrace
  alias backtrace backtrace_with_evm
end

begin

File.write("/output", $evm.inspect)

rescue Exception => err
  unless err.kind_of?(SystemExit)
    $evm.log('error', 'The following error occurred during method evaluation:')
    $evm.log('error', "  \#{err.class}: \#{err.message}")
    $evm.log('error', "  \#{err.backtrace[0..-2].join('\n')}")
  end
  raise
ensure
  $evm.disconnect_sql
end
