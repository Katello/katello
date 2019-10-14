import React from 'react';
import { translate as __ } from 'foremanReact/common/I18n';

const question = __('Are you sure you want to delete the manifest?');
const note = __(`Note: Deleting a subscription manifest is STRONGLY discouraged.
                 Deleting a manifest will:`);
const l1 = __('Delete all subscriptions that are attached to running hosts.');
const l2 = __('Delete all subscriptions attached to activation keys.');
const l3 = __('Disable Red Hat Insights.');
const l4 = __(`Require you to upload the subscription-manifest and re-attach
               subscriptions to hosts and activation keys.`);
const debug = __(`This action should only be taken in extreme circumstances or
                  for debugging purposes.`);

const DeleteManifestModalText = () => (
  <React.Fragment>
    <p>{question}</p>
    <p>{note}</p>
    <ul className="list-aligned">
      <li>{l1}</li>
      <li>{l2}</li>
      <li>{l3}</li>
      <li>{l4}</li>
    </ul>
    <p>{debug}</p>
  </React.Fragment>
);

export default DeleteManifestModalText;
