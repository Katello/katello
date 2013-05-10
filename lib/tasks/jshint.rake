if Rails.env.development?
  begin
    require "jshintrb/jshinttask"

    vendor_files = [
      'app/assets/javascripts/common/routes',
      'app/assets/javascripts/common/chosen.jquery',
      'app/assets/javascripts/common/spin.min',
      'app/assets/javascripts/html5/excanvas',
      'app/assets/javascripts/html5/html5'
    ].join(",")

    Jshintrb::JshintTask.new :jshint do |t|
      t.pattern         = 'app/assets/javascripts/**/*.js'
      t.exclude_pattern = "{#{vendor_files}}.js"
      t.options         = {
          :bitwise   => true,
          :curly     => true,
          :eqeqeq    => true,
          :forin     => true,
          :immed     => true,
          :latedef   => false, # TODO: reenable this and fix
          :newcap    => false,
          :noarg     => true,
          :noempty   => true,
          :nonew     => true,
          :plusplus  => true,
          :regexp    => true,
          :undef     => false,
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
