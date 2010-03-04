require 'uuidtools'
require 'uuidtools_extensions'

module ActiveRecord #:nodoc:
  module Acts #:nodoc:
    module HasUuid #:nodoc:
      GENERATORS = [:random, :timestamp] #:nodoc:

      def self.included(base) #:nodoc:
        base.extend(ClassMethods)
      end

      # Use this extension to automatically assign a UUID when your model is created.
      #
      # Example:
      #
      #    class Post < ActiveRecord::Base
      #      has_uuid
      #    end
      #
      # That is all.
      module ClassMethods
        # Configuration options are:
        #
        # * +auto+ - specifies whether the plugin should auto-generate UUIDs on create
        # * +generator+ - sets the UUID generator. Possible values are <tt>:random</tt> for version 4 (default) and <tt>:timestamp</tt> for version 1.
        # * +column+ - specifies the column in which to store the UUID (default: +uuid+).
        def has_uuid(options = {})
          options.reverse_merge!(:auto => true, :generator => :random, :column => :uuid)
          raise ArgumentError unless GENERATORS.include?(options[:generator])

          class_eval do
            send :include, InstanceMethods # hide include from RDoc
            
            if options[:auto]
              before_validation_on_create :assign_uuid
            end

            write_inheritable_attribute :uuid_generator, options[:generator]
            write_inheritable_attribute :uuid_column, options[:column]
          end
        end
        
        # Find appropriately based whether argument is a UUID.
        def find_by_id_or_uuid(id_or_uuid)
          if UUIDTools::UUID.valid?(id_or_uuid)
            send("find_by_#{self.read_inheritable_attribute(:uuid_column)}", id_or_uuid) # find_by_uuid(id_or_uuid)
          else
            find(id_or_uuid.to_i)
          end
        end
      end

      module InstanceMethods #:nodoc:
          def assign_uuid(options = {})
            
            # default options
            { :force => false }.merge!(options)
            
            return if uuid_valid? unless options[:force]
            
            new_uuid = UUIDTools::UUID.send("#{self.class.read_inheritable_attribute(:uuid_generator)}_create").to_s
            send("#{self.class.read_inheritable_attribute(:uuid_column)}=", new_uuid)
          end
        
          def assign_uuid!
            assign_uuid(:force => true)
            save!
          end
          
          def uuid_valid?
            UUIDTools::UUID.valid?(send(self.class.read_inheritable_attribute(:uuid_column)))
          end
          
          def uuid_invalid?
            !uuid_valid?
          end
      end
    end
  end
end
