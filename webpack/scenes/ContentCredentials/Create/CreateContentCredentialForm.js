import React, { useState, useEffect, useRef, useCallback } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { useHistory } from 'react-router-dom';
import PropTypes from 'prop-types';
import {
  Form,
  FormGroup,
  TextInput,
  TextArea,
  FormSelect,
  FormSelectOption,
  FormHelperText,
  HelperText,
  HelperTextItem,
  Flex,
  FlexItem,
  Button,
} from '@patternfly/react-core';
import { FileUploadIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import { orgId } from '../../../services/api';
import { createContentCredential } from '../ContentCredentialActions';
import {
  selectCreateContentCredentialStatus,
} from '../ContentCredentialSelectors';
import {
  CONTENT_CREDENTIAL_GPG_TYPE,
  CONTENT_CREDENTIAL_CERT_TYPE,
} from '../ContentCredentialConstants';
import './CreateContentCredentialForm.scss';

const CreateContentCredentialForm = ({ setModalOpen, setFormState, refreshTable }) => {
  const dispatch = useDispatch();
  const history = useHistory();
  const status = useSelector(selectCreateContentCredentialStatus);
  const fileInputRef = useRef(null);

  const [name, setName] = useState('');
  const [contentType, setContentType] = useState(CONTENT_CREDENTIAL_GPG_TYPE);
  const [content, setContent] = useState('');
  const [file, setFile] = useState(null);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    if (status === STATUS.RESOLVED && saving) {
      setSaving(false);
      setModalOpen(false);
      refreshTable();
      history.push('/content_credentials');
    } else if (status === STATUS.ERROR) {
      setSaving(false);
    }
  }, [status, saving, setModalOpen, refreshTable, history]);

  const onSave = useCallback(() => {
    setSaving(true);
    let params;

    if (file) {
      const formData = new FormData();
      formData.append('name', name);
      formData.append('content_type', contentType);
      formData.append('file_path', file);
      formData.append('organization_id', orgId());
      params = formData;
    } else {
      params = {
        name,
        content_type: contentType,
        content,
        organization_id: orgId(),
      };
    }

    dispatch(createContentCredential(params));
  }, [name, contentType, file, content, dispatch]);

  const handleContentChange = (value) => {
    setContent(value);
    if (value && file) {
      setFile(null);
    }
  };

  const handleFileChange = (event) => {
    const selectedFile = event.target.files?.[0];
    if (selectedFile) {
      setFile(selectedFile);
      if (content) {
        setContent('');
      }
    }
  };

  const contentTypeOptions = [
    { value: CONTENT_CREDENTIAL_GPG_TYPE, label: __('GPG Key') },
    { value: CONTENT_CREDENTIAL_CERT_TYPE, label: __('Certificate') },
  ];

  const submitDisabled =
    !name?.length || (!content?.length && !file) || saving;

  useEffect(() => {
    setFormState({
      onSave,
      submitDisabled,
      saving,
    });
  }, [onSave, submitDisabled, saving, setFormState]);

  return (
    <Form>
      <FormGroup label={__('Name')} isRequired fieldId="name">
        <TextInput
          ouiaId="name-input"
          isRequired
          type="text"
          id="name"
          name="name"
          aria-label="name"
          value={name}
          onChange={(_event, value) => setName(value)}
          autoFocus
        />
      </FormGroup>

      <FormGroup label={__('Type')} isRequired fieldId="content_type">
        <FormSelect
          ouiaId="content-type-select"
          value={contentType}
          onChange={(_event, value) => setContentType(value)}
          id="content_type"
          name="content_type"
          aria-label="content_type"
        >
          {contentTypeOptions.map(option => (
            <FormSelectOption
              key={option.value}
              value={option.value}
              label={option.label}
            />
          ))}
        </FormSelect>
      </FormGroup>

      <FormGroup label={__('Content')} fieldId="content">
        <TextArea
          id="content"
          name="content"
          aria-label="content"
          value={content}
          autoResize
          onChange={(_event, value) => handleContentChange(value)}
          placeholder={__('Paste contents of public key or certificate')}
          isDisabled={!!file}
        />
      </FormGroup>

      <FormGroup label={__('Upload file')} fieldId="file_path">
        <Flex>
          <FlexItem>
            <input
              type="file"
              ref={fileInputRef}
              style={{ display: 'none' }}
              onChange={handleFileChange}
              disabled={saving}
              accept={contentType === CONTENT_CREDENTIAL_GPG_TYPE ? '.asc,.gpg,.key' : '.crt,.pem,.cer,.cert'}
              aria-label="file_path"
            />
            <Button
              variant="secondary"
              icon={<FileUploadIcon />}
              isDisabled={saving}
              onClick={() => fileInputRef.current?.click()}
              ouiaId="upload-file-button"
            >
              {file ? file.name : __('Choose file')}
            </Button>
          </FlexItem>
        </Flex>
        <FormHelperText>
          <HelperText>
            <HelperTextItem>
              {__('Upload public key or certificate file')}
            </HelperTextItem>
          </HelperText>
        </FormHelperText>
      </FormGroup>
    </Form>
  );
};

CreateContentCredentialForm.propTypes = {
  setModalOpen: PropTypes.func.isRequired,
  setFormState: PropTypes.func.isRequired,
  refreshTable: PropTypes.func,
};

CreateContentCredentialForm.defaultProps = {
  refreshTable: () => {},
};

export default CreateContentCredentialForm;
