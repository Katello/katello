import React from 'react';
import {
  Card,
  CardHeader,
  CardTitle,
  CardBody,
  Flex,
  FlexItem,
  GridItem,
  Label,
} from '@patternfly/react-core';

import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { translate as __ } from 'foremanReact/common/I18n';
import { propsToCamelCase } from 'foremanReact/common/helpers';
import PropTypes from 'prop-types';
import ContentViewIcon from '../../../../scenes/ContentViews/components/ContentViewIcon';
import { hostIsRegistered } from '../hostDetailsHelpers';

const HostContentViewDetails = ({
  contentView, lifecycleEnvironment, contentViewVersionId,
  contentViewVersion, contentViewVersionLatest,
}) => {
  let versionLabel = `Version ${contentViewVersion}`;
  if (contentViewVersionLatest) {
    versionLabel += ' (latest)';
  }

  return (
    <GridItem rowSpan={1} md={6} lg={4} xl2={3} >
      <Card isHoverable>
        <CardHeader>
          <CardTitle>{__('Content view details')}</CardTitle>
        </CardHeader>
        <CardBody>
          <Flex direction={{ default: 'column' }}>
            <Flex
              direction={{ default: 'row', sm: 'row' }}
              flexWrap={{ default: 'nowrap' }}
              alignItems={{ default: 'alignItemsCenter', sm: 'alignItemsCenter' }}
            >
              <ContentViewIcon composite={contentView.composite} style={{ marginRight: '2px' }} />
              <h3>{__('Content view')}</h3>
            </Flex>
            <Flex direction={{ default: 'row', sm: 'row' }} flexWrap={{ default: 'wrap' }}>
              <a style={{ fontSize: '14px' }} href={`/content_views/${contentView.id}`}>{`${contentView.name}`}</a>
              <Label isTruncated color="purple" href={`/lifecycle_environments/${lifecycleEnvironment.id}`}>{`${lifecycleEnvironment.name}`}</Label>
            </Flex>
          </Flex>
          <Flex direction={{ default: 'column' }}>
            <FlexItem>
              <h3>{__('Version in use')}</h3>
              <a style={{ fontSize: '14px' }} href={urlBuilder(`content_views/${contentView.id}/versions/${contentViewVersionId}`, '')}>
                {versionLabel}
              </a>
            </FlexItem>
          </Flex>
        </CardBody>
      </Card>
    </GridItem>
  );
};

const ContentViewDetailsCard = ({ hostDetails }) => {
  if (hostIsRegistered({ hostDetails }) && hostDetails.content_facet_attributes) {
    return <HostContentViewDetails {...propsToCamelCase(hostDetails.content_facet_attributes)} />;
  }
  return null;
};

HostContentViewDetails.propTypes = {
  contentView: PropTypes.shape({
    name: PropTypes.string,
    id: PropTypes.number,
    composite: PropTypes.bool,
  }).isRequired,
  lifecycleEnvironment: PropTypes.shape({
    name: PropTypes.string,
    id: PropTypes.number,
  }).isRequired,
  contentViewVersionId: PropTypes.number.isRequired,
  contentViewVersion: PropTypes.string.isRequired,
  contentViewVersionLatest: PropTypes.bool.isRequired,
};

ContentViewDetailsCard.propTypes = {
  hostDetails: PropTypes.shape({
    content_facet_attributes: PropTypes.shape({}),
  }),
};

ContentViewDetailsCard.defaultProps = {
  hostDetails: {},
};

export default ContentViewDetailsCard;
