import React from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import {
  camelCase,
  isEmpty,
} from 'lodash';
import PropTypes from 'prop-types';
import { Link } from 'react-router-dom';
import {
  Grid,
  GridItem,
} from '@patternfly/react-core';
import ContentConfig from '../../../../Content/ContentConfig';
import InactiveText from '../../../components/InactiveText';

const ContentViewVersionRepositoryCell = ({
  data: {
    content_counts: ContentCounts,
    product: { id },
    library_instance_id: libraryInstanceId,
  },
}) => {
  const CONTENT_COUNTS = {
    ansible_collection: {
      name: __('Ansible collections'),
      to: `ansibleCollections?library_instance_id=${libraryInstanceId}`,
    },
    deb: {
      name: __('Deb packages'),
      to: `debPackages?library_instance_id=${libraryInstanceId}`,
    },
    docker_manifest: {
      name: __('Container manifests'),
      url: `products/${id}/repositories/${libraryInstanceId}/content/content/docker_manifests`,
    },
    docker_manifest_list: {
      name: __('Container manifest lists'),
      url: `products/${id}/repositories/${libraryInstanceId}/content/content/docker_manifest_lists`,
    },
    docker_tag: {
      name: __('Container image tags'),
      to: `dockerTags?library_instance_id=${libraryInstanceId}`,
    },
    erratum: {
      name: __('Errata'),
      to: `errata?library_instance_id=${libraryInstanceId}`,
    },
    file: {
      name: __('Files'),
      to: `files?library_instance_id=${libraryInstanceId}`,
    },
    module_stream: {
      name: __('Module streams'),
      to: `moduleStreams?library_instance_id=${libraryInstanceId}`,
    },
    package_group: {
      name: __('Package groups'),
      to: `rpmPackageGroups?library_instance_id=${libraryInstanceId}`,
    },
    rpm: {
      name: __('RPM packages'),
      to: `rpmPackages?library_instance_id=${libraryInstanceId}`,
    },
    srpm: {
      name: __('Source RPMs'),
    },
  };

  ContentConfig.forEach((type) => {
    CONTENT_COUNTS[type.names.singularLabel] = {
      name: type.names.pluralLowercase,
      to: `${camelCase(type.names.pluralLabel)}?library_instance_id=${libraryInstanceId}`,
    };
  });

  const getContentSpan = (num) => {
    switch (true) {
      case num < 4:
        return 12;
      case num > 4 && num < 9:
        return 6;
      case num > 9:
        return 4;
      default:
        return 12;
    }
  };

  const CountComponent = ({ countKey }) => {
    const { to, url, name } = CONTENT_COUNTS[countKey];
    const count = ContentCounts[countKey];
    switch (true) {
      case !!url:
        return (
          <a href={urlBuilder(url, '')}>
            {count} {name}
          </a>);
      case !!to:
        return (
          <Link to={to}>
            {count} {name}
          </Link>);
      default:
        return `${count} ${name} `;
    }
  };

  CountComponent.propTypes = {
    countKey: PropTypes.string.isRequired,
  };

  const contentCountArray = Object.keys(CONTENT_COUNTS);
  const contentCountToShow = contentCountArray.filter(key => !!ContentCounts[key]);
  const contentSpan = getContentSpan(contentCountToShow.length);

  return (
    <Grid>
      {!isEmpty(contentCountToShow) ?
        contentCountToShow.map(countKey => (
          <GridItem key={countKey} span={contentSpan}>
            <CountComponent countKey={countKey} />
          </GridItem>)) : <InactiveText text={__('N/A')} />
      }
    </Grid >
  );
};

ContentViewVersionRepositoryCell.propTypes = {
  data: PropTypes.shape({
    product: PropTypes.shape({ id: PropTypes.number }),
    content_counts: PropTypes.shape({}),
    library_instance_id: PropTypes.number,
  }).isRequired,
};

export default ContentViewVersionRepositoryCell;
