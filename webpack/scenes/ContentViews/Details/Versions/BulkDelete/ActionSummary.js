import React from 'react';
import { PropTypes } from 'prop-types';
import {
  Flex,
  FlexItem,
  Label,
  Text,
  Icon,
} from '@patternfly/react-core';
import { ExclamationTriangleIcon } from '@patternfly/react-icons';
import {
  global_warning_color_100 as warningColor,
} from '@patternfly/react-tokens';

const ActionSummary = ({ title, text, selectedEnv: { name, id } }) => (
  <div>
    {title &&
      <h3 style={{ margin: '8px 0' }}><b>{title}</b></h3>
    }
    {text &&
      <Flex>
        <FlexItem style={{ marginRight: '8px' }}>
          <Icon color={warningColor.value}><ExclamationTriangleIcon /></Icon>
        </FlexItem>
        <FlexItem style={{ marginRight: '8px' }}>
          <Text ouiaId="action-summary-text">{text}</Text>
        </FlexItem>
        {name && id &&
          <FlexItem>
            <Label color="purple" href={`/lifecycle_environments/${id}`}>{name}</Label>
          </FlexItem>
        }
      </Flex>
    }
  </div>);


ActionSummary.propTypes = {
  title: PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.object, // React component
  ]),
  text: PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.object, // React component
  ]),
  selectedEnv: PropTypes.shape({
    id: PropTypes.number,
    name: PropTypes.string,
  }),
};

ActionSummary.defaultProps = {
  title: undefined,
  text: undefined,
  selectedEnv: {},
};

export default ActionSummary;
