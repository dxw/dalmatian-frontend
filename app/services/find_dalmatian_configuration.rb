require "yaml"

class FindDalmatianConfiguration
  attr_reader :config

  def initialize
    @config = YAML.safe_load(File.read("tmp/dalmatian-config/dalmatian.yml"))
  end

  def infrastructures
    config["infrastructures"].keys
  end
end
