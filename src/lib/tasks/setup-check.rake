desc  "Run development setup check script"

task :check_setup do
  sh %(../scripts/devsetup/check_setup.py)
end
