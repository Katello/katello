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
  } = props;

  const toggleSimpleContentAccess = () => {
    if (isSimpleContentAccessEnabled) {
      disableSimpleContentAccess();
    } else {
      enableSimpleContentAccess();
    }
  };

  return (
    <div id="simple-content-access">
      <Col sm={5}>
        <ControlLabel
          className="control-label"
          style={{ paddingTop: '0' }}
        >
          <Level>
            <LevelItem>
              <span className="sca-label">{__('Simple Content Access')}</span>
            </LevelItem>
            <LevelItem>
              <OverlayTrigger
                overlay={
                  <Tooltip id="sca-refresh-tooltip">
                    {__('When Simple Content Access is enabled, hosts are not required to have subscriptions attached to access repositories.')}
                  </Tooltip>
                }
                placement="bottom"
                trigger={['hover', 'focus']}
                rootClose={false}
              >
                <Icon type="pf" name="info" />
              </OverlayTrigger>
            </LevelItem>
          </Level>
        </ControlLabel>
      </Col>
      <Col sm={7}>
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
        <div>
          <i>{__('Toggling Simple Content Access will refresh your manifest.')}</i>
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
};

export default SimpleContentAccess;
