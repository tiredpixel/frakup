module Frakup
  class Fileobject
    include DataMapper::Resource
    
    property :id,
      Serial
    property :created_at,
      DateTime
    property :updated_at,
      DateTime
    
    has n, :backupelements
    has n, :backupsets, :through => :backupelements
    
    property :uid,
      String,
      :length => 128
    property :size,
      Integer
    property :verified_at,
      DateTime
    property :uncorrupted,
      Boolean
    
    def verify
      full_path = File.join($fileobjects_path, id.to_s)
      
      self.verified_at = Time.now
      
      self.uncorrupted = (Fileobject.uid(full_path) == self.uid)
      
      self.save
    end
    
    def self.uid(f)
      Digest::SHA512.file(f).hexdigest
    end
    
    def self.store(f)
      uid = Fileobject.uid(f)
      
      fileobject = Fileobject.first(
        :uid => uid,
        :uncorrupted => true
        )
      
      if fileobject
        $log.info "    - Used Fileobject ##{fileobject.id}"
      else
        fileobject = Fileobject.create(
          :uid => uid,
          :size => File.size(f)
          )
        
        $log.info "    - Created Fileobject ##{fileobject.id}"
        
        fileobject_full_path = File.join($fileobjects_path, fileobject.id.to_s)
        
        if !File.exists?(fileobject_full_path)
          FileUtils.mkdir_p(File.dirname(fileobject_full_path))
          
          $log.info "    - Transferring Fileobject ##{fileobject.id}"
          
          FileUtils.cp(f, fileobject_full_path)
        end
        
        $log.info "    - Verifying Fileobject ##{fileobject.id}"
        
        fileobject.verify
      end
      
      fileobject
    end
    
    def self.verify(target)
      time_start = Time.now
      
      $log.info "Verify started"
      $log.info "  - target: #{target}"
      
      Fileobject.each do |f|
        f.verify
        
        if f.uncorrupted
          $log.info "  Uncorrupted Fileobject ##{f.id}"
        else
          $log.info "  Corrupted Fileobject ##{f.id}"
        end
      end
      
      time_stop = Time.now
      
      $log.info "  Verify finished"
      $log.info "    - duration: #{Time.at(time_stop - time_start).gmtime.strftime('%R:%S')}"
      $log.info "    - fileobjects: #{Fileobject.count}"
      $log.info "    - corrupted: #{Fileobject.count(:uncorrupted => false)}"
    end
  end
end
