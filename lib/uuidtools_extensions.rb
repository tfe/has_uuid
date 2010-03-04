module UUIDTools
  class UUID
    
    # Re-open the class and define a quick method for determining validity of a string that might be a UUID.
    def self.valid?(potential_uuid = nil)
      begin
        self.parse(potential_uuid).kind_of? UUIDTools::UUID
      rescue ArgumentError, TypeError
        false
      end
    end
  end
end