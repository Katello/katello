require 'open3'
require 'bastion/engine'

namespace :bastion do

  desc 'Run linting and tests for the plugin'
  task 'ci' do
    success = grunt('ci')
    exit!(1) if !success
  end

  desc 'Run any grunt task by specifying the argument'
  task 'grunt', [:task] do |task, args|
    success = grunt(args[:task])
    exit!(1) if !success
  end

  desc 'Setup development environment'
  task 'setup' do
    puts "Setting up development environment"

    setup_npm
  end

end

def grunt(command)
  syscall("grunt #{command}")
end

def bastion_core?
  Dir.pwd.split('/').last == 'bastion'
end

def setup_npm
  syscall('sudo yum install -y nodejs npm') if !system('rpm -q nodejs') || !system('rpm -q npm')
  syscall('sudo npm -g install grunt-cli bower yo phantomjs')

  puts "Installing NPM dependencies"
  syscall("npm install #{Bastion::Engine.root}") if !bastion_core?
  syscall("npm install") if File.exist?('package.json')
  syscall("bower install") if bastion_core?
end

def syscall(*cmd)
  Open3.popen3(*cmd) do |stdin, stdout, stderr, thread|

    # read each stream from a new thread
    { :out => stdout, :err => stderr }.each do |key, stream|
      Thread.new do
        until (raw_line = stream.gets).nil? do
          puts raw_line
        end
      end
    end

    thread.join # don't exit until the external process is done
    thread.value.success?
  end
end
