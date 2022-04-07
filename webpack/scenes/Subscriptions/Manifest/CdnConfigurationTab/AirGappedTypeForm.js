import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { useDispatch, useSelector } from 'react-redux';
import { FormattedMessage } from 'react-intl';
import {
  ActionGroup,
  Button,
  Form,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import { noop } from 'foremanReact/common/helpers';

import { AIRGAPPED } from './CdnConfigurationConstants';
import { updateCdnConfiguration } from '../../../Organizations/OrganizationActions';
import {
  selectUpdatingCdnConfiguration,
} from '../../../Organizations/OrganizationSelectors';

import './CdnConfigurationForm.scss';

const AirGappedTypeForm = ({ showUpdate, onUpdate }) => {
  const [updateEnabled, setUpdateEnabled] = useState(showUpdate);
  const updatingCdnConfiguration = useSelector(state => selectUpdatingCdnConfiguration(state));
  const dispatch = useDispatch();
  const performUpdate = () => {
    setUpdateEnabled(false);
    dispatch(updateCdnConfiguration({
      type: AIRGAPPED,
    }, onUpdate));
  };

  return (
    <Form isHorizontal>
      <div id="update-hint-cdn" className="margin-top-16">
        <p>
          <FormattedMessage
            id="cdn-configuration-type"
            defaultMessage={__('Red Hat content will be enabled and consumed via the {type} process.')}
            values={{
              type: <strong>{__('Import/Export')}</strong>,
            }}
          />
          <br />
          {showUpdate &&
            <FormattedMessage
              id="cdn-configuration-type-cdn"
              defaultMessage={__('Click {update} below to save changes.')}
              values={{
                update: <strong>{__('Update')}</strong>,
              }}
            />
          }
        </p>
      </div>

      <ActionGroup>
        <Button
          ouiaId="export-sync-configuration-update-button"
          aria-label="update-airgapped-configuration"
          variant="secondary"
          onClick={performUpdate}
          isDisabled={updatingCdnConfiguration || !updateEnabled}
          isLoading={updatingCdnConfiguration}
        >
          {__('Update')}
        </Button>
      </ActionGroup>
    </Form>
  );
};


AirGappedTypeForm.propTypes = {
  showUpdate: PropTypes.bool.isRequired,
  onUpdate: PropTypes.func,
};

AirGappedTypeForm.defaultProps = {
  onUpdate: noop,
};

export default AirGappedTypeForm;
