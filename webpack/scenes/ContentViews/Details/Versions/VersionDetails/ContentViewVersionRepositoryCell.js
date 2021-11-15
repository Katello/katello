import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { isEmpty } from 'lodash';
import {
  Grid,
  GridItem,
} from '@patternfly/react-core';
import InactiveText from '../../../components/InactiveText';
import ContentConfig from '../../../../Content/ContentConfig';

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
      url: `ansible_collections?repositoryId=${libraryInstanceId}`,
    },
    deb: {
      name: __('Deb packages'),
      url: `debs?repositoryId=${libraryInstanceId}`,
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
      url: `docker_tags?repositoryId=${libraryInstanceId}`,
    },
    erratum: {
      name: __('Errata'),
      url: `errata?repositoryId=${libraryInstanceId}`,
    },
    file: {
      name: __('Files'),
      url: `files?repositoryId=${libraryInstanceId}`,
    },
    module_stream: {
      name: __('Module streams'),
      url: `products/${id}/repositories/${libraryInstanceId}/content/module_streams`,
    },
    package: {
      name: __('Packages'),
      url: `products/${id}/repositories/${libraryInstanceId}/content/packages`,
    },
    package_group: {
      name: __('Package groups'),
      url: `products/${id}/repositories/${libraryInstanceId}/content/package_groups`,
    },
    rpm: {
      name: __('Rpm packages'),
      url: `packages?repositoryId=${libraryInstanceId}`,
    },
    srpm: {
      name: __('Source RPMs'),
    },
  };

  ContentConfig().forEach((type) => {
    CONTENT_COUNTS[type.names.singularLabel] = {
      name: type.names.pluralLowercase,
      url: `products/${id}/repositories/${libraryInstanceId}/content/${type.names.pluralLabel}`,
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

  const contentCountArray = Object.keys(CONTENT_COUNTS);
  const contentCountToShow = contentCountArray.filter(key => !!ContentCounts[key]);
  const contentSpan = getContentSpan(contentCountToShow.length);
  return (
    <Grid>
      {!isEmpty(contentCountToShow) ?
        contentCountToShow.map((countKey) => {
          const { url = undefined, name } = CONTENT_COUNTS[countKey];
          const count = ContentCounts[countKey];
          return (
            <GridItem key={countKey} span={contentSpan}>
              {url ?
                <a href={urlBuilder(url, '')}>
                  {count} {name}
                </a> : `${count} ${name} `}
            </GridItem>);
        }) : <InactiveText text={__('N/A')} />
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
