import React from 'react';
import PropTypes from 'prop-types';
import { Link } from 'react-router-dom';
import {
  Text,
  TextContent,
  TextVariants,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import ContentConfig from './../../../Content/ContentConfig';

const ContentViewVersionContent = ({ cvId, versionId, cvVersion }) => {
  const {
    deb_count: debCount,
    docker_manifest_count: dockerManifestCount,
    docker_tag_count: dockerTagCount,
    file_count: fileCount,
    module_stream_count: moduleStreamCount,
    ansible_collection_count: ansibleCollectionCount,
  } = cvVersion;

  const genericContentTypes = {};

  ContentConfig().forEach((type) => {
    const countLabel = `${type.names.singularLabel}_count`;
    genericContentTypes[countLabel.replace(/([-_]\w)/g, g => g[1].toUpperCase())] = [cvVersion[countLabel], type.names.pluralLowercase];
  });
  // Ansible Collections has a tab in version details so it's handled separately below.
  delete genericContentTypes.ansibleCollectionCount;
  const genericContentCountsStyle = { whiteSpace: 'pre-line' };

  return (
    <React.Fragment>
      {(moduleStreamCount > 0 &&
        <>
          <Link to={`/versions/${versionId}/moduleStreams`}>
            {`${moduleStreamCount} Module streams`}
          </Link><br />
        </>)
      }
      {(debCount > 0 &&
        <>
          <Link to={`/versions/${versionId}/debPackages`}>
            {`${debCount} Deb packages`}
          </Link><br />
        </>)
      }
      {(dockerManifestCount > 0 && dockerTagCount > 0 &&
        <>
          <Link to={`/versions/${versionId}/dockerTags`}>
            {`${dockerTagCount} Docker tags`}
          </Link><br />
          <a href={urlBuilder(`content_views/${cvId}#/versions/${versionId}/dockerTags`, '')}>{`${dockerManifestCount} Container manifests`}</a><br />
        </>)
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
      <>
        <span style={genericContentCountsStyle}>
          {Object.keys(genericContentTypes).filter(typeCountKey => genericContentTypes[typeCountKey][0] > 0).map(typeCountKey => `${genericContentTypes[typeCountKey][0]} ${genericContentTypes[typeCountKey][1]}\n`)}
        </span>
      </>
      {(moduleStreamCount === 0 && debCount === 0 &&
        dockerManifestCount === 0 && dockerTagCount === 0 &&
        fileCount === 0 && ansibleCollectionCount === 0 &&
        Object.keys(genericContentTypes).map(typeCountKey =>
          genericContentTypes[typeCountKey][0]).reduce((pv, cv) => pv + cv) === 0 &&
          <TextContent>
            <Text component={TextVariants.small}>{__('N/A')}</Text>
          </TextContent>
      )
      }
    </React.Fragment>
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
