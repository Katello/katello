import React from 'react';
import {
  DescriptionList,
  DescriptionListTerm,
  DescriptionListGroup,
  DescriptionListDescription,
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

const HostContentViewDetails = ({
  contentView, lifecycleEnvironment, contentViewVersionId,
  contentViewVersion, contentViewVersionLatest,
}) => {
  let versionLabel = `Version ${contentViewVersion}`;
  if (contentViewVersionLatest) {
    versionLabel += ' (latest)';
  }

  return (
    <GridItem rowSpan={2} md={6} lg={3}>
      <Card isHoverable>
        <CardHeader>
          <CardTitle>{__('Content View Details')}</CardTitle>
        </CardHeader>
        <CardBody>
          <DescriptionList isHorizontal isAutoColumnWidths>
            <DescriptionListGroup>
              <DescriptionListTerm>{__('Content View')}</DescriptionListTerm>
              <DescriptionListDescription>
                <Flex>
                  <FlexItem spacer={{ default: 'spacerNone' }}><ContentViewIcon composite={contentView.composite} /></FlexItem>
                  <FlexItem><a href={`/content_views/${contentView.id}`}>{`${contentView.name}`}</a> </FlexItem>
                  <FlexItem><Label isTruncated color="purple" href={`/lifecycle_environments/${lifecycleEnvironment.id}`}>{`${lifecycleEnvironment.name}`}</Label></FlexItem>
                </Flex>
              </DescriptionListDescription>
            </DescriptionListGroup>
            <DescriptionListGroup>
              <DescriptionListTerm>{__('Version in use')}</DescriptionListTerm>
              <DescriptionListDescription>
                <Flex>
                  <FlexItem>
                    <a href={urlBuilder(`content_views/${contentView.id}/versions/${contentViewVersionId}`, '')}>
                      {versionLabel}
                    </a>
                  </FlexItem>
                </Flex>
              </DescriptionListDescription>
            </DescriptionListGroup>
          </DescriptionList>
        </CardBody>
      </Card>
    </GridItem>
  );
};

const ContentViewDetailsCard = ({ hostDetails }) => {
  if (hostDetails.content_facet_attributes) {
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
