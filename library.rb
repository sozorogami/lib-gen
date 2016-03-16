require 'fileutils'
require 'json'

module LibraryGenerator
  # a loose definition of a library
  class Library
    attr_accessor :path, :name, :spec

    def initialize(path, name, dependencies=[])
      self.path = "#{File.expand_path(path)}/#{name}"
      self.name = name
      self.spec = generate_specification(name)

      for dep in dependencies do
        self.add_dependency(dep)
      end

      FileUtils.mkdir_p self.path
      write_specification(spec)
    end

    def generate_specification(name)
      spec = {
        name: name,
        version: '1.0.0',
        summary: "An example library called #{name}",
        source_files: '*.{h,m,swift}',
        platforms: {
          ios: '8.0'
        },
        authors: 'it-me@oh-hi.com',
        dependencies: {}
      }

      spec
    end

    def dependency_count
      spec[:dependencies].count
    end

    def write_specification(specification)
      return unless specification

      File.open("#{path}/#{name}.podspec.json", 'w') { |f| f.write(JSON.pretty_generate(specification)) }
    end

    def add_dependency(name)
      # Add a new dependency which will add another node in the graph.
      spec[:dependencies][name] = []
    end

    def add_swift_file(name)
      swift = <<-EOF
      public class #{name} {
        public func name() -> String {
          return "#{name}"
        }
      }
      EOF

      File.open("#{path}/#{name}.swift", 'w') { |f| f.write(swift) }
    end

    def add_objectivec_file(name)
      interface = <<-EOF_H
      @interface #{name}: NSObject

      - (NSString *)name;

      @end
      EOF_H

      implementation = <<-EOF_I
      #import "#{name}.h"
      @implementation #{name}

      - (NSString *)name {
        return @"#{name}";
      }

      @end
      EOF_I

      File.open("#{path}/#{name}.h", 'w') { |f| f.write(interface) }
      File.open("#{path}/#{name}.m", 'w') { |f| f.write(implementation) }
    end
  end
end
