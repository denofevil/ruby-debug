module Debugger
  class SetCommand < Command # :nodoc:
    include ParseFunctions
    include ShowFunctions
    
    SubcmdStruct=Struct.new(:name, :min, :is_bool, :short_help)
    Subcommands = 
      [
       ['args', 2, false,
       "Set argument list to give program being debugged when it is started."],
       ['autoeval', 4, true,
        "Evaluate every unrecognized command"],
       ['autolist', 4, true,
        "Execute 'list' command on every breakpoint"],
       ['autoirb', 4, true,
        "Invoke IRB on every stop"],
       ['autoreload', 4, true,
        "Reload source code when changed"],
       ['forcestep', 2, true,
        "Make sure 'next/step' commands always move to a new line"],
       ['framefullpath', 2, true,
        "Display full file names in frames"],
       ['keep-frame-bindings', 1, true,
        "Save frame binding on each call"],
       ['linetrace', 3, true,
       "Set line execution tracing"],
       ['listsize', 3, false,
       "Set number of source lines to list by default"],
       ['trace', 1, true,
        "Display stack trace when 'eval' raises exception"],
       ['width', 1, false,
        "Number of characters the debugger thinks are in a line"],
      ].map do |name, min, is_bool, short_help| 
      SubcmdStruct.new(name, min, is_bool, short_help)
    end
    
    self.control = true

    def regexp
      /^set (?: \s+ (.*) )?$/ix
    end

    def execute
      if not @match[1]
        print "\"set\" must be followed by the name of an set command:\n"
        print "List of set subcommands:\n\n"
        for subcmd in Subcommands do
          print "set #{subcmd.name} -- #{subcmd.short_help}\n"
        end
      else
        args = @match[1].split(/[ \t]+/)
        subcmd = args.shift
        subcmd.downcase!
        if subcmd =~ /^no/i
          set_on = false
          subcmd = subcmd[2..-1]
        else
          set_on = true
        end
        for try_subcmd in Subcommands do
          if (subcmd.size >= try_subcmd.min) and
              (try_subcmd.name[0..subcmd.size-1] == subcmd)
            begin
              set_on = get_onoff(args) if try_subcmd.is_bool
              case try_subcmd.name
              when /^args$/
                Command.settings[:argv][1..-1] = args
              when /^autolist$/
                Command.settings[:autolist] = set_on
              when /^autoeval$/
                Command.settings[:autoeval] = set_on
              when /^trace$/
                Command.settings[:stack_trace_on_error] = set_on
              when /^framefullpath$/
                Command.settings[:frame_full_path] = set_on
              when /^frameclassname$/
                Command.settings[:frame_class_names] = set_on
              when /^autoreload$/
                Command.settings[:reload_source_on_change] = set_on
              when /^autoirb$/
                Command.settings[:autoirb] = set_on
              when /^forcestep$/
                self.class.settings[:force_stepping] = set_on
              when /^keep-frame-bindings$/
                Debugger.keep_frame_binding = set_on
              when /^linetrace$/
                Debugger.tracing = set_on
              when /^listsize$/
                listsize = get_int(args[0], "Set listsize", 1, nil, 10)
                if listsize
                  self.class.settings[:listsize] = listsize
                else
                  return
                end
              when /^width$/
                width = get_int(args[0], "Set width", 10, nil, 80)
                if width
                  self.class.settings[:width] = width
                  ENV['COLUMNS'] = width.to_s
                else
                  return
                end
              else
                print "Unknown setting #{@match[1]}.\n"
                return
              end
              print "%s\n" % show_setting(try_subcmd.name)
              return
            rescue RuntimeError
              return
            end
          end
        end
        print "Unknown set command #{subcmd}\n"
      end
    end

    class << self
      def help_command
        "set"
      end

      def help(cmd)
        s = "
Modifies parts of the ruby-debug environment. Boolean values take
on, off, 1 or 0.
You can see these environment settings with the \"show\" command.

-- 
List of set subcommands:
--  
"
        for subcmd in Subcommands do
          s += "set #{subcmd.name} -- #{subcmd.short_help}\n"
        end
        return s
      end
    end
  end
end
