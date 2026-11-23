require 'digest'
require 'base64'

module Katello
  class UploadStaging < Katello::Model
    belongs_to :repository, class_name: 'Katello::Repository', inverse_of: :upload_stagings
    has_one_attached :file if respond_to?(:has_one_attached)

    validates :repository, :execution_plan_uuid, :filename, :sha256, presence: true

    def self.supported?
      ApplicationRecord.respond_to?(:has_one_attached)
    end

    def self.legacy_root
      Rails.root.join('tmp/uploads').to_s
    end

    def self.store!(path, **attributes)
      blob = nil
      File.open(path, 'rb') do |source|
        sha256 = Digest::SHA256.file(source.path).hexdigest
        blob = ActiveStorage::Blob.create_before_direct_upload!(
          filename: attributes[:filename].presence || File.basename(path),
          content_type: 'application/octet-stream', byte_size: source.size,
          checksum: Base64.strict_encode64(Digest::MD5.file(source.path).digest)
        )
        blob.upload(source, identify: false)
        blob.save!
        transaction(requires_new: true) do
          create!(**attributes, filename: blob.filename.to_s, sha256: sha256, file: blob)
        end
      end
    rescue StandardError
      if blob && !blob.attachments.exists?
        blob.service.delete(blob.key)
        blob.destroy! if blob.persisted?
      end
      raise
    end

    def self.resolve(metadata, repository_id, plan_uuid)
      metadata = { path: metadata } if metadata.is_a?(String)
      metadata = metadata.with_indifferent_access
      scope = where(repository_id: repository_id, execution_plan_uuid: plan_uuid)
      return scope.find(metadata[:staging_id]) if metadata[:staging_id]

      scope.find_by(legacy_path: File.expand_path(metadata[:path])) if metadata[:path]
    end

    def metadata
      { staging_id: id, filename: filename, sha256: sha256, byte_size: file.byte_size }
    end

    def open
      file.open do |copy|
        fail ActiveStorage::IntegrityError unless Digest::SHA256.file(copy.path).hexdigest == sha256

        yield copy
      end
    end

    # Only call once the owning plan no longer needs the upload. Deleting the
    # object first keeps its owner/metadata available if storage deletion fails.
    def purge!
      file.blob.service.delete(file.blob.key) if file.attached?
      file.purge
      destroy!
    end
  end
end
