import React from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { useSelector } from 'react-redux';
import { translate as __ } from 'foremanReact/common/I18n';
import { Grid, GridItem, Flex, FlexItem, TextContent, Text, TextVariants, Tooltip } from '@patternfly/react-core';
import { InProgressIcon, OutlinedQuestionCircleIcon } from '@patternfly/react-icons';
import ContentViewIcon from "./ContentViewIcon";
import {selectContentViewError, selectContentViews, selectContentViewStatus} from "../ContentViewSelectors";

const ContentViewsCounter = () => {
  const response = useSelector(selectContentViews);
  const status = useSelector(selectContentViewStatus);
  const error = useSelector(selectContentViewError);
  const {composite, component} = response;
  return (
    <Grid className="grid-with-margin">
      <GridItem span={12}>
        <b>
          <Flex>
            <FlexItem spacer={{ default: 'spacerXs' }}>
              <ContentViewIcon composite={false} description={__('Component content views')} count={component || <InProgressIcon/>}/>
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
              <ContentViewIcon composite={true} description={__('Composite content views')} count={composite || <InProgressIcon/>}/>
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
