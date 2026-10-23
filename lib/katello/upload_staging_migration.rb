require 'digest'

module Katello
  class UploadStagingMigration
    LABEL = 'Actions::Katello::Repository::UploadFiles'.freeze

    def initialize(apply: false, cleanup: false, drained: false, output: $stdout)
      @apply = apply
      @cleanup = cleanup
      @drained = drained
      @output = output
    end

    def run
      fail 'Foreman Active Storage support is required' unless UploadStaging.supported?

      counts = { eligible: 0, copied: 0, cleaned: 0, skipped: 0, failed: 0 }
      @cleanup ? cleanup(counts) : copy(counts)
      @output.puts("#{@apply ? 'Apply' : 'Preview'} #{@cleanup ? 'cleanup' : 'copy'}: #{counts.inspect}")
      counts
    end

    private

    def legacy_entries(counts)
      entries = []
      ForemanTasks::Task.where(label: LABEL).where.not(state: 'stopped').find_each do |task|
        begin
          data = task.execution_plan_action.input.with_indifferent_access
          Array(data[:tmp_files]).each do |file|
            file = file.with_indifferent_access
            entries << { path: File.expand_path(file.fetch(:path)), filename: file[:filename],
                         repository_id: data.fetch(:repository).fetch(:id), execution_plan_uuid: task.external_id,
                         expected_sha256: file[:sha256] }
          end
        rescue StandardError => e
          counts[:failed] += 1
          @output.puts("Cannot inspect task #{task.id}: #{e.class}")
        end
      end
      entries
    end

    def copy(counts)
      entries = legacy_entries(counts)
      references = entries.group_by { |entry| entry[:path] }
      entries.each do |entry|
        copy_entry(entry, references.fetch(entry[:path]).size, counts)
      end
    end

    def copy_entry(entry, reference_count, counts)
      blob = nil
      fail 'Multiple resumable tasks reference this mutable source; resolve the conflict first' unless reference_count == 1
      path = entry[:path]
      validate_path!(path)
      before = fingerprint(path)
      if entry[:expected_sha256].present? && Digest::SHA256.file(path).hexdigest != entry[:expected_sha256]
        fail 'Source differs from the checksum in the original task input'
      end
      existing = UploadStaging.find_by(execution_plan_uuid: entry[:execution_plan_uuid], legacy_path: path)
      if existing
        fail 'Source no longer matches the imported copy' unless Digest::SHA256.file(path).hexdigest == existing.sha256
        existing.open { |_file| nil }
        counts[:skipped] += 1
      elsif @apply
        UploadStaging.transaction(requires_new: true) do
          record = UploadStaging.store!(path, repository_id: entry[:repository_id],
            execution_plan_uuid: entry[:execution_plan_uuid], filename: entry[:filename], legacy_path: path)
          blob = record.file.blob
          fail 'Source changed during copying' unless fingerprint(path) == before && Digest::SHA256.file(path).hexdigest == record.sha256
        end
        counts[:copied] += 1
      else
        counts[:eligible] += 1
      end
    rescue StandardError => e
      blob.service.delete(blob.key) if blob && !blob.attachments.exists?
      counts[:failed] += 1
      @output.puts("Failed #{File.basename(entry[:path])}: #{e.class}: #{e.message}")
    end

    def cleanup(counts)
      if @apply
        fail 'Stop legacy writers and pass CONFIRM_DRAINED=true' unless @drained
        if ForemanTasks::Task.where(label: LABEL).where.not(state: 'stopped').exists?
          fail 'Repository uploads are still active or resumable; original files were retained'
        end
      end
      UploadStaging.find_each do |record|
        cleanup_entry(record, counts)
      end
    end

    def cleanup_entry(record, counts)
      unless ForemanTasks::Task.where(external_id: record.execution_plan_uuid, state: 'stopped', result: 'success').exists?
        counts[:skipped] += 1
        return
      end
      record.open { |_file| nil }
      path = record.legacy_path
      if path && (File.exist?(path) || File.symlink?(path))
        validate_path!(path)
        before = fingerprint(path)
        fail 'Source no longer matches its verified copy' unless Digest::SHA256.file(path).hexdigest == record.sha256
        fail 'Source changed during verification' unless fingerprint(path) == before

        File.unlink(path) if @apply
      end
      if @apply
        # Pulp owns the uploaded content now; both staging copies are temporary.
        record.purge!
        counts[:cleaned] += 1
      else
        counts[:eligible] += 1
      end
    rescue StandardError => e
      counts[:failed] += 1
      @output.puts("Failed staging #{record.id}: #{e.class}: #{e.message}")
    end

    def validate_path!(path)
      unless File.dirname(path) == UploadStaging.legacy_root && !File.symlink?(UploadStaging.legacy_root) && File.file?(path) && !File.symlink?(path)
        fail 'Only regular files directly inside Katello tmp/uploads can be migrated'
      end
    end

    def fingerprint(path)
      stat = File.lstat(path)
      [stat.dev, stat.ino, stat.size, stat.mtime, stat.ctime]
    end
  end
end
