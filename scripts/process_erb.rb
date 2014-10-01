require_relative '../lib/env'
require_relative '../lib/processor'

input_basedir = "#{File.dirname(__FILE__)}/../templates"

%w(production staging).each do |env_name|
  env = Env.new(env_name)
  processor = Processor.new(env)
  output_basedir = "#{File.dirname(__FILE__)}/../generated/#{env_name}"
  processor.process_all(input_basedir, output_basedir)
end
