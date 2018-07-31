// This component should be replaced with a react version
/* eslint-disable */
import React from 'react';
import ReactDOM from 'react-dom';
import { FormControl } from 'react-bootstrap';
import PropTypes from 'prop-types';

require('jquery');
require('bootstrap-select');

class BootstrapSelect extends React.Component {
  constructor(props) {
    super(props);
    this.state = { open: false };
  }

  componentDidMount() {
    this.body = $('body');
    this.select = $(ReactDOM.findDOMNode(this));
    this.select.selectpicker();

    this.container = this.select.parent();
    this.button = this.container.find('button');
    this.items = this.container.find('ul.dropdown-menu li a');

    this.body.click(() => {
      this.setState({ open: false });
    });

    this.button.click(e => {
      e.stopPropagation();
      this.setState({ open: !this.state.open });
    });

    this.items.click(() => {
      if (this.props.multiple) return;
      this.setState({ open: !this.state.open });
    });
  }

  componentDidUpdate() {
    this.select.selectpicker('refresh');
    this.container.toggleClass('open', this.state.open);
  }

  componentWillUnmount() {
    this.body.off('click');
    this.button.off('click');
    this.items.off('click');
    this.select.selectpicker('destroy');
  }

  render() {
    // TODO: these classes are required because foreman assumes that all selects should use select2 and jquery multiselect
    // TODO: see also http://projects.theforeman.org/issues/21952
    const { noneSelectedText } = this.props;

    return <FormControl {...this.props}
                        data-none-selected-text={noneSelectedText}
                        data-selected-text-format="count>3"
                        data-count-selected-text={__('{0} items selected')}
                        componentClass="select"
                        className="without_select2 without_jquery_multiselect"
    />;
  }
}

BootstrapSelect.propTypes = {
  noneSelectedText: PropTypes.string,
}

BootstrapSelect.defaultProps = {
  noneSelectedText: __('Nothing selected'),
}

export default BootstrapSelect;
