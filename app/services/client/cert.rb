#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'openssl'
require 'base64'

module Client
  class Cert
    attr_accessor :cert

    def initialize(cert)
      self.cert = extract(cert)
    end

    def uuid
      drop_cn_prefix_from_subject(@cert.subject.to_s)
    end

    private

    def extract(cert)
      if cert.empty?
        fail('Invalid cert provided. Ensure that the provided cert is not empty.')
      else
        cert = strip_cert(cert)
        cert = Base64.decode64(cert)

        OpenSSL::X509::Certificate.new(cert)
      end
    end

    def drop_cn_prefix_from_subject(subject_string)
      subject_string.sub(/\/CN=/i, '')
    end

    def strip_cert(cert)
      cert = cert.to_s.gsub("-----BEGIN CERTIFICATE-----", "").gsub("-----END CERTIFICATE-----", "")
      cert.gsub!(' ', '')
      cert.gsub!(/\n/, '')
      cert
    end
  end
end
