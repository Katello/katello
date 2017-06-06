if Rails.env.development?
  begin
    require "jshintrb/jshinttask"

    Jshintrb::JshintTask.new :jshint do |t|
      t.pattern         = '{public/javascripts, public/javscripts/widgets}/*.js'
      t.exclude_pattern = '{public/javascripts/converge-ui/**/*,public/javascripts/tests/**/*,public/javascripts/routes}.js'
      t.options         = {
          :bitwise   => true,
          :curly     => true,
          :eqeqeq    => true,
          :forin     => true,
          :immed     => true,
          :latedef   => true,
          :newcap    => false,
          :noarg     => true,
          :noempty   => true,
          :nonew     => true,
          :plusplus  => true,
          :regexp    => true,
          :undef     => true,
          :strict    => false,
          :trailing  => true,
          :browser   => true,
          :jquery    => true,
          :passfail  => false,
          :white     => false,
          :sub       => true,
          :lastsemic => true,
          :smarttabs => true
      }

    end
  rescue LoadError
    warn "install jshintrb gem"
  end
end
