import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { Spinner } from 'patternfly-react';
import './LoadingState.scss';

class LoadingState extends Component {
  constructor(props) {
    super(props);
    this.state = {
      render: false,
    };
  }

  componentDidMount() {
    setTimeout(() => {
      this.setState({ render: true });
    }, this.props.timeout);
  }

  render() {
    const { loading, loadingText, children } = this.props;
    const spinner = (
      <div className="loading-state">
        <Spinner loading={loading} size="lg" />
        <p>{loadingText}</p>
      </div>);

    if (loading) {
      return this.state.render ? spinner : null;
    }
    return children;
  }
}
LoadingState.propTypes = {
  loading: PropTypes.bool,
  loadingText: PropTypes.string,
  children: PropTypes.node,
  timeout: PropTypes.number,
};

LoadingState.defaultProps = {
  loading: false,
  loadingText: __('Loading'),
  children: null,
  timeout: 300,
};

export default LoadingState;
