import React from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import { urlBuilder } from 'foremanReact/common/urlHelpers';
import { getResponseErrorMsgs } from '../../utils/helpers';

export const bulkSearchKey = key => `${key}_TASK_SEARCH`;
export const pollTaskKey = key => `${key}_POLL_TASK`;

const link = id => ({
  children: __('Go to task page'),
  href: urlBuilder('foreman_tasks/tasks', '', id),
});
const getErrors = task => (
  <ul>
    {task.humanized.errors.map(e => (
      <li key={e}> {e} </li>
    ))}
  </ul>
);

export const renderTaskStartedToast = (task) => {
  if (!task) return;

  const message = (__(`Task ${task.humanized.action} has started.`));

  window.tfm.toastNotifications.notify({
    message,
    type: 'info',
    link: link(task.id),

  });
};

export const taskFinishedToast = (task) => {
  const message = __(`Task ${task.humanized.action} completed with a result of ${task.result}.
  ${task.errors ? getErrors(task) : ''}`);

  return {
    message,
    type: task.result,
    link: link(task.id),
  };
};

export const renderTaskFinishedToast = (task) => {
  if (!task) return;

  window.tfm.toastNotifications.notify(taskFinishedToast(task));
};

export const errorToast = error => getResponseErrorMsgs(error.response);
