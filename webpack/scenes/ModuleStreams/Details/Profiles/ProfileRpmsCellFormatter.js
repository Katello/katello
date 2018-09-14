import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { Icon } from 'patternfly-react';

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

    this.setState(
      { expanded: !this.state.expanded },
      () => {
        const showAmount = this.state.expanded ? rpms.length : this.minAmount;
        this.setState({ showAmount });
      },
    );
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
        {rpms.map(rpm => rpm.name).slice(0, this.state.showAmount).join(', ')}
        {largeList && !this.state.expanded && ', ...'}
      </td>
    );
  }
}

ProfileRpmsCellFormatter.propTypes = {
  rpms: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
};

export default ProfileRpmsCellFormatter;
