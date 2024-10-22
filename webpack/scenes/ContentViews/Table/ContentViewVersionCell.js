import React from 'react';
import PropTypes from 'prop-types';
import { Flex, FlexItem } from '@patternfly/react-core';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import ComponentEnvironments from '../Details/ComponentContentViews/ComponentEnvironments';

const ContentViewVersionCell = ({
  id, latestVersion, latestVersionId, latestVersionEnvironments, rolling,
}) => (
  <Flex grow={{ default: 'grow' }}>
    { !rolling &&
      <FlexItem>
        <a href={urlBuilder(`content_views/${id}/versions/${latestVersionId}`, '')}>{`Version ${latestVersion}`}</a>
      </FlexItem>}
    <FlexItem>
      <ComponentEnvironments environments={latestVersionEnvironments} />
    </FlexItem>
  </Flex>
);

ContentViewVersionCell.propTypes = {
  id: PropTypes.number.isRequired,
  latestVersion: PropTypes.string.isRequired,
  latestVersionId: PropTypes.number,
  latestVersionEnvironments: PropTypes.instanceOf(Array),
  rolling: PropTypes.bool.isRequired,
};

ContentViewVersionCell.defaultProps = {
  latestVersionId: null,
  latestVersionEnvironments: [],
};

export default ContentViewVersionCell;

