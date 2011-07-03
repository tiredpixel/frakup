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
      
      if !fileobject
        fileobject = Fileobject.create(
          :uid => uid
          )
        
        fileobject_full_path = File.join($fileobjects_path, fileobject.id.to_s)
        
        if !File.exists?(fileobject_full_path)
          FileUtils.mkdir_p(File.dirname(fileobject_full_path))
          FileUtils.cp(f, fileobject_full_path)
        end
        
        fileobject.verify
      end
      
      fileobject
    end
  end
end
