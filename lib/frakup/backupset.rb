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
    
    def self.backup(local, target)
      backupset = Backupset.create
      
      Pathname.glob(File.join(local, "*")).each do |f|
        Backupelement.store(backupset, f)
      end
    end
  end
end
