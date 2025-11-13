import React from 'react';
import PropTypes from 'prop-types';
import { Modal, ModalVariant, Button, TextContent, Text } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import ManifestRepositoriesTable from './ManifestRepositoriesTable';

const PullablePathsModal = ({
  show, setIsOpen, repositories, tagName,
}) => {
  const handleClose = () => {
    setIsOpen(false);
  };

  return (
    <Modal
      ouiaId="pullable-paths-modal"
      title={__('Copy pullable paths')}
      variant={ModalVariant.large}
      isOpen={show}
      onClose={handleClose}
      appendTo={document.body}
      actions={[
        <Button key="close" variant="primary" onClick={handleClose} ouiaId="pullable-paths-close-button">
          {__('Close')}
        </Button>,
      ]}
    >
      <>
        <TextContent>
          <Text ouiaId="pullable-paths-description">
            {__('Copy this to pull the specific image version from your published content view, ensuring consistency across your deployments.')}
          </Text>
        </TextContent>
        <ManifestRepositoriesTable repositories={repositories} tagName={tagName} />
      </>
    </Modal>
  );
};

PullablePathsModal.propTypes = {
  show: PropTypes.bool,
  setIsOpen: PropTypes.func.isRequired,
  repositories: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.number,
    name: PropTypes.string,
    full_path: PropTypes.string,
    product_id: PropTypes.number,
    kt_environment: PropTypes.shape({
      id: PropTypes.number,
      name: PropTypes.string,
    }),
    content_view_version: PropTypes.shape({
      id: PropTypes.number,
      name: PropTypes.string,
      content_view_id: PropTypes.number,
    }),
  })),
  tagName: PropTypes.string,
};

PullablePathsModal.defaultProps = {
  show: false,
  repositories: [],
  tagName: '',
};

export default PullablePathsModal;
