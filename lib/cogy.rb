require "cogy/engine"
require "cogy/handler"
require "cogy/command"

module Cogy
  COG_BUNDLE_VERSION = 4

  # Holds all the registered Commands. Not to be messed with.
  mattr_accessor :commands
  @@commands = {}

  # Bundle config-related stuff
	mattr_accessor :bundle_name
	@@bundle_name = "cogy"

  mattr_accessor :bundle_description
  @@bundle_description = "Cogy-generated commands"

  # Can be either a string or an object that responds to `#call` and returns
  # a string.
  #
  # Must be set explicitly
  mattr_accessor :bundle_version
  @@bundle_version = nil

  # The path in the Cog Relay where the command executable is located.
  #
  # Must be set explicitly.
  mattr_accessor :executable_path
  @@executable_path = nil

  # Paths where the files that define the commands will be searched in
  mattr_accessor :command_load_paths
  @@command_load_paths = ["cogy"]

  def self.on(cmd_name, opts = {}, &blk)
    cmd = Command.new(cmd_name, opts)
    handler = Handler.new(blk)
    cmd.register!(handler)
  end

  # @return [Hash]
  def self.bundle_config
    version = if bundle_version.respond_to?(:call)
      bundle_version.call
    else
      bundle_version
    end

    config = {
      "cog_bundle_version" => COG_BUNDLE_VERSION,
      "name" => bundle_name,
      "description" => bundle_description,
      "version" => version,
      "commands" => {}
    }

    commands.each do |name, cmd|
      # also add options
      config["commands"][name] = {
        "executable" => executable_path,
        "description" => cmd.desc,
        "arguments" => cmd.formatted_args,
        #"options" => cmd.options, TODO
        "rules" => cmd.rules
      }

      if cmd.example
        config["commands"][name]["example"] = cmd.example
      end
    end

    config
  end

  def self.configure
    yield self
  end
end
