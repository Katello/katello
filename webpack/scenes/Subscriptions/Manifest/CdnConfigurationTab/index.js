import React, { useState } from 'react';
import PropTypes from 'prop-types';

import {
  ToggleGroup,
  ToggleGroupItem,
} from '@patternfly/react-core';
import { noop } from 'foremanReact/common/helpers';
import CdnTypeForm from './CdnTypeForm';
import ExportSyncForm from './ExportSyncForm';
import NetworkSyncForm from './NetworkSyncForm';
import CustomCdnTypeForm from './CustomCdnTypeForm';
import './CdnConfigurationForm.scss';
import { CDN, EXPORT_SYNC, CUSTOM_CDN, NETWORK_SYNC, CDN_CONFIGURATION_TYPES } from './CdnConfigurationConstants';

const CdnConfigurationForm = (props) => {
  const {
    contentCredentials,
    cdnConfiguration,
    onUpdate,
  } = props;

  const [type, setType] = useState(cdnConfiguration.type);

  const updateType = (connectionType) => {
    if (type !== connectionType) {
      setType(connectionType);
    }
  };

  return (
    <div id="cdn-configuration">
      <ToggleGroup aria-label="Default with multiple selectable">
        <ToggleGroupItem text={CDN_CONFIGURATION_TYPES[CDN]} key={0} buttonId="cdn" isSelected={type === CDN} onChange={() => updateType(CDN)} />
        <ToggleGroupItem
          text={CDN_CONFIGURATION_TYPES[CUSTOM_CDN]}
          key={1}
          buttonId="customCdn"
          isSelected={type === CUSTOM_CDN}
          onChange={() => updateType(CUSTOM_CDN)}
        />
        <ToggleGroupItem
          text={CDN_CONFIGURATION_TYPES[NETWORK_SYNC]}
          key={2}
          buttonId="usptream_server"
          isSelected={type === NETWORK_SYNC}
          onChange={() => updateType(NETWORK_SYNC)}
        />
        <ToggleGroupItem text={CDN_CONFIGURATION_TYPES[EXPORT_SYNC]} key={3} buttonId="airgapped" isSelected={type === EXPORT_SYNC} onChange={() => updateType(EXPORT_SYNC)} />
      </ToggleGroup>

      { type === NETWORK_SYNC &&
        <NetworkSyncForm
          cdnConfiguration={cdnConfiguration}
          contentCredentials={contentCredentials}
          onUpdate={onUpdate}
          showUpdate={type !== cdnConfiguration.type}
        />
      }

      { type === CDN &&
        <CdnTypeForm
          showUpdate={type !== cdnConfiguration.type}
          onUpdate={onUpdate}
        />
      }
      { type === CUSTOM_CDN &&
        <CustomCdnTypeForm
          cdnConfiguration={cdnConfiguration}
          contentCredentials={contentCredentials}
          showUpdate={type !== cdnConfiguration.type}
          onUpdate={onUpdate}
        />
      }

      { type === EXPORT_SYNC &&
        <ExportSyncForm
          showUpdate={type !== cdnConfiguration.type}
          onUpdate={onUpdate}
        />
      }
    </div>
  );
};

CdnConfigurationForm.propTypes = {
  contentCredentials: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.number,
    name: PropTypes.string,
  })),
  cdnConfiguration: PropTypes.shape({
    type: PropTypes.string,
    url: PropTypes.string,
    username: PropTypes.string,
    upstream_organization_label: PropTypes.string,
    upstream_content_view_label: PropTypes.string,
    upstream_lifecycle_environment_label: PropTypes.string,
    ssl_ca_credential_id: PropTypes.number,
    password_exists: PropTypes.bool,
  }),
  onUpdate: PropTypes.func,
};

CdnConfigurationForm.defaultProps = {
  contentCredentials: [],
  cdnConfiguration: {},
  onUpdate: noop,
};

export default CdnConfigurationForm;
