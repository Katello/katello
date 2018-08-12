import React from 'react';
import ReactDOMServer from 'react-dom/server';
import { sprintf } from 'jed';
import helpers from '../../move_to_foreman/common/helpers';
import { notify } from '../../move_to_foreman/foreman_toast_notifications';

const getErrors = task => (
  <ul>
    {task.humanized.errors.map(error => (
      <li key={error}> {error} </li>
        ))}
  </ul>
);

export const renderTaskStartedToast = (task) => {
  const message = (
    <span>
      <span>
        {sprintf('Task %s has started.', task.humanized.action)}
        {' '}
      </span>
      <a href={helpers.urlBuilder('foreman_tasks/tasks', '', task.id)}>
        {__('Click here to go to the tasks page for the task.')}
      </a>
    </span>
  );

  notify({
    message: ReactDOMServer.renderToStaticMarkup(message),
    type: 'info',
  });
};

export const renderTaskFinishedToast = (task, orgName) => {
  const message = (
    <span>
      <span>
        {`${__(`Task ${task.humanized.action} completed with a result of ${task.result} in organization ${orgName}.`)} `}
        {' '}
      </span>
      {task.errors ? getErrors(task) : ''}
      <a href={helpers.urlBuilder('foreman_tasks/tasks', '', task.id)}>
        {__('Click here to go to the tasks page for the task.')}
      </a>
    </span>
  );

  notify({
    message: ReactDOMServer.renderToStaticMarkup(message),
    type: task.result,
  });
};
