module Frakup
  class Backupelement
    include DataMapper::Resource
    
    property :id,
      Serial
    property :created_at,
      DateTime
    property :updated_at,
      DateTime
    
    belongs_to :backupset
    belongs_to :fileobject,
      :required => false
    
    property :path,
      FilePath,
      :required => true,
      :key => true
    property :ftype,
      String,
      :required => true
    property :atime,
      DateTime,
      :required => true
    property :ctime,
      DateTime,
      :required => true
    property :mtime,
      DateTime,
      :required => true
    property :mode,
      String,
      :length => 4,
      :required => true
    property :full_mode,
      String,
      :length => 6,
      :required => true
    property :uid,
      Integer,
      :required => true
    property :gid,
      Integer,
      :required => true
    
    def self.store(backupset, f)
      begin
        mode = File.stat(f).mode.to_s(8)
        
        backupelement = Backupelement.create(
          :backupset => backupset,
          :path => f,
          :ftype => File.stat(f).ftype,
          :atime => File.atime(f),
          :ctime => File.ctime(f),
          :mtime => File.mtime(f),
          :mode => mode[-4..-1],
          :full_mode => mode,
          :uid => File.stat(f).uid,
          :gid => File.stat(f).gid
          )
        
        $log.info "  Storing #{backupelement.ftype} #{f}"
        
        case backupelement.ftype
        when "file"
          fileobject = Fileobject.store(f)
          
          backupelement.fileobject = fileobject
        end
        
        backupelement.save
        
        $log.info "    - Created Backupelement ##{backupelement.id}"
      rescue
        $log.error "  Could not stat #{f}"
      end
    end
  end
end
