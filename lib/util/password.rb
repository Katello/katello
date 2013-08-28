#
# Copyright 2013 Red Hat, Inc.
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
require 'digest/sha2'

# This module contains functions for hashing and storing passwords with
# SHA512 with 64 characters long random salt. It also includes several other
# password-related utility functions.
#
# Please note this module is required either from Rails and from Puppet.
#
module Password

  # Generates a new salt and rehashes the password
  def self.update(password)
    salt = self.salt
    hash = self.hash(password, salt)
    self.store(hash, salt)
  end

  # Checks the password against the stored password
  def self.check(password, store)
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
    chars = ('A'..'Z').to_a + ('a'..'z').to_a + (0..9).to_a
    result = []
    length.to_i.times { result += chars.sample(1) }
    result.join
  end

  def self.encrypt(text, passphrase = nil)
    passphrase = File.open('/etc/katello/secure/passphrase', 'rb') { |f| f.read }.chomp if passphrase.nil?
    '$1$' + [aes_encrypt(text, passphrase)].pack('m0').gsub("\n", '') # for Ruby 1.8
  rescue => e
    if defined?(Rails) && Rails.logger
      Rails.logger.warn "Unable to encrypt password: #{e}"
    else
      STDERR.puts "Unable to encrypt password: #{e}".chomp
    end
    text # return the input if anything goes wrong
  end

  def self.decrypt(text, passphrase = nil)
    return text unless text.start_with? '$1$' # password is plain
    passphrase = File.open('/etc/katello/secure/passphrase', 'rb') { |f| f.read }.chomp if passphrase.nil?
    aes_decrypt(text[3..-1].unpack('m0')[0], passphrase)
  rescue => e
    if defined?(Rails) && Rails.logger
      Rails.logger.warn "Unable to decrypt password, returning encrypted version #{e}"
    else
      STDERR.puts "Unable to decrypt password, returning encrypted version #{e}".chomp
    end
    text # return the input if anything goes wrong
  end

  protected

  def self.aes_encrypt(text, passphrase)
    cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    cipher.encrypt
    cipher.key = Digest::SHA2.hexdigest(passphrase)
    cipher.iv = Digest::SHA2.hexdigest(passphrase + passphrase)

    encrypted = cipher.update(text)
    encrypted << cipher.final
    encrypted
  end

  def self.aes_decrypt(text, passphrase)
    cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
    cipher.decrypt
    cipher.key = Digest::SHA2.hexdigest(passphrase)
    cipher.iv = Digest::SHA2.hexdigest(passphrase + passphrase)

    decrypted = cipher.update(text)
    decrypted << cipher.final
    decrypted
  end

  # this option is intended for altering the behaviour
  # of hashin (such as faster passowrd hashing when running tests)
  # should be used with caution (setting to 1 in testing environment
  # is probably the only reasonable usage)
  # rubocop:disable TrivialAccessors
  def self.password_rounds=(value)
    @password_rounds = value
  end

  def self.password_rounds
    @password_rounds || 500
  end

  # Generates a psuedo-random 64 character string
  def self.salt
    self.generate_random_string(64)
  end

  # Generates a 128 character hash
  def self.hash(password, salt)
    digest = "#{password}:#{salt}"
    password_rounds.times { digest = Digest::SHA512.hexdigest(digest) }
    digest
  end

  # Mixes the hash and salt together for storage
  def self.store(hash, salt)
    hash + salt
  end

  # Gets the hash from a stored password
  def self.get_hash(store)
    store[0..127]
  end

  # Gets the salt from a stored password
  def self.get_salt(store)
    store[128..191]
  end
end
