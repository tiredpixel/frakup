module Frakup
  class Backupset
    include DataMapper::Resource
    
    property :id,
      Serial
    property :created_at,
      DateTime
    property :updated_at,
      DateTime
    
    has n, :backupelements
    has n, :fileobjects, :through => :backupelements
    
    def self.backup(source, target)
      time_start = Time.now
      
      $log.info "Backup started"
      $log.info "  - source: #{source}"
      $log.info "  - target: #{target}"
      
      backupset = Backupset.create
      
      $log.info "  Created Backupset ##{backupset.id}"
      
      Pathname.glob(File.join(source, "*")).each do |f|
        Backupelement.store(backupset, f)
      end
      
      time_stop = Time.now
      
      $log.info "  Backup finished"
      $log.info "    - duration: #{Time.at(time_stop - time_start).gmtime.strftime('%R:%S')}"
    end
  end
end
