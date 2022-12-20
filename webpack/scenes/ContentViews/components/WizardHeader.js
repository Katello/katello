import React from 'react';
import PropTypes from 'prop-types';
import { Grid, TextContent, Text, TextVariants, Flex, FlexItem } from '@patternfly/react-core';

const WizardHeader = ({
  title,
  description,
}) => (
  <Grid style={{ gridGap: '24px' }}>
    {title &&
      <TextContent>
        <Text ouiaId="wizard-header-text" component={TextVariants.h2}>{title}</Text>
      </TextContent>}
    {description &&
      <TextContent>
        <Flex flex={{ default: 'inlineFlex' }}>
          <FlexItem>
            <TextContent>
              {description}
            </TextContent>
          </FlexItem>
        </Flex>
      </TextContent>}
  </Grid>
);

WizardHeader.propTypes = {
  title: PropTypes.oneOfType([
    PropTypes.node,
    PropTypes.string,
  ]),
  description: PropTypes.oneOfType([
    PropTypes.node,
    PropTypes.string,
  ]),
};

WizardHeader.defaultProps = {
  title: undefined,
  description: undefined,
};


export default WizardHeader;
