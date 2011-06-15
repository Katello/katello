YARD::Rake::YardocTask.new do |t|
  t.files   = ['app/**/*.rb' ]   # optional
 t.options = ['--output-dir=yard']
end

