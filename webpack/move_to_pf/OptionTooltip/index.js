import React, { Component } from '@theforeman/vendor/react';
import PropTypes from '@theforeman/vendor/prop-types';
import classNames from '@theforeman/vendor/classnames';
import { Popover, OverlayTrigger } from '@theforeman/vendor/patternfly-react';
import './OptionTooltip.scss';

class OptionTooltip extends Component {
  constructor(props) {
    super(props);

    this.state = {
      tooltipOpen: false,
    };
    this.handleInputChange = this.handleInputChange.bind(this);
    this.renderTooltip = this.renderTooltip.bind(this);
  }

  handleInputChange(event, index) {
    const { options } = this.props;
    options[index].value = event.target.checked;
    this.setState(options);
    this.props.onChange(options);
  }
  renderTooltip() {
    const { options, id } = this.props;
    return (
      <Popover id={id} className="option-tooltip">
        <ul>
          {
            options.map((option, index) => (
              <li key={option.key}>
                <input type="checkbox" checked={option.value} name={option.key} id={option.key} onChange={e => this.handleInputChange(e, index)} />
                <span>{option.label}</span>
              </li>
            ))
          }
        </ul>
      </Popover>
    );
  }
  render() {
    const { icon, options, rootClose } = this.props;
    const onOpen = () => {
      this.setState({ tooltipOpen: true });
    };
    const onClose = () => {
      this.props.onClose(options);
      this.setState({ tooltipOpen: false });
    };

    return (
      <OverlayTrigger
        overlay={this.renderTooltip()}
        placement="bottom"
        trigger={['click']}
        rootClose={rootClose}
        onEnter={onOpen}
        onExit={onClose}
      >
        <i className={classNames('fa', icon, 'tooltip-button', { 'tooltip-open': this.state.tooltipOpen })} />
      </OverlayTrigger>
    );
  }
}

OptionTooltip.propTypes = {
  icon: PropTypes.string.isRequired,
  id: PropTypes.string.isRequired,
  options: PropTypes.arrayOf(PropTypes.shape({
    key: PropTypes.string,
    label: PropTypes.string,
    value: PropTypes.bool,
  })).isRequired,
  onChange: PropTypes.func,
  onClose: PropTypes.func,
  rootClose: PropTypes.bool,
};
OptionTooltip.defaultProps = {
  onChange: () => {},
  onClose: () => {},
  rootClose: true,
};
export default OptionTooltip;
