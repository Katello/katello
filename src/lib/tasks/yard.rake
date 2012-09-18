begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.files   = ['app/**/*.rb' ]   # optional
    t.options = ['--output-dir=yard']
  end
rescue LoadError
  # yard not present, skipping this definition
end


