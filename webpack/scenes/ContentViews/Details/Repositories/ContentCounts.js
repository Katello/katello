import React, { Fragment } from 'react';
import PropTypes from 'prop-types';
import { urlBuilder } from 'foremanReact/common/urlHelpers';

// type: [plural_name, singular_name, link]
const repoLabels = {
  rpm: ['RPM packages', 'RPM package', 'packages'],
  module_stream: ['module streams', 'module stream', 'module_streams'],
  erratum: ['errata', 'erratum', 'errata'], // need to handle link, its $URL/errata?repositoryId=107
  deb: ['deb packages', 'deb package', 'debs'],
  ansible_collection: ['Ansible collections', 'Ansible collection', 'ansible_collections'],
  docker_manifest: ['container manifests', 'container manifest', 'content/docker_manifests'],
  docker_manifest_list: ['container manifest lists', 'container manifest list', 'content/docker_manifest_lists'],
  docker_tag: ['container tags', 'container tag', 'content/docker_tags'],
  file: ['files', 'file', 'content/files'],
  ostree_branch: ['ostree branches', 'ostree branch', 'content/ostree_branches'],
  package_group: ['package groups', 'package group', 'package_groups'],
  puppet_module: ['puppet modules', 'puppet module', 'content/puppet_modules'],
  srpm: ['source RPMs', 'source RPM', 'source_rpms'], // no link?
};

const appendCount = (type, count, info, productId, repoId) => {
  const [repoPlural, repoSingular, link] = info;
  const displayName = count > 1 ? repoPlural : repoSingular;
  let url = urlBuilder(`products/${productId}/repositories/${repoId}/content`, '', link);
  const displayInfo = `${count} ${displayName}`;
  if (type === 'source_rpm') return displayInfo;
  if (type === 'erratum') url = urlBuilder(`errata?repositoryId=${repoId}`);

  return (
    <div key={`${type}${count}`}>
      <a href={url}>{displayInfo}</a>
    </div>
  );
};

const ContentCounts = ({ productId, repoId, counts }) => {
  const allCounts = [];

  Object.keys(counts).forEach((type) => {
    const count = counts[type];
    const info = repoLabels[type];
    // package and rpm are the same
    if (type !== 'package' && count > 0) allCounts.push(appendCount(type, count, info, productId, repoId));
  });

  return <Fragment>{allCounts}</Fragment>;
};

ContentCounts.propTypes = {
  productId: PropTypes.number.isRequired,
  repoId: PropTypes.number.isRequired,
  counts: PropTypes.shape({}).isRequired,
};

export default ContentCounts;
