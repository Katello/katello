require 'pulp_rpm_client'

unless PulpRpmClient.const_defined?('OneOfMetadataChecksumTypeEnumNullEnum')
  class PulpRpmClient::OneOfMetadataChecksumTypeEnumNullEnum
    def self.build_from_hash(value)
      value
    end
  end
end

unless PulpRpmClient.const_defined?('OneOfPackageChecksumTypeEnumNullEnum')
  class PulpRpmClient::OneOfPackageChecksumTypeEnumNullEnum
    def self.build_from_hash(value)
      value
    end
  end
end
