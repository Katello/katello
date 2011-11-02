#
# Copyright 2011 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'digest/sha2'

# This module contains functions for hashing and storing passwords with
# SHA512 with 64 characters long random salt.
module Password

  # Generates a new salt and rehashes the password
  def Password.update(password)
    salt = self.salt
    hash = self.hash(password, salt)
    self.store(hash, salt)
  end

  # Checks the password against the stored password
  def Password.check(password, store)
    hash = self.get_hash(store)
    salt = self.get_salt(store)
    if self.hash(password, salt) == hash
      true
    else
      false
    end
  end

  # Generates random string like for length = 10 => "iCi5MxiTDn"
  def self.generate_random_string(length)
    length.to_i.times.collect { (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }.join
  end

  protected

  # Generates a psuedo-random 64 character string
  def Password.salt
    self.generate_random_string(64)
  end

  # Generates a 128 character hash
  def Password.hash(password, salt)
    digest = "#{password}:#{salt}"
    500.times { digest = Digest::SHA512.hexdigest(digest) }
    digest
  end

  # Mixes the hash and salt together for storage
  def Password.store(hash, salt)
    hash + salt
  end

  # Gets the hash from a stored password
  def Password.get_hash(store)
    store[0..127]
  end

  # Gets the salt from a stored password
  def Password.get_salt(store)
    store[128..191]
  end
end
