require './library.rb'
require './generator.rb'
require 'optparse'

options = {}
options[:path] = File.expand_path('~/Desktop/libs')
options[:files_per_lib] = 20
options[:max_depth] = 1
options[:dependencies_per_lib] = 1
options[:suppress_del_prompt] = false

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: lib-gen.rb -p path -f files_per_node -d max_depth -n dependencies_per_lib"
  opts.separator ''
  opts.on('-p', '--path [PATH]', String, 'Path to create dependencies') do |path|
    options[:path] = File.expand_path(path)
  end
  opts.on('-f', '--files [NUM]', Integer, 'Source files per dependency') do |n|
    options[:files_per_lib] = n
  end
  opts.on('-d', '--depth [NUM]', Integer, 'Max depth of dependency tree') do |n|
    options[:max_depth] = n
  end
  opts.on('-n', '--number [NUM]', Integer, 'Number of dependencies per library') do |n|
    options[:dependencies_per_lib] = n
  end
  opts.on('-D', '--delete', 'Suppress prompt when deleting existing directory') do
    options[:suppress_del_prompt] = true
  end
end

if ARGV.length == 0
  puts optparse; exit
end

optparse.parse!(ARGV)

config = LibraryGenerator::GeneratorConfig.new(options[:path],
                                               1,
                                               options[:files_per_lib],
                                               options[:max_depth],
                                               options[:dependencies_per_lib],
                                               options[:suppress_del_prompt])
LibraryGenerator::Generator.generate!(config)
