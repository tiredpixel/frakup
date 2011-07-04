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
    
    property :started_at,
      DateTime
    property :finished_at,
      DateTime
    
    def self.backup(source, target)
      $log.info "Backup started"
      $log.info "  - source: #{source}"
      $log.info "  - target: #{target}"
      
      backupset = Backupset.create(
        :started_at => Time.now
        )
      
      $log.info "  Created Backupset ##{backupset.id}"
      
      Backupelement.transaction do
        Pathname.glob(File.join(source, "**", "*")).each do |f|
          Backupelement.store(backupset, f)
        end
      end
      
      backupset.finished_at = Time.now
      backupset.save
      
      $log.info "  Backup finished"
      $log.info "    - duration: #{Time.at(backupset.finished_at.to_time - backupset.started_at.to_time).gmtime.strftime('%R:%S')}"
      $log.info "    - backupelements: #{backupset.backupelements.count}"
      $log.info "    - fileobjects: #{backupset.fileobjects.count}"
      $log.info "    - size: #{Frakup::Helper.human_size(backupset.fileobjects.sum(:size))}"
    end
  end
end
