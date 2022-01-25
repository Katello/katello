import React, { useState } from 'react';
import PropTypes from 'prop-types';

import {
  ToggleGroup,
  ToggleGroupItem,
} from '@patternfly/react-core';
import { noop } from 'foremanReact/common/helpers';
import CdnTypeForm from './CdnTypeForm';
import AirGappedTypeForm from './AirGappedTypeForm';
import UpstreamServerTypeForm from './UpstreamServerTypeForm';

import './CdnConfigurationForm.scss';
import { CDN_URL, CDN, AIRGAPPED, UPSTREAM_SERVER, CDN_CONFIGURATION_TYPES } from './CdnConfigurationConstants';

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

  const cdnUrl = type !== cdnConfiguration.type ? CDN_URL : cdnConfiguration.url;

  return (
    <div id="cdn-configuration">
      <ToggleGroup aria-label="Default with multiple selectable">
        <ToggleGroupItem text={CDN_CONFIGURATION_TYPES[CDN]} key={0} buttonId="cdn" isSelected={type === CDN} onChange={() => updateType(CDN)} />
        <ToggleGroupItem
          text={CDN_CONFIGURATION_TYPES[UPSTREAM_SERVER]}
          key={1}
          buttonId="usptream_server"
          isSelected={type === UPSTREAM_SERVER}
          onChange={() => updateType(UPSTREAM_SERVER)}
        />
        <ToggleGroupItem text={CDN_CONFIGURATION_TYPES[AIRGAPPED]} key={2} buttonId="airgapped" isSelected={type === AIRGAPPED} onChange={() => updateType(AIRGAPPED)} />
      </ToggleGroup>

      { type === UPSTREAM_SERVER &&
        <UpstreamServerTypeForm
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
          url={cdnUrl}
        />
      }
      { type === AIRGAPPED &&
        <AirGappedTypeForm
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
