require 'erb'
require 'yaml'

input_filename = ARGV[0]
output_filename = ARGV[1]

class Env
  attr_reader(:config, :secrets)

  def initialize
    @config = load_config
    @secrets = load_secrets
  end

  def load_config
    raise RuntimeError.new("You need to specify OVERVIEW_SECRETS and OVERVIEW_CONFIG paths to Yaml files.") if ENV['OVERVIEW_CONFIG'].nil?
    YAML.load_file(ENV['OVERVIEW_CONFIG'])
  end

  def load_secrets
    raise RuntimeError.new("You need to specify OVERVIEW_SECRETS and OVERVIEW_CONFIG paths to Yaml files.") if ENV['OVERVIEW_SECRETS'].nil?
    YAML.load_file(ENV['OVERVIEW_SECRETS'])
  end

  def method_missing(meth, *args, &block)
    if !config[meth.to_s].nil?
      config[meth.to_s]
    else
      super(meth, *args, &block)
    end
  end

  def binding; super; end # public
end

env = Env.new

contents = File.open(input_filename, 'r') { |f| f.read }

erb = ERB.new(contents)
erb.filename = input_filename

output = erb.result(env.binding)
File.open(output_filename, 'w') { |f| f.write(output) }
