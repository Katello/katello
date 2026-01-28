import React from 'react';
import PropTypes from 'prop-types';
import {
  Button,
  TextContent,
  Text,
  TextVariants,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';

/**
 * Shared button component for adding another content view environment assignment
 */
export const AddAnotherCVButton = ({ onClick, isDisabled }) => (
  <>
    <hr style={{ margin: '1rem 0' }} />
    <Button
      variant="link"
      icon={<span style={{ fontSize: '1.2em', marginRight: '0.5rem' }}>+</span>}
      onClick={onClick}
      ouiaId="assign-another-cv-button"
      style={{ paddingLeft: 0 }}
      isDisabled={isDisabled}
    >
      {__('Assign another content view environment')}
    </Button>
  </>
);

AddAnotherCVButton.propTypes = {
  onClick: PropTypes.func.isRequired,
  isDisabled: PropTypes.bool.isRequired,
};

/**
 * Shared modal description that explains content view environments
 */
export const AssignmentModalDescription = ({ allowMultipleContentViews }) => (
  <TextContent style={{ marginBottom: '1rem' }}>
    <Text component={TextVariants.p} ouiaId="modal-description">
      {allowMultipleContentViews
        ? __('A content view environment is a combination of a particular lifecycle environment and content view. You can assign multiple content view environments to provide hosts access to multiple sets of content.')
        : __('A content view environment is a combination of a particular lifecycle environment and content view.')
      }
    </Text>
  </TextContent>
);

AssignmentModalDescription.propTypes = {
  allowMultipleContentViews: PropTypes.bool.isRequired,
};

/**
 * Shared heading for the assignments section
 */
export const AssignmentsHeading = ({ show }) => {
  if (!show) return null;

  return (
    <Text
      component={TextVariants.h3}
      style={{ marginBottom: '0.5rem' }}
      ouiaId="attached-content-views-heading"
    >
      {__('Associated content view environments')}
    </Text>
  );
};

AssignmentsHeading.propTypes = {
  show: PropTypes.bool,
};

AssignmentsHeading.defaultProps = {
  show: true,
};
