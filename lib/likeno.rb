require 'yaml'
require 'logger'
require 'likeno/entity.rb'

module Likeno
  @config = {}

  # Configure through hash
  def self.configure(opts = {})
    opts.each { |name, address| @config[name.to_sym] = address }
  end

  # Configure through yaml file
  def self.configure_with(path_to_yaml_file)
    begin
      @config = Psych.load_file path_to_yaml_file
    rescue Errno::ENOENT
      raise Errno::ENOENT, "YAML configuration file couldn't be found."
    rescue Psych::Exception
      raise Psych::Exception, 'YAML configuration file contains invalid syntax.'
    end

    configure(config)
  end

  def self.config
    @config
  end
end
