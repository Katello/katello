require 'ostruct'
@resource_struct = OpenStruct.new(@resource)

object @resource_struct => :certificate

attributes :id, :cert, :key
attributes  :created => :created_at,
            :updated => :updated_at

child OpenStruct.new(@resource_struct.serial) => :serial do
  attributes :id, :revoked, :collected, :serial
  attributes  :created => :created_at,
              :updated => :updated_at,
              :expiration => :expires_at
end
