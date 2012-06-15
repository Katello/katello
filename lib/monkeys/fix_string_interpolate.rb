class String
  # the fix
  def _fast_gettext_old_format_m(args)
    if args.kind_of?(Hash)
      dup.gsub(INTERPOLATION_PATTERN_WITH_ESCAPE) do |match|
        if match == '%%'
          '%'
        else
          match =~ INTERPOLATION_PATTERN # this line is added to fill $1 and $2
          key = ($1 || $2).to_sym
          raise KeyError unless args.has_key?(key)
          $3 ? sprintf("%#{$3}", args[key]) : args[key]
        end
      end
    elsif self =~ INTERPOLATION_PATTERN
      raise ArgumentError.new('one hash required')
    else
      result = gsub(/%([{<])/, '%%\1')
      result.send :'interpolate_without_ruby_19_syntax', args
    end
  end
end
