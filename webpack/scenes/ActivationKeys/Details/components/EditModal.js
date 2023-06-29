import React, {
  useEffect,
  useState,
} from 'react';
import {
  useDispatch,
} from 'react-redux';
import PropTypes from 'prop-types';
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
import { putActivationKey } from '../ActivationKeyActions';

const EditModal = ({ akDetails, akId }) => {
  const dispatch = useDispatch();

  const {
    name, description, maxHosts, unlimitedHosts,
  } = akDetails;

  const [nameValue, setNameValue] = useState(name);
  const [descriptionValue, setDescriptionValue] = useState(description);
  const [maxHostsValue, setMaxHostsValue] = useState(maxHosts);
  const [isUnlimited, setUnlimited] = useState(unlimitedHosts);

  useEffect(() => {
    setNameValue(name);
    setDescriptionValue(description);
    setMaxHostsValue(maxHosts);
    setUnlimited(unlimitedHosts);
  }, [name, description, maxHosts, unlimitedHosts]);


  const [isModalOpen, setModalOpen] = useState(false);

  const handleModalToggle = () => {
    setModalOpen(!isModalOpen);
  };
  const handleSave = () => {
    dispatch(putActivationKey(
      akId,
      {
        name: nameValue,
        description: descriptionValue,
        max_hosts: maxHostsValue,
        unlimited_hosts: isUnlimited,
      },
    ));
    handleModalToggle();
  };

  const resetModalValues = () => {
    setNameValue(name);
    setDescriptionValue(description);
    setMaxHostsValue(maxHosts);
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
    maxHostsValue(oldValue => (oldValue || 0) - 1);
  };
  const onChange = (event) => {
    let newValue = (event.target.value === '' ? event.target.value : Math.round(+event.target.value));
    if (newValue < 0) {
      newValue = 0;
    }
    setMaxHostsValue(newValue);
  };
  const onPlus = () => {
    setMaxHostsValue(oldValue => (oldValue || 0) + 1);
  };

  const handleCheckBox = () => {
    setUnlimited(prevUnlimited => !prevUnlimited);
  };

  return (
    <>
      <Button ouiaId="ak-edit-button" variant="secondary" onClick={handleModalToggle}>
        Edit
      </Button>
      <Modal
        ouiaId="ak-edit-modal"
        variant={ModalVariant.small}
        title="Edit activation key"
        description={`Select attributes for ${akDetails.name}`}
        isOpen={isModalOpen}
        onClose={handleClose}
        actions={[
          <Button ouiaId="edit-modal-save-button" key="create" variant="primary" form="modal-with-form-form" onClick={handleSave}>
            Save
          </Button>,
          <Button ouiaId="cancel-button" key="cancel" variant="link" onClick={handleClose}>
            Cancel
          </Button>,
        ]}
      >
        <Form isHorizontal>
          <FormGroup
            label="Name"
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
            label="Host limit"
          >
            <Stack hasGutter>
              <StackItem>
                <NumberInput
                  value={maxHostsValue}
                  min={0}
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
                  label="Unlimited"
                  isChecked={isUnlimited}
                  onChange={handleCheckBox}
                />
              </StackItem>
            </Stack>
          </FormGroup>
          <FormGroup
            label="Description"
          >
            <TextArea
              id="ak-description"
              type="text"
              defaultValue={descriptionValue || 'Description empty'}
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
  }),
  akId: PropTypes.string,
};

EditModal.defaultProps = {
  akDetails: {},
  akId: '',
};
