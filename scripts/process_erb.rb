require 'erb'
require 'yaml'

input_filename = ARGV[0]
output_filename = ARGV[1]
production_or_staging = ARGV[2]

class Env
  attr_reader(:config, :secrets, :production_or_staging)

  def initialize(production_or_staging)
    @production_or_staging = production_or_staging
    @config = load_config
    @secrets = load_secrets
  end

  def load_config
    raise RuntimeError.new("You need to specify OVERVIEW_SECRETS and OVERVIEW_CONFIG paths to Yaml files.") if ENV['OVERVIEW_CONFIG'].nil?
    YAML.load_file(ENV['OVERVIEW_CONFIG'])[production_or_staging]
  end

  def load_secrets
    raise RuntimeError.new("You need to specify OVERVIEW_SECRETS and OVERVIEW_CONFIG paths to Yaml files.") if ENV['OVERVIEW_SECRETS'].nil?
    YAML.load_file(ENV['OVERVIEW_SECRETS'])[production_or_staging]
  end

  def database_ip
    @database_ip ||= get_ips('database').first
  end

  def database_url
    "postgres://#{database_username}:#{secrets['database-password']}@#{database_ip}/#{database_dbname}?ssl=true&sslfactory=org.postgresql.ssl.NonValidatingFactory"
  end

  def worker_ip
    @worker_ip ||= get_ips('worker').first
  end

  def searchindex_ip
    @searchindex_ip ||= get_ips('searchindex').first
  end

  def method_missing(meth, *args, &block)
    if !config[meth.to_s].nil?
      config[meth.to_s]
    else
      super(meth, *args, &block)
    end
  end

  def binding; super; end # public

  private

  def overview_manage_status
    @overview_manage_status ||= `overview-manage status`
    @overview_manage_status.lines
  end

  def get_ips(machine_type)
    overview_manage_status
      .grep(/#{production_or_staging}/)
      .grep(/#{machine_type}/)
      .map { |line| line.split[2] }
  end
end

env = Env.new(production_or_staging)

contents = File.open(input_filename, 'r') { |f| f.read }

erb = ERB.new(contents)
erb.filename = input_filename

output = erb.result(env.binding)
File.open(output_filename, 'w') { |f| f.write(output) }
