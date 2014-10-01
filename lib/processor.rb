require 'erb'
require 'fileutils'

class Processor
  def initialize(env)
    @env = env
  end

  def process_all(input_basedir, output_basedir)
    Dir.glob("#{input_basedir}/**/*.erb") do |input_filename|
      output_filename = output_basedir + input_filename[input_basedir.length..-1]
      output_dirname = File.dirname(output_filename)
      FileUtils.mkdir_p(output_dirname)
      process(input_filename, output_filename)
    end
  end

  def process(input_filename, output_filename)
    contents = File.open(input_filename, 'r') { |f| f.read }

    erb = ERB.new(contents)
    erb.filename = input_filename
    output = erb.result(@env.binding)

    File.open(output_filename, 'w') { |f| f.write(output) }
  end
end
