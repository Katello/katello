import React, {
  useEffect,
  useState,
} from 'react';
import {
  useDispatch,
} from 'react-redux';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  Modal,
  ModalVariant,
  Button,
  Form,
  FormGroup,
  TextInput,
  Checkbox,
  NumberInput,
  TextArea,
  Stack,
  StackItem,
} from '@patternfly/react-core';
import { getActivationKey, putActivationKey } from '../ActivationKeyActions';

const EditModal = ({ akDetails, akId }) => {
  const dispatch = useDispatch();

  const {
    name, description, maxHosts, unlimitedHosts, usageCount,
  } = akDetails;

  const initialMaxHosts = maxHosts || '';

  const [nameValue, setNameValue] = useState(name);
  const [descriptionValue, setDescriptionValue] = useState(description);
  const [maxHostsValue, setMaxHostsValue] = useState(initialMaxHosts);
  const [isUnlimited, setUnlimited] = useState(unlimitedHosts);

  useEffect(() => {
    setNameValue(name);
    setDescriptionValue(description);
    setMaxHostsValue(initialMaxHosts);
    setUnlimited(unlimitedHosts);
  }, [name, description, initialMaxHosts, unlimitedHosts]);


  const [isModalOpen, setModalOpen] = useState(false);

  const refreshActivationKeyDetails = () => dispatch(getActivationKey(akId));

  const handleModalToggle = () => {
    setModalOpen(!isModalOpen);
  };
  const handleSave = () => {
    dispatch(putActivationKey(
      akId,
      {
        name: nameValue,
        description: descriptionValue,
        max_hosts: maxHostsValue || (usageCount !== 0 ? usageCount : usageCount + 1),
        unlimited_hosts: isUnlimited,
      },
      refreshActivationKeyDetails,
    ));
    handleModalToggle();
  };

  const resetModalValues = () => {
    setNameValue(name);
    setDescriptionValue(description);
    setMaxHostsValue(initialMaxHosts);
    setUnlimited(unlimitedHosts);
  };

  const handleClose = () => {
    resetModalValues();
    handleModalToggle();
  };

  const handleNameInputChange = (value) => {
    setNameValue(value);
  };
  const handleDescriptionInputChange = (value) => {
    setDescriptionValue(value);
  };

  const onMinus = () => {
    setMaxHostsValue(oldValue => (oldValue || 0) - 1);
  };
  const onChange = (event) => {
    let newValue = (event.target.value === '' ? event.target.value : Math.round(+event.target.value));
    if (newValue < 1 && newValue !== '') {
      newValue = 1;
    }
    setMaxHostsValue(newValue);
  };
  const onPlus = () => {
    setMaxHostsValue(oldValue => (oldValue || 0) + 1);
  };

  const handleCheckBox = () => {
    setUnlimited(prevUnlimited => !prevUnlimited);
    setMaxHostsValue(usageCount > 0 ? usageCount : usageCount + 1);
  };

  return (
    <>
      <Button ouiaId="ak-edit-button" aria-label="edit-button" variant="secondary" onClick={handleModalToggle}>
        {__('Edit')}
      </Button>
      <Modal
        ouiaId="ak-edit-modal"
        variant={ModalVariant.small}
        title={__('Edit activation key')}
        description={__(`Select attributes for ${akDetails.name}`)}
        isOpen={isModalOpen}
        onClose={handleClose}
        actions={[
          <Button ouiaId="edit-modal-save-button" key="create" variant="primary" form="modal-with-form-form" onClick={handleSave}>
            {__('Save')}
          </Button>,
          <Button ouiaId="cancel-button" key="cancel" variant="link" onClick={handleClose}>
            {__('Cancel')}
          </Button>,
        ]}
      >
        <Form isHorizontal>
          <FormGroup
            label={__('Name')}
          >
            <TextInput
              ouiaId="ak-name-input"
              id="ak-name-input"
              type="text"
              value={nameValue}
              onChange={handleNameInputChange}
            />
          </FormGroup>
          <FormGroup
            label={__('Host Limit')}
          >
            <Stack hasGutter>
              <StackItem>
                <NumberInput
                  value={maxHostsValue}
                  min={1}
                  onMinus={onMinus}
                  onChange={onChange}
                  onPlus={onPlus}
                  inputName="input"
                  inputAriaLabel="number input"
                  minusBtnAriaLabel="minus"
                  plusBtnAriaLabel="plus"
                  isDisabled={isUnlimited}
                  allowEmptyInput
                />
              </StackItem>
              <StackItem>
                <Checkbox
                  ouiaId="unlimited-checkbox"
                  id="unlimited-checkbox"
                  label={__('Unlimited')}
                  isChecked={isUnlimited}
                  onChange={handleCheckBox}
                />
              </StackItem>
            </Stack>
          </FormGroup>
          <FormGroup
            label={__('Description')}
          >
            <TextArea
              id="ak-description"
              type="text"
              placeholder={__('Description')}
              value={descriptionValue}
              onChange={handleDescriptionInputChange}
            />
          </FormGroup>
        </Form>
      </Modal>
    </>
  );
};

export default EditModal;

EditModal.propTypes = {
  akDetails: PropTypes.shape({
    name: PropTypes.string,
    maxHosts: PropTypes.number,
    description: PropTypes.string,
    unlimitedHosts: PropTypes.bool,
    usageCount: PropTypes.number,
  }),
  akId: PropTypes.string.isRequired,
};

EditModal.defaultProps = {
  akDetails: {},
};
