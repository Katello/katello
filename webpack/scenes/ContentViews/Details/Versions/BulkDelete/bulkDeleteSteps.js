import React from 'react';

import { translate as __ } from 'foremanReact/common/I18n';
import { PropTypes } from 'prop-types';

import {
  getNumberOfActivationKeys,
  getNumberOfEnvironments,
  getNumberOfHosts,
} from './BulkDeleteHelpers';
import ConfirmBulkDelete from './Steps/ConfirmBulkDelete';
import FinishBulkDelete from './Steps/FinishBulkDelete';
import ReassignActivationKeys from './Steps/ReassignActivationKeys';
import ReassignHosts from './Steps/ReassignHosts';
import ReviewEnvironments from './Steps/ReviewEnvironments';

const bulkDeleteSteps = ({
  versions,
  selectedCVForAK,
  selectedCVForHosts,
  currentStep,
}) => {
  const affectedEnvironmentCount = getNumberOfEnvironments(versions);
  const activationKeyCount = getNumberOfActivationKeys(versions);
  const hostCount = getNumberOfHosts(versions);
  const deleteSteps = [];

  if (affectedEnvironmentCount) {
    deleteSteps.push({
      name: affectedEnvironmentCount > 1 ?
        __('Review affected environments') :
        __('Review affected environment'),
      component: <ReviewEnvironments />,
    });
  }

  if (hostCount) {
    deleteSteps.push({
      name: hostCount > 1 ?
        __('Reassign affected hosts') :
        __('Reassign affected host'),
      component: <ReassignHosts />,
      enableNext: !!selectedCVForHosts,
    });
  }

  if (activationKeyCount) {
    deleteSteps.push({
      name: activationKeyCount > 1 ?
        __('Reassign affected activation keys') :
        __('Reassign affected activation key'),
      component: <ReassignActivationKeys />,
      enableNext: !!selectedCVForAK,
    });
  }

  deleteSteps.push(...[
    {
      name: __('Review details'),
      component: <ConfirmBulkDelete />,
      nextButtonText: __('Delete'),
    },
    {
      name: __('Finish'),
      component: <FinishBulkDelete />,
      isFinishedStep: true,
    },
  ]);

  // Add the id and canJumpTo to control incremental progress.
  return deleteSteps.map((step, index) =>
    ({ ...step, id: index + 1, canJumpTo: currentStep >= index + 1 }));
};

bulkDeleteSteps.propTypes = {
  context: PropTypes.shape({}).isRequired,
};

export default bulkDeleteSteps;
