require 'katello_test_helper'

module Katello
  class ContainerPathOverlapValidatorTest < ActiveSupport::TestCase
    Validator = Validators::ContainerPathOverlapValidator
    Reference = Struct.new(:id, :path, :repository, keyword_init: true)

    def candidate(path, repository: nil, reference_id: nil, namespace: nil)
      Validator::Candidate.new(path: path, repository: repository, reference_id: reference_id, namespace: namespace)
    end

    test 'exact and parent child overlaps respect slash boundaries' do
      assert Validator.overlap?('a/b', 'a/b')
      assert Validator.overlap?('a/b', 'a/b/c')
      assert Validator.overlap?('a/b/c', '/a/b/')
      assert_not Validator.overlap?('a/b', 'a/bc')
      assert_raises(ArgumentError) { Validator.overlap?('', 'a') }
    end

    test 'candidate pairs are checked without references and respect known namespaces' do
      assert_equal 1, Validator.conflicts(candidates: [candidate('a'), candidate('a/b')], references: []).size
      assert_empty Validator.conflicts(candidates: [candidate('a', namespace: 1), candidate('a/b', namespace: 2)], references: [])
      assert_equal 1, Validator.conflicts(candidates: [candidate('a', namespace: 1), candidate('a/b')], references: []).size
    end

    test 'exact reference is excluded, not other distributions for same repository' do
      repo = Object.new
      refs = [Reference.new(id: 1, path: 'a', repository: repo), Reference.new(id: 2, path: 'a/child', repository: repo)]
      conflicts = Validator.conflicts(candidates: [candidate('a', repository: repo, reference_id: 1)], references: refs)
      assert_equal([2], conflicts.map { |conflict| conflict.other.reference_id })
    end

    test 'refresh catches old overlap and repair ignores unrelated old overlaps' do
      refs = [Reference.new(id: 1, path: 'a', repository: nil), Reference.new(id: 2, path: 'a/b', repository: nil)]
      assert_equal 1, Validator.conflicts(candidates: [candidate('a', reference_id: 1)], references: refs).size
      assert_empty Validator.conflicts(candidates: [candidate('safe', reference_id: 1)], references: refs)
      assert_empty Validator.conflicts(candidates: [candidate('elsewhere')], references: refs)
    end

    test 'transition checks candidate against another candidate current path' do
      refs = [Reference.new(id: 1, path: 'old/one', repository: nil), Reference.new(id: 2, path: 'new', repository: nil)]
      candidates = [candidate('new/one', reference_id: 1), candidate('safe/two', reference_id: 2)]
      conflicts = Validator.conflicts(candidates: candidates, references: refs)
      assert_equal([2], conflicts.map { |conflict| conflict.other.reference_id })
    end

    test 'blank reference paths are skipped instead of raising' do
      refs = [Reference.new(id: 1, path: '', repository: nil), Reference.new(id: 2, path: '///', repository: nil)]
      assert_empty Validator.conflicts(candidates: [candidate('a')], references: refs)
    end

    test 'ancestor paths are strict slash-delimited prefixes' do
      assert_equal ['a', 'a/b'], Validator.ancestor_paths('a/b/c')
      assert_empty Validator.ancestor_paths('a')
    end

    test 'relevant references load only paths that could overlap a candidate' do
      repo = katello_repositories(:busybox)
      Katello::Pulp3::DistributionReference.delete_all
      %w[org org/app org/app/web org/apple other/path].each_with_index do |path, index|
        Katello::Pulp3::DistributionReference.create!(repository: repo, path: path, href: "/pulp/dist/#{index}/")
      end
      assert_equal ['org', 'org/app', 'org/app/web'], Validator.relevant_references(['org/app']).map(&:path).sort
      assert_empty Validator.relevant_references([])
    end

    test 'messages default to generic when user or repository is unknown' do
      messages = Validator.messages(candidates: [candidate('secret'), candidate('secret/child')], organization: nil, references: [])
      assert_equal 1, messages.size
      assert_not_includes messages.first, 'secret'
      assert_includes messages.first, 'administrator'
    end
  end
end
