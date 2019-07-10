import React from 'react';
import PropTypes from 'prop-types';
import { Modal, ProgressBar } from 'patternfly-react';
import { sprintf } from 'foremanReact/common/I18n';

const ModalProgressBar = (props) => {
  const { show, container, task } = props;
  let modalTitle = null;
  let progress = 0;

  if (task) {
    modalTitle = task.humanized.action;
    progress = Math.round(task.progress * 100);
  }

  return (
    <Modal id="modal-progress-bar" show={show} container={container}>
      <Modal.Header>
        <Modal.Title>{modalTitle}</Modal.Title>
      </Modal.Header>
      <Modal.Body>
        <ProgressBar
          active
          now={progress}
          label={sprintf(__('%(progress)s%% Complete'), { progress })}
        />
      </Modal.Body>
    </Modal>
  );
};

ModalProgressBar.propTypes = {
  show: PropTypes.bool.isRequired,
  container: PropTypes.shape({}),
  task: PropTypes.shape({
    progress: PropTypes.number,
    humanized: PropTypes.shape({
      action: PropTypes.string,
    }),
  }),
};

ModalProgressBar.defaultProps = {
  container: document.body,
  task: { humanized: {} },
};

export default ModalProgressBar;
