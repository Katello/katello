Rake::TestTask.new "test:integration:pulp" do |t|
  t.test_files = FileList['test/integration/pulp/*_test.rb']
  t.libs = ["lib"]
end
  
Rake::Task[:'test:integration:pulp'].prerequisites.clear
