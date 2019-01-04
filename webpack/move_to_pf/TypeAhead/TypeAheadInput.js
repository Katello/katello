import React, { Component } from '@theforeman/vendor/react';
import PropTypes from '@theforeman/vendor/prop-types';
import { FormControl } from '@theforeman/vendor/patternfly-react';

class TypeAheadInput extends Component {
  constructor(props) {
    super(props);
    this.handleKeyPress = this.handleKeyPress.bind(this);
  }

  componentDidMount() {
    if (this.ref) {
      this.ref.addEventListener('keydown', this.handleKeyPress);
    }
  }

  componentWillUnmount() {
    if (this.ref) {
      this.ref.removeEventListener('keydown', this.handleKeyPress);
    }
  }

  handleKeyPress(e) {
    this.props.onKeyPress(e);
  }

  render() {
    return (
      <FormControl
        inputRef={(ref) => {
          this.ref = ref;
        }}
        onFocus={this.props.onInputFocus}
        type="text"
        {...this.props.passedProps}
      />
    );
  }
}

TypeAheadInput.propTypes = {
  passedProps: PropTypes.shape({}).isRequired,
  onKeyPress: PropTypes.func.isRequired,
  onInputFocus: PropTypes.func.isRequired,
};

export default TypeAheadInput;
