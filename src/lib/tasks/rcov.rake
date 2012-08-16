desc  "Run all specs with rcov"

begin
  RSpec::Core::RakeTask.new("rcov") do |t|
    t.rcov = true
    t.rcov_opts = %w{--rails --include views -Ispec --exclude gems\/,spec\/,features\/,seeds\/,usr\/,lib\/ --failure-threshold 60}
  end
rescue NameError => e
  # RSpec is not installed, disabling rcov task
end
