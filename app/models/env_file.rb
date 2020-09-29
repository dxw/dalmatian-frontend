class EnvFile
  include ActiveModel::Model

  attr_accessor :file_name

  validate :env_file?

  def initialize(file_name: nil)
    self.file_name = file_name
  end

  def self.valid?(tempfile:)
    return false unless File.extname(tempfile.path) == ".env"

    results = []
    File.foreach(tempfile) do |line|
      env_var_pattern = /^(\w|_)*=([^"|'])*$/
      results << line.match(env_var_pattern)
    end
    return false if results.include?(nil)
    true
  end

  def file_path
    "./tmp/#{file_name}"
  end

  def self.persist(tempfile:)
    FileUtils.cp(tempfile, "./tmp/#{tempfile.original_filename}")
  end

  def contents
    contents = {}
    File.foreach(file_path) do |line|
      split_line = line.split("=")
      key, value = split_line.first, split_line.last.strip
      contents[key] = value
    end
    contents
  end
end
