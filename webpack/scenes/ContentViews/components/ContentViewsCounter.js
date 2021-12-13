import React from 'react';
import { useSelector } from 'react-redux';
import { translate as __ } from 'foremanReact/common/I18n';
import { Grid, GridItem, Flex, FlexItem, Tooltip } from '@patternfly/react-core';
import { InProgressIcon, OutlinedQuestionCircleIcon } from '@patternfly/react-icons';
import ContentViewIcon from './ContentViewIcon';
import { selectOrganizationState } from '../../Organizations/OrganizationSelectors';

const ContentViewsCounter = () => {
  const organization = useSelector(selectOrganizationState);
  const {
    composite_content_views_count: composite,
    content_view_components_count: component,
  } = organization;
  return (
    <Grid>
      <GridItem span={12}>
        <b>
          <Flex>
            <FlexItem spacer={{ default: 'spacerXs' }}>
              <ContentViewIcon composite={false} description={__('Component content views')} count={(component || component === 0) ? component : <InProgressIcon />} />
            </FlexItem>
            <FlexItem>
              <Tooltip
                position="top"
                content={
                  __('Consists of repositories')
                }
              >
                <OutlinedQuestionCircleIcon />
              </Tooltip>
            </FlexItem>
          </Flex>
        </b>
      </GridItem>
      <GridItem span={12}>
        <b>
          <Flex>
            <FlexItem spacer={{ default: 'spacerXs' }}>
              <ContentViewIcon composite description={__('Composite content views')} count={(composite || composite === 0) ? composite : <InProgressIcon />} />
            </FlexItem>
            <FlexItem>
              <Tooltip
                position="top"
                content={
                  __('Consists of content views')
                }
              >
                <OutlinedQuestionCircleIcon />
              </Tooltip>
            </FlexItem>
          </Flex>
        </b>
      </GridItem>
    </Grid>
  );
};

export default ContentViewsCounter;
