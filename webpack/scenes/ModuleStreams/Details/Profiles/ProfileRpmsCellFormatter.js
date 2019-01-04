import React, { Component } from '@theforeman/vendor/react';
import PropTypes from '@theforeman/vendor/prop-types';
import { Icon } from '@theforeman/vendor/patternfly-react';

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

  iconName = () => (this.state.expanded ? 'angle-down' : 'angle-right');

  render() {
    const { rpms } = this.props;
    const largeList = rpms.length > this.minAmount;

    return (
      <td>
        {largeList && <Icon
          className="expand-profile-rpms"
          onClick={this.onClick}
          name={this.iconName()}
        />}
        {rpms
          .slice(0, this.state.showAmount)
          .map(rpm => rpm.name)
          .join(', ')}
        {largeList && !this.state.expanded && ', ...'}
      </td>
    );
  }
}

ProfileRpmsCellFormatter.propTypes = {
  rpms: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
};

export default ProfileRpmsCellFormatter;
