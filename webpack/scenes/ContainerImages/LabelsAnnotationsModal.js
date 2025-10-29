import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  Modal,
  ModalVariant,
  Button,
  Label,
  Flex,
  FlexItem,
} from '@patternfly/react-core';

const LabelsAnnotationsModal = ({
  show, setIsOpen, digest, labels, annotations,
}) => {
  const INITIAL_DISPLAY_COUNT = 10;
  const [showAll, setShowAll] = useState(false);

  const handleClose = () => {
    setShowAll(false);
    setIsOpen(false);
  };

  // Combine labels and annotations into a single array of key-value pairs
  const allItems = [
    ...Object.entries(labels || {}).map(([key, value]) => ({
      key: `label-${key}`,
      value: `${key}=${value}`,
    })),
    ...Object.entries(annotations || {}).map(([key, value]) => ({
      key: `annotation-${key}`,
      value: `${key}=${value}`,
    })),
  ];

  const totalCount = allItems.length;
  const displayedItems = showAll ? allItems : allItems.slice(0, INITIAL_DISPLAY_COUNT);
  const remainingCount = totalCount - INITIAL_DISPLAY_COUNT;

  return (
    <Modal
      ouiaId="labels-annotations-modal"
      title={__('Labels and annotations')}
      variant={ModalVariant.medium}
      isOpen={show}
      onClose={handleClose}
      appendTo={document.body}
      actions={[
        <Button key="close" variant="link" onClick={handleClose} ouiaId="labels-annotations-close-button">
          {__('Close')}
        </Button>,
      ]}
    >
      <div>
        <p>
          {__('View labels and annotations for image ')}
          <strong>{digest}</strong>.
        </p>
        <p style={{ marginTop: '16px', fontWeight: 'bold' }}>
          {__(`${totalCount} labels and annotations`)}
        </p>
        <Flex
          spaceItems={{ default: 'spaceItemsSm' }}
          style={{ marginTop: '16px' }}
          direction={{ default: 'row' }}
          flexWrap={{ default: 'wrap' }}
        >
          {displayedItems.map(item => (
            <FlexItem key={item.key}>
              <Label>{item.value}</Label>
            </FlexItem>
          ))}
        </Flex>
        {!showAll && remainingCount > 0 && (
          <Button
            variant="link"
            isInline
            onClick={() => setShowAll(true)}
            style={{ marginTop: '16px', padding: 0 }}
            ouiaId="show-more-labels-annotations-button"
          >
            {__(`Show ${remainingCount} more`)}
          </Button>
        )}
      </div>
    </Modal>
  );
};

LabelsAnnotationsModal.propTypes = {
  show: PropTypes.bool,
  setIsOpen: PropTypes.func.isRequired,
  digest: PropTypes.string,
  labels: PropTypes.objectOf(PropTypes.string),
  annotations: PropTypes.objectOf(PropTypes.string),
};

LabelsAnnotationsModal.defaultProps = {
  show: false,
  digest: '',
  labels: {},
  annotations: {},
};

export default LabelsAnnotationsModal;
