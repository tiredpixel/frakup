require 'logger'

module Frakup
  module Setup
    def setup(target)
      # set up global variables                                                #
      $frakup_path = File.join(target, "frakup")
      $fileobjects_path = File.join($frakup_path, "fileobjects")
      $database_path = File.join($frakup_path, "frakup.sqlite3")
      $log_path = File.join($frakup_path, "frakup.log")
      
      # create required directories                                            #
      FileUtils.mkdir($frakup_path) unless File.exists?($frakup_path)
      FileUtils.mkdir($fileobjects_path) unless File.exists?($fileobjects_path)
      
      # set up database                                                        #
      DataMapper.setup(
        :default,
        "sqlite:#{$database_path}"
        )
      
      DataMapper.finalize
      
      DataMapper.auto_upgrade!
      
      # set up log                                                             #
      $log = Logger.new($log_path)
    end
    module_function :setup
  end
end
