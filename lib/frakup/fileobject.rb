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
    
    property :size,
      Integer,
      :key => true
    property :uid,
      String,
      :length => 128,
      :key => true
    property :verified_at,
      DateTime
    property :uncorrupted,
      Boolean
    
    def verify
      folder = (id / 10000).to_s
      
      full_path = File.join($fileobjects_path, folder, id.to_s)
      
      self.verified_at = Time.now
      
      self.uncorrupted = (
        File.exists?(full_path) && (
          Fileobject.size(full_path) == self.size &&
          Fileobject.uid(full_path) == self.uid
          )
        )
      
      self.save
    end
    
    def self.uid(f)
      Digest::SHA512.file(f).hexdigest
    end
    
    def self.size(f)
      File.size(f)
    end
    
    def self.store(f)
      uid = Fileobject.uid(f)
      size = Fileobject.size(f)
      
      fileobject = Fileobject.first(
        :size => size,
        :uid => uid,
        :uncorrupted => true
        )
      
      if fileobject
        $log.info "    - Used Fileobject ##{fileobject.id}"
      else
        fileobject = Fileobject.create(
          :size => size,
          :uid => uid
          )
        
        $log.info "    - Created Fileobject ##{fileobject.id}"
        
        fileobject_folder = (fileobject.id / 10000).to_s
        
        fileobject_full_path = File.join($fileobjects_path, fileobject_folder, fileobject.id.to_s)
        
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
          $log.warn "  Corrupted Fileobject ##{f.id}"
        end
      end
      
      time_stop = Time.now
      
      $log.info "  Verify finished"
      $log.info "    - duration: #{Time.at(time_stop - time_start).gmtime.strftime('%R:%S')}"
      $log.info "    - fileobjects: #{Fileobject.count}"
      $log.warn "    - corrupted: #{Fileobject.count(:uncorrupted => false)}"
    end
  end
end
