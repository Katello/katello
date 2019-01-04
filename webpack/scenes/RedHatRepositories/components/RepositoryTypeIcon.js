import React from '@theforeman/vendor/react';
import PropTypes from '@theforeman/vendor/prop-types';
import { ListView, OverlayTrigger, Tooltip } from '@theforeman/vendor/patternfly-react';

import { getTypeIcon } from '../../../services/index';

export default class RepositoryTypeIcon extends React.Component {
  constructor(props) {
    super(props);

    this.tooltipId = `type-tooltip-${props.id}`;
  }

  render() {
    const typeIcon = getTypeIcon(this.props.type);

    return (
      <OverlayTrigger
        overlay={<Tooltip id={this.tooltipId}>{this.props.type}</Tooltip>}
        placement="bottom"
        trigger={['hover', 'focus']}
        rootClose={false}
      >
        <ListView.Icon name={typeIcon.name} size="sm" type={typeIcon.type} />
      </OverlayTrigger>
    );
  }
}

RepositoryTypeIcon.propTypes = {
  id: PropTypes.number.isRequired,
  type: PropTypes.string.isRequired,
};
