module ORI
  # Simplistic ANSI colorizer.
  module Colorize   #:nodoc:
    # Issue an ANSI color sequence.
    #
    #   puts [Colorize.seq(:message, :error), "Error!", Colorize.seq(:reset)].join
    def self.seq(*spec)
      Tools.ansi(*case spec
        when [:choice, :title]
          [:green]
        when [:choice, :index]
          [:yellow, :bold]
        when [:choice, :label]
          [:cyan]
        when [:choice, :prompt]
          [:yellow, :bold]

        # These go in sequence, each knows who's before. Thus we minimize ANSI.
        when [:list_method, :own_marker]
          [:reset, :bold]
        when [:list_method, :not_own_marker]
          [:reset]
        when [:list_method, :obj_module_name]
          [:cyan, :bold]
        when [:list_method, :owner_name]
          [:reset]
        when [:list_method, :access]
          [:reset, :cyan]
        when [:list_method, :name]
          [:reset, :bold]
        when [:list_method, :visibility]
          [:reset, :yellow]

        # These go in sequence.
        when [:mam, :module_name]
          [:cyan, :bold]
        when [:mam, :access]
          [:reset, :cyan]
        when [:mam, :method_name]
          [:reset, :bold]

        when [:message, :action]
          [:green]
        when [:message, :error]
          [:red, :bold]
        when [:message, :info]
          [:green]

        when [:reset]
          [:reset]

        else
          raise ArgumentError, "Unknown spec: #{spec.inspect}"
        end
      ) # Tools.ansi
    end

    def self.colorize(*args)
      args.map {|v| v.is_a?(Array) ? seq(*v) : v}.join
    end
  end # Colorize
end
