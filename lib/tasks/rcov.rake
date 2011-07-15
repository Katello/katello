desc  "Run all specs with rcov"

if Rails.env == 'test' || Rails.env == 'development'
  RSpec::Core::RakeTask.new("rcov") do |t|
    t.rcov = true
    t.rcov_opts = %w{--rails --include views -Ispec --exclude gems\/,spec\/,features\/,seeds\/,usr\/,lib\/ --failure-threshold 75}
  end
end
