import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';

const DeleteManifestModalText = ({ simpleContentAccess }) => (
  <React.Fragment>
    <p>{__('Are you sure you want to delete the manifest?')}</p>
    {simpleContentAccess && (
      <>
        <p>{__('Note: Deleting a subscription manifest is STRONGLY discouraged.')}</p>
        <p>{__('This action should only be taken for debugging purposes.')}</p>
      </>
    )}
    {!simpleContentAccess && (
      <>
        <p>
          {__(`Note: Deleting a subscription manifest is STRONGLY discouraged.
        Deleting a manifest will:`)}
        </p>
        <ul className="list-aligned">
          <li>{__('Delete all subscriptions that are attached to running hosts.')}</li>
          <li>{__('Delete all subscriptions attached to activation keys.')}</li>
          <li>{__('Disable Red Hat Insights.')}</li>
          <li>
            {__(`Require you to upload the subscription-manifest and re-attach
              subscriptions to hosts and activation keys.`)}
          </li>
        </ul>
        <p>
          {__(`This action should only be taken in extreme circumstances or
              for debugging purposes.`)}
        </p>
      </>
    )}
  </React.Fragment>
);

DeleteManifestModalText.propTypes = {
  simpleContentAccess: PropTypes.bool,
};

DeleteManifestModalText.defaultProps = {
  simpleContentAccess: false,
};

export default DeleteManifestModalText;
