module Frakup
  module Setup
    def setup(target)
      $frakup_path = File.join(target, "frakup")
      FileUtils.mkdir($frakup_path) unless File.exists?($frakup_path)
      
      $fileobjects_path = File.join($frakup_path, "fileobjects")
      FileUtils.mkdir($fileobjects_path) unless File.exists?($fileobjects_path)
      
      $database_path = File.join($frakup_path, "frakup.sqlite3")
      
      DataMapper.setup(
        :default,
        "sqlite:#{$database_path}"
        )
      
      DataMapper.finalize
      
      DataMapper.auto_upgrade!
    end
    module_function :setup
  end
end
