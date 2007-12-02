module Debugger
  module VarFunctions # :nodoc:
    def var_list(ary, b = get_binding)
      ary.sort!
      for v in ary
        s = debug_eval(v, b).inspect
        if s.size > self.class.settings[:width]
          s[self.class.settings[:width]-3 .. -1] = "..."
        end
        print "%s = %s\n", v, s
      end
    end
  end

  class VarConstantCommand < Command # :nodoc:
    def regexp
      /^\s*v(?:ar)?\s+c(?:onst(?:ant)?)?\s+/
    end

    def execute
      obj = debug_eval(@match.post_match)
      unless obj.kind_of? Module
        print "Should be Class/Module: %s\n", @match.post_match
      else
        constants = debug_eval("#{@match.post_match}.constants")
        constants.sort!
        for c in constants
          next if c =~ /SCRIPT/
          value = obj.const_get(c) rescue "ERROR: #{$!}"
          print " %s => %p\n", c, value
        end
      end
    end

    class << self
      def help_command
        'var'
      end

      def help(cmd)
        %{
          v[ar] c[onst] <object>\t\tshow constants of object
        }
      end
    end
  end

  class VarGlobalCommand < Command # :nodoc:
    def regexp
      /^\s*v(?:ar)?\s+g(?:lobal)?\s*$/
    end

    def execute
      var_list(global_variables)
    end

    class << self
      def help_command
        'var'
      end

      def help(cmd)
        %{
          v[ar] g[lobal]\t\t\tshow global variables
        }
      end
    end
  end

  class VarInstanceCommand < Command # :nodoc:
    def regexp
      /^\s*v(?:ar)?\s+i(?:nstance)?\s*/
    end

    def execute
      obj = debug_eval(@match.post_match.empty? ? 'self' : @match.post_match)
      var_list(obj.instance_variables, obj.instance_eval{binding()})
    end

    class << self
      def help_command
        'var'
      end

      def help(cmd)
        %{
          v[ar] i[nstance] <object>\tshow instance variables of object
        }
      end
    end
  end

  class VarLocalCommand < Command # :nodoc:
    def regexp
      /^\s*v(?:ar)?\s+l(?:ocal)?\s*$/
    end

    def execute
      locals = @state.context.frame_locals(@state.frame_pos)
      _self = @state.context.frame_self(@state.frame_pos) 
      locals.keys.sort.each do |name|
        print "  %s => %p\n", name, locals[name]
      end
    end

    class << self
      def help_command
        'var'
      end

      def help(cmd)
        %{
          v[ar] l[ocal]\t\t\tshow local variables
        }
      end
    end
  end
end
