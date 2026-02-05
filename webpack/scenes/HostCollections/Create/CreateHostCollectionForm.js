import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  Form,
  FormGroup,
  TextInput,
  TextArea,
  Checkbox,
  ActionGroup,
  Button,
  NumberInput,
  FormHelperText,
  HelperText,
  HelperTextItem,
} from '@patternfly/react-core';
import { addToast } from 'foremanReact/components/ToastsList/slice';
import { createHostCollection } from '../HostCollectionsActions';

const CreateHostCollectionForm = ({ onClose }) => {
  const dispatch = useDispatch();
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [unlimitedHosts, setUnlimitedHosts] = useState(true);
  const [maxHosts, setMaxHosts] = useState(1);
  const [saving, setSaving] = useState(false);

  const onMinus = () => {
    const newValue = (maxHosts || 1) - 1;
    setMaxHosts(newValue < 1 ? 1 : newValue);
  };

  const onPlus = () => {
    setMaxHosts((maxHosts || 1) + 1);
  };

  const onChange = (event) => {
    const value = Number(event.target.value);
    setMaxHosts(value < 1 ? 1 : value);
  };

  const handleSuccess = () => {
    setSaving(false);
    dispatch(addToast({
      type: 'success',
      message: __('Host collection created successfully'),
    }));
    onClose();
    window.location.reload();
  };

  const handleError = (error) => {
    setSaving(false);
    const errorMsg =
      error?.response?.data?.error?.full_messages?.[0] ||
      error?.response?.data?.displayMessage ||
      __('Failed to create host collection');
    dispatch(addToast({
      type: 'error',
      message: errorMsg,
    }));
  };

  const onSave = () => {
    setSaving(true);
    const params = {
      name,
      description,
      unlimited_hosts: unlimitedHosts,
    };
    if (!unlimitedHosts) {
      params.max_hosts = maxHosts;
    }
    dispatch(createHostCollection(params, handleSuccess, handleError));
  };

  const submitDisabled = !name?.trim().length || saving;

  return (
    <Form
      onSubmit={(e) => {
        e.preventDefault();
        onSave();
      }}
      id="create-host-collection-form"
    >
      <FormGroup label={__('Name')} isRequired fieldId="name">
        <TextInput
          isRequired
          type="text"
          id="name"
          aria-label="name"
          ouiaId="name-input"
          name="name"
          value={name}
          onChange={(_event, value) => setName(value)}
          isDisabled={saving}
        />
      </FormGroup>
      <FormGroup label={__('Description')} fieldId="description">
        <TextArea
          type="text"
          id="description"
          name="description"
          aria-label="description"
          ouiaId="description-input"
          value={description}
          onChange={(_event, value) => setDescription(value)}
          isDisabled={saving}
        />
      </FormGroup>
      <FormGroup fieldId="unlimited-hosts">
        <Checkbox
          id="unlimited-hosts"
          ouiaId="unlimited-hosts-checkbox"
          name="unlimited-hosts"
          label={__('Unlimited hosts')}
          isChecked={unlimitedHosts}
          onChange={(_event, checked) => setUnlimitedHosts(checked)}
          isDisabled={saving}
        />
      </FormGroup>
      {!unlimitedHosts && (
        <FormGroup label={__('Limit')} isRequired fieldId="max-hosts">
          <NumberInput
            id="max-hosts"
            aria-label="max-hosts"
            ouiaId="max-hosts-input"
            value={maxHosts}
            onMinus={onMinus}
            onChange={onChange}
            onPlus={onPlus}
            min={1}
            isDisabled={saving}
          />
          <FormHelperText>
            <HelperText>
              <HelperTextItem>
                {__('Maximum number of content hosts in this collection')}
              </HelperTextItem>
            </HelperText>
          </FormHelperText>
        </FormGroup>
      )}
      <ActionGroup>
        <Button
          ouiaId="create-button"
          aria-label="create"
          variant="primary"
          isDisabled={submitDisabled}
          isLoading={saving}
          type="submit"
        >
          {__('Create')}
        </Button>
        <Button
          ouiaId="cancel-button"
          variant="link"
          onClick={onClose}
          isDisabled={saving}
        >
          {__('Cancel')}
        </Button>
      </ActionGroup>
    </Form>
  );
};

CreateHostCollectionForm.propTypes = {
  onClose: PropTypes.func.isRequired,
};

export default CreateHostCollectionForm;
