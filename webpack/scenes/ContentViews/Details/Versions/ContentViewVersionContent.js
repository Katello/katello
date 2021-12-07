import React from 'react';
import PropTypes from 'prop-types';
import { Link } from 'react-router-dom';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import ContentConfig from './../../../Content/ContentConfig';
import InactiveText from '../../components/InactiveText';

const ContentViewVersionContent = ({ cvId, versionId, cvVersion }) => {
  const {
    deb_count: debCount = 0,
    docker_manifest_count: dockerManifestCount = 0,
    docker_tag_count: dockerTagCount = 0,
    file_count: fileCount = 0,
    module_stream_count: moduleStreamCount = 0,
    ansible_collection_count: ansibleCollectionCount = 0,
  } = cvVersion;


  const genericContentTypes = ContentConfig().filter(({ names: { singularLabel } }) => {
    // Ansible Collections has a tab in version details so it's handled separately below.
    if (singularLabel === 'ansible_collection') return false;
    const countLabel = `${singularLabel}_count`;
    return !!cvVersion[countLabel];
  }).map(({ names: { singularLabel, singularLowercase, pluralLowercase } }) => {
    const countParam = `${singularLabel}_count`;
    const count = cvVersion[countParam];
    return {
      label: count > 1 ? pluralLowercase : singularLowercase,
      count,
    };
  });

  const noCounts =
    !Number(debCount) && !Number(dockerManifestCount) && !Number(dockerTagCount) &&
    !Number(fileCount) && !Number(moduleStreamCount) && !Number(ansibleCollectionCount) &&
    !genericContentTypes?.length;

  if (noCounts) {
    return <InactiveText text={__('No content')} />;
  }

  return (
    <>
      {moduleStreamCount > 0 &&
        <>
          <Link to={`/versions/${versionId}/moduleStreams`}>
            {`${moduleStreamCount} Module streams`}
          </Link><br />
        </>
      }
      {debCount > 0 &&
        <>
          <Link to={`/versions/${versionId}/debPackages`}>
            {`${debCount} Deb packages`}
          </Link><br />
        </>
      }
      {dockerManifestCount > 0 && dockerTagCount > 0 &&
        <>
          <Link to={`/versions/${versionId}/dockerTags`}>
            {`${dockerTagCount} Docker tags`}
          </Link><br />
          <a href={urlBuilder(`content_views/${cvId}#/versions/${versionId}/dockerTags`, '')}>{`${dockerManifestCount} Container manifests`}</a><br />
        </>
      }
      {fileCount > 0 &&
        <>
          <a href={urlBuilder(`content_views/${cvId}#/versions/${versionId}/files`, '')}>{`${fileCount} Files`}</a><br />
        </>
      }
      {ansibleCollectionCount > 0 &&
        <>
          <a href={urlBuilder(`content_views/${cvId}#/versions/${versionId}/ansibleCollections`, '')}>{`${ansibleCollectionCount} Collections`}</a><br />
        </>
      }
      {genericContentTypes?.length > 0 &&
        genericContentTypes.map(({ label, count }) => (
          <span key={label} style={{ whiteSpace: 'pre-line' }}>
            {`${count} ${label}`}
          </span>))
      }
    </>
  );
};

ContentViewVersionContent.propTypes = {
  cvId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  versionId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  cvVersion: PropTypes.shape({
    deb_count: PropTypes.number,
    docker_manifest_count: PropTypes.number,
    docker_tag_count: PropTypes.number,
    file_count: PropTypes.number,
    module_stream_count: PropTypes.number,
    ansible_collection_count: PropTypes.number,
  }),
};

ContentViewVersionContent.defaultProps = {
  cvId: '',
  versionId: '',
  cvVersion: {
    deb_count: 0,
    docker_manifest_count: 0,
    docker_tag_count: 0,
    file_count: 0,
    module_stream_count: 0,
    ansible_collection_count: 0,
  },
};

export default ContentViewVersionContent;
