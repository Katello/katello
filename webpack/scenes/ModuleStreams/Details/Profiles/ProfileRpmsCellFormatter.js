import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { AngleRightIcon, AngleDownIcon } from '@patternfly/react-icons';
import { Button } from '@patternfly/react-core';

import './ProfileRpmsCellFormatter.scss';

class ProfileRpmsCellFormatter extends Component {
  constructor(props) {
    super(props);
    this.minAmount = 10;
    this.state = {
      expanded: false,
      showAmount: this.minAmount,
    };
  }

  onClick = () => {
    const { rpms } = this.props;

    this.setState(state => ({
      expanded: !state.expanded,
      showAmount: !state.expanded ? rpms.length : this.minAmount,
    }));
  };

  render() {
    const { rpms, profileId } = this.props;
    const largeList = rpms.length > this.minAmount;
    const Icon = this.state.expanded ? AngleDownIcon : AngleRightIcon;

    return (
      <>
        {largeList && (
          <Button
            variant="plain"
            className="expand-profile-rpms"
            onClick={this.onClick}
            aria-label={this.state.expanded ? 'Collapse' : 'Expand'}
            ouiaId={`expand-profile-rpms-button-${profileId}`}
          >
            <Icon />
          </Button>
        )}
        {rpms
          .slice(0, this.state.showAmount)
          .map(rpm => rpm.name)
          .join(', ')}
        {largeList && !this.state.expanded && ', ...'}
      </>
    );
  }
}

ProfileRpmsCellFormatter.propTypes = {
  rpms: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  profileId: PropTypes.number.isRequired,
};

export default ProfileRpmsCellFormatter;
