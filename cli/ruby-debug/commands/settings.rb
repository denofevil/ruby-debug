module Debugger
  class SetCommand < Command # :nodoc:
    self.control = true

    def regexp
      /^set \s+ (.+) \s*/x
    end

    def execute
      case @match[1]
      when /^(no)?autolist$/
        ListCommand.always_run = $1.nil?
        print "autolist is #{$1.nil? ? 'on' : 'off'}.\n"
      when /^(no)?autoeval$/
        EvalCommand.unknown = $1.nil?
        print "autoeval is #{$1.nil? ? 'on' : 'off'}.\n"
      when /^(no)?trace$/
        @@display_stack_trace = $1.nil?
        print "Displaying stack trace is #{$1.nil? ? 'on' : 'off'}.\n"
      when /^(no)?framefullpath$/
        @@full_file_names = $1.nil?
        print "Displaying frame's full file names is #{$1.nil? ? 'on' : 'off'}.\n"
      when /^(no)?frameclassname$/
        @@full_class_names = $1.nil?
        print "Displaying frame's original class name is #{$1.nil? ? 'on' : 'off'}.\n"
      when /^(no)?autoreload$/
        Debugger.reload_source_on_change = $1.nil?
        print "autoreload is #{$1.nil? ? 'on' : 'off'}.\n"
      when /^(no)?autoirb$/
        IRBCommand.always_run = $1.nil?
        print "autoirb is #{$1.nil? ? 'on' : 'off'}.\n"
      when /^(no)?forcestep$/
        @@force_stepping = $1.nil?
        print "force-stepping is #{$1.nil? ? 'on' : 'off'}.\n"
      else
        print "Unknown setting.\n"
      end
    end

    class << self
      def help_command
        "set"
      end

      def help(cmd)
        %{
           set <setting>, where <setting>:
           autolist       - execute 'list' command on every breakpoint
           autoeval       - evaluate every unrecognized command
           autoreload     - enables automatic source code reloading
           autoirb        - debugger invokes IRB on every stop
           trace          - display stack trace when 'eval' raises exception
           framefullpath  - frame will display full file names
           frameclassname - frame will display class names
           forcestep      - make sure 'next/step' commands always move to a new line
           To disable setting, use 'no' prefix, like 'noautolist'
         }
      end
    end
  end
end
