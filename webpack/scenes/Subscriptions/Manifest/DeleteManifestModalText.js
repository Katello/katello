import React from 'react';
import { translate as __ } from 'foremanReact/common/I18n';

const DeleteManifestModalText = () => (
  <React.Fragment>
    <p>{__('Are you sure you want to delete the manifest?')}</p>
    <>
      <p>{__('Note: Deleting a subscription manifest is STRONGLY discouraged.')}</p>
      <p>{__('This action should only be taken for debugging purposes.')}</p>
    </>
  </React.Fragment>
);

export default DeleteManifestModalText;
