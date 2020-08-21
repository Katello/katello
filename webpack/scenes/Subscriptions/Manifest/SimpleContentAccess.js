import React from 'react';
import PropTypes from 'prop-types';
import { Switch, Level, LevelItem } from '@patternfly/react-core';
import { OverlayTrigger, Tooltip, Icon } from 'patternfly-react';
import { translate as __ } from 'foremanReact/common/I18n';
import { Col, ControlLabel } from 'react-bootstrap';

const SimpleContentAccess = (props) => {
  const {
    canToggleSimpleContentAccess,
    isSimpleContentAccessEnabled,
    enableSimpleContentAccess,
    disableSimpleContentAccess,
    infoMessage,
    colWidths,
  } = props;

  const toggleSimpleContentAccess = () => {
    if (isSimpleContentAccessEnabled) {
      disableSimpleContentAccess();
    } else {
      enableSimpleContentAccess();
    }
  };

  return (
    <div id="simple-content-access" style={{ display: 'flex' }}>
      <Col sm={colWidths.left}>
        <ControlLabel
          className="control-label"
          style={{ paddingTop: '0' }}
        >
          <Level
            style={{
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'flex-end',
            }}
          >
            <LevelItem>
              <span className="sca-label">{__('Simple Content Access')}</span>
            </LevelItem>
            <LevelItem>
              <OverlayTrigger
                overlay={
                  <Tooltip id="sca-refresh-tooltip">
                    {__('When Simple Content Access is enabled, hosts can consume from all repositories in their Content View regardless of subscription status.')}
                  </Tooltip>
                }
                placement="bottom"
                trigger={['hover', 'focus']}
                rootClose={false}
              >
                <Icon type="pf" name="info" style={{ marginRight: '0px' }} />
              </OverlayTrigger>
            </LevelItem>
          </Level>
        </ControlLabel>
      </Col>
      <Col sm={colWidths.right} style={colWidths.right === 4 ? { paddingLeft: '5px' } : undefined}>
        <div id="manifest-toggle-sca-switch">
          <Switch
            id="simple-switch"
            isChecked={isSimpleContentAccessEnabled}
            onChange={toggleSimpleContentAccess}
            isDisabled={!canToggleSimpleContentAccess}
            data-testid="switch"
            label=" "
          />
        </div>
        <div id="sca-info-message" style={{ marginTop: '6px' }}>
          <i>{infoMessage}</i>
        </div>
      </Col>
    </div>
  );
};

SimpleContentAccess.propTypes = {
  enableSimpleContentAccess: PropTypes.func.isRequired,
  disableSimpleContentAccess: PropTypes.func.isRequired,
  isSimpleContentAccessEnabled: PropTypes.bool.isRequired,
  canToggleSimpleContentAccess: PropTypes.bool.isRequired,
  infoMessage: PropTypes.string,
  colWidths: PropTypes.shape({
    left: PropTypes.number,
    right: PropTypes.number,
  }),
};

SimpleContentAccess.defaultProps = {
  infoMessage: __('Toggling Simple Content Access will refresh your manifest.'),
  colWidths: { left: 5, right: 7 },
};

export default SimpleContentAccess;
