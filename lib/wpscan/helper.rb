def read_json_file(file)
  JSON.parse(File.read(file))
rescue StandardError => e
  raise "JSON parsing error in #{file} #{e}"
end
