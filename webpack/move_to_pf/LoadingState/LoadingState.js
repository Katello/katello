import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { Spinner } from 'patternfly-react';
import './LoadingState.scss';

/* eslint-disable no-underscore-dangle */
class LoadingState extends Component {
  constructor(props) {
    super(props);
    this.state = {
      render: false,
    };
  }

  componentDidMount() {
    this._ismounted = true;

    setTimeout(() => {
      // Check if mounted to avoid updating the state on an unmounted component
      if (this._ismounted) {
        this.setState({ render: true });
      }
    }, this.props.timeout);
  }

  componentWillUnmount() {
    this._ismounted = false;
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

/* eslint-enable no-underscore-dangle */
export default LoadingState;
