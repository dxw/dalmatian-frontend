require "yaml"

class FindDalmatianConfiguration
  def call
    YAML.safe_load(File.read("tmp/dalmatian-config/dalmatian.yml"))
  end
end
