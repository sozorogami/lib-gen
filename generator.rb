require 'fileutils'

module LibraryGenerator
  # Ideally we would not be relying on global state like this, but we got lazy
  @@allLibraries

  # Used to generate many libraries based upon a given configuration.
  class Generator
    # Generate the libraries based on the config
    def self.generate!(config)
      fail 'No config given!' unless config
      libraries = generate_libraries!(config)
      generate_podfile!(config, libraries)
    end

    def self.deleteExistingDir!(config)
      if config.suppress_del_prompt == false && Dir.exists?(config.path)
        while(true)
          puts("This will delete the directory at " + config.path + ". OK? (YES/NO)")
          input = gets.chomp
          if input == 'YES'
            break
          elsif input == 'NO'
            exit
          end
        end
      end

      FileUtils.rm_rf(config.path)
    end

    def self.generate_libraries!(config)
      deleteExistingDir!(config)

      @@allLibraries = []
      libraries = []
      config.number_of_libraries.times do
        name = `uuidgen`.chomp!
        dependencies = generate_dependencies!(config, config.max_depth - 1,
                                             config.dependencies_per_lib)
        library = Library.new(config.path, name, dependencies.map { |dep| dep.name })
        config.files_per_lib.times do
          add_source_files_to_library(config, library)
        end
        libraries += @@allLibraries
        libraries << library
      end

      libraries
    end

    def self.generate_dependencies!(config, depth, dependencies_per_lib)
      return [] unless depth > 0
      dependencies = []
      dependencies_per_lib.times do
        subdeps = generate_dependencies!(config, depth - 1, dependencies_per_lib)
        name = `uuidgen`.chomp!
        library = Library.new(config.path, name, subdeps.map { |dep| dep.name })
        config.files_per_lib.times do
          add_source_files_to_library(config, library)
        end
        dependencies << library
        @@allLibraries << library
      end
      dependencies
    end

    def self.add_source_files_to_library(config, library)
      objective_c_file = [true, false].sample
      file_name = "C#{`uuidgen`.chomp!.delete('-')}"

      if config.mixed && objective_c_file
        library.add_objectivec_file(file_name)
      else
        library.add_swift_file(file_name)
      end
    end

    def self.generate_podfile!(config, libraries)
      file_path = "#{File.expand_path(config.path)}/podfile_support.rb"

      pod_entries = libraries.map { |library| "pod \"#{library.name}\", :path => \"#{library.path}\"" }
      pod_strings = pod_entries.join("\n")

      support_contents = <<-EOF
  def import_shared_generated_pods
      #{pod_strings}
  end
      EOF

      File.open(file_path, 'w') { |f| f.write(support_contents) }
    end
  end

  # A config which can specify the options for generatation.
  class GeneratorConfig
    attr_accessor :number_of_libraries, :max_depth, :dependencies_per_lib,
      :mixed, :path, :files_per_lib, :suppress_del_prompt

    def initialize(path,
                   number_of_libraries,
                   files_per_lib,
                   max_depth,
                   dependencies_per_lib,
                   suppress_del_prompt,
                   mixed = true)
      self.number_of_libraries = number_of_libraries
      self.max_depth = max_depth
      self.dependencies_per_lib = dependencies_per_lib
      self.mixed = mixed
      self.path = path
      self.files_per_lib = files_per_lib
      self.suppress_del_prompt = suppress_del_prompt
    end
  end
end
