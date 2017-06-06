# .simplecov
SimpleCov.start 'rails' do
  # configuration stuff
  merge_timeout 1800
  command_name "spec"
  command_name "minitest"
  add_filter "/test/"
  add_filter "/lib/tasks/"
  add_filter "/spec"
end if ENV['COVERAGE']
