import React from 'react';
import { useSelector } from 'react-redux';
import { translate as __ } from 'foremanReact/common/I18n';
import { Grid, GridItem, Flex, FlexItem, Tooltip } from '@patternfly/react-core';
import { InProgressIcon, OutlinedQuestionCircleIcon } from '@patternfly/react-icons';
import ContentViewIcon from './ContentViewIcon';
import { selectOrganizationState } from '../../Organizations/OrganizationSelectors';
import { contentViewDescriptions } from '../Create/CreateContentViewForm';

const ContentViewsCounter = () => {
  const organization = useSelector(selectOrganizationState);
  const {
    composite_content_views_count: composite,
    content_view_components_count: component,
    rolling_content_views_count: rolling,
  } = organization;
  if (composite || component || rolling) {
    return (
      <Grid>
        <GridItem span={12}>
          <b>
            <Flex>
              <FlexItem spacer={{ default: 'spacerXs' }}>
                <ContentViewIcon
                  composite={false}
                  rolling={false}
                  description={__('Content views')}
                  count={(component || component === 0) ? component : <InProgressIcon />}
                />
              </FlexItem>
              <FlexItem>
                <Tooltip
                  position="top"
                  content={contentViewDescriptions.CV}
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
                <ContentViewIcon
                  composite
                  description={__('Composite content views')}
                  count={(composite || composite === 0) ? composite : <InProgressIcon />}
                />
              </FlexItem>
              <FlexItem>
                <Tooltip
                  position="top"
                  content={contentViewDescriptions.CCV}
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
                <ContentViewIcon
                  rolling
                  description={__('Rolling content views')}
                  count={(rolling || rolling === 0) ? rolling : <InProgressIcon />}
                />
              </FlexItem>
              <FlexItem>
                <Tooltip
                  position="top"
                  content={contentViewDescriptions.RCV}
                >
                  <OutlinedQuestionCircleIcon />
                </Tooltip>
              </FlexItem>
            </Flex>
          </b>
        </GridItem>
      </Grid>
    );
  } return <></>;
};

export default ContentViewsCounter;
