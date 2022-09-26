import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { ActionGroup, Button, Form, FormGroup, Modal, ModalVariant, TextArea, TextInput } from '@patternfly/react-core';
import { editACS, getACSDetails } from '../../ACSActions';

const ACSEditDetails = ({ onClose, acsId, acsDetails }) => {
  const { name, description } = acsDetails;
  const dispatch = useDispatch();
  const [acsName, setACSName] = useState(name);
  const [acsDescription, setAcsDescription] = useState(description || '');
  const [saving, setSaving] = useState(false);

  const onSubmit = () => {
    setSaving(true);
    dispatch(editACS(
      acsId,
      { acsId, name: acsName, description: acsDescription },
      () => {
        dispatch(getACSDetails(acsId));
        onClose();
      },
      () => {
        setSaving(false);
      },
    ));
  };

  return (
    <Modal
      title={__('Edit details')}
      variant={ModalVariant.small}
      isOpen
      onClose={onClose}
      appendTo={document.body}
    >
      <Form onSubmit={(e) => {
        e.preventDefault();
        onSubmit();
      }}
      >
        <FormGroup label={__('Name')} isRequired fieldId="acs_name">
          <TextInput
            isRequired
            type="text"
            id="acs_name_field"
            name="acs_name_field"
            aria-label="acs_name_field"
            value={acsName}
            onChange={(value) => {
              setACSName(value);
            }}
          />
        </FormGroup>
        <FormGroup
          label={__('Description')}
          type="string"
          fieldId="acs_description"
        >
          <TextArea
            value={acsDescription}
            onChange={(value) => {
              setAcsDescription(value);
            }}
            name="acs_description_field"
            id="acs_description_field"
          />
        </FormGroup>
        <ActionGroup>
          <Button
            ouiaId="edit-acs-details-submit"
            aria-label="edit_acs_details"
            variant="primary"
            isDisabled={saving || acsName.length === 0}
            isLoading={saving}
            type="submit"
          >
            {__('Edit ACS details')}
          </Button>
          <Button ouiaId="edit-acs-details-cancel" variant="link" onClick={onClose}>
            {__('Cancel')}
          </Button>
        </ActionGroup>
      </Form>
    </Modal>
  );
};

ACSEditDetails.propTypes = {
  acsId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  onClose: PropTypes.func.isRequired,
  acsDetails: PropTypes.shape({
    name: PropTypes.string,
    description: PropTypes.string,
    id: PropTypes.number,
  }),
};

ACSEditDetails.defaultProps = {
  acsDetails: { name: '', description: '', id: undefined },
};

export default ACSEditDetails;
