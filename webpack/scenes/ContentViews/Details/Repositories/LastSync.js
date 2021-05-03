/* eslint-disable translation/no-strings-without-translations */
import React, { Fragment } from 'react';
import { CheckCircleIcon, ExclamationTriangleIcon, CloseIcon } from '@patternfly/react-icons';
import { foremanUrl } from 'foremanReact/common/helpers';
import { translate as __ } from 'foremanReact/common/I18n';
import PropTypes from 'prop-types';

const LastSync = ({ lastSyncWords, lastSync }) => {
  if (lastSync && lastSyncWords) {
    let Icon;
    let color = 'black';
    const { result, id } = lastSync;

    if (result === 'success') {
      Icon = CheckCircleIcon;
      color = 'green';
    } else if (result === 'warning') {
      Icon = ExclamationTriangleIcon;
      color = 'orange';
    } else if (result === 'error') {
      Icon = CloseIcon;
      color = 'red';
    } else {
      Icon = Fragment;
    }

    return (
      <a href={foremanUrl(`/foreman_tasks/tasks/${id}/`)}>
        <Icon style={{ color }} />&nbsp;{`${lastSyncWords} ago`}
      </a>
    );
  }
  return <div>{__('Not Synced')}</div>;
};

LastSync.propTypes = {
  lastSyncWords: PropTypes.string,
  lastSync: PropTypes.shape({
    id: PropTypes.string, // API returns string
    result: PropTypes.string,
  }),
};

LastSync.defaultProps = {
  lastSyncWords: null,
  lastSync: null,
};

export default LastSync;
