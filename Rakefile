# tests with rake's own test task
require 'rake/testtask'
Rake::TestTask.new do |t|
  t.pattern = "spec/*_spec.rb" # default test/*_test.rb
end

# tests with a custom task
SPECS = "./spec"

desc "Run all the tests under #{SPECS}"
task :mytest do
  Dir.glob("#{SPECS}/**/*_spec.rb") { |f| puts f; require f }
end
