import React, { Component } from 'react';
import { FormControl } from 'patternfly-react';

import { commonInputPropTypes } from '../helpers/commonPropTypes';

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

TypeAheadInput.propTypes = commonInputPropTypes;

export default TypeAheadInput;
