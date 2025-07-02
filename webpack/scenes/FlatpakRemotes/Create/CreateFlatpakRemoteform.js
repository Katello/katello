import React, { useState } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { STATUS } from 'foremanReact/constants';
import { translate as __ } from 'foremanReact/common/I18n';
import PropTypes from 'prop-types';
import { useDispatch, useSelector } from 'react-redux';
import {
  Form,
  FormGroup,
  TextInput,
  ActionGroup,
  Button,
  FormHelperText,
  HelperText,
  HelperTextItem,

} from '@patternfly/react-core';
import { createFlatpakRemote } from '../FlatpakRemotesActions';
import {
  selectCreateFlatpakRemotes,
  selectCreateFlatpakRemotesStatus,
  selectCreateFlatpakRemotesError,
} from '../FlatpakRemotesSelectors';

export const contentViewDescriptions = {
  CV: __('Contains repositories. Versions are published and optionally filtered.'),
  CCV: __('Contains content views. You must choose the version to use for each content view.'),
  RCV: __('Contains repositories. Always serves the latest synced content, without the need to publish versions.'),
};

const CreateFlatpakForm = ({ setModalOpen }) => {
  const dispatch = useDispatch();
  const [name, setName] = useState('');
  const [url, seturl] = useState('');
  const [username, setUsername] = useState('');
  const [password, setpassword] = useState('');
  const [redirect, setRedirect] = useState(false);
  const [saving, setSaving] = useState(false);

  const [urlValidated, seturlValidated] = useState('default');
  const handleLabelChange = (newurl, _event) => {
    seturl(newurl);
    if (newurl === '') {
      seturlValidated('default');
    } else if (/^(http(s):\/\/.)[-a-zA-Z0-9@:%._~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:%_.~#?&//=]*)$/g.test(newurl)) {
      seturlValidated('success');
    } else {
      seturlValidated('error');
    }
  };

  const response = useSelector(selectCreateFlatpakRemotes);
  const status = useSelector(selectCreateFlatpakRemotesStatus);
  const error = useSelector(selectCreateFlatpakRemotesError);

  useDeepCompareEffect(() => {
    const { id } = response;
    if (id && status === STATUS.RESOLVED && saving) {
      setSaving(false);
      setRedirect(true);
    } else if (status === STATUS.ERROR) {
      setSaving(false);
    }
  }, [response, status, error, saving]);

  const onSave = () => {
    setSaving(true);
    dispatch(createFlatpakRemote({
      name,
      url,
      username,
      password,
    }));
  };

  if (redirect) {
    const { id } = response;
    window.location.assign(`/flatpak_remotes/${id}`);
  }

  const submitDisabled =
    !name?.length || !url?.length || saving || redirect || urlValidated === 'error';

  return (
    <Form
      onSubmit={(e) => {
        e.preventDefault();
        onSave();
      }}
      id="create-flatpak-form"
    >
      <FormGroup
        label={__('Name')}
        isRequired
        fieldId="name"
      >
        <TextInput
          isRequired
          type="text"
          id="name"
          aria-label="input_name"
          ouiaId="input_name"
          name="name"
          value={name}
          onChange={(_event, value) => setName(value)}
        />
      </FormGroup>
      <FormGroup
        label={__('URL')}
        isRequired
        fieldId="url"
      >
        <TextInput
          isRequired
          type="url"
          id="url"
          aria-label="input_url"
          ouiaId="input_url"
          name="url"
          value={url}
          validated={urlValidated}
          onChange={(_event, newurl) => handleLabelChange(newurl, _event)}
        />
        {urlValidated === 'error' && (
          <FormHelperText>
            <HelperText>
              <HelperTextItem variant="error">
                {__("Must be Ascii alphanumeric, '_' or '-'")}
              </HelperTextItem>
            </HelperText>
          </FormHelperText>
        )}
      </FormGroup>
      <FormGroup label={__('Username')} fieldId="username">
        <TextInput
          isRequired
          type="text"
          id="username"
          ouiaId="input_username"
          name="username"
          aria-label="input_username"
          value={username}
          onChange={(_event, value) => setUsername(value)}
        />
        <FormHelperText>
          <HelperText>
            <HelperTextItem>Authentication for registry</HelperTextItem>
          </HelperText>
        </FormHelperText>
      </FormGroup>
      <FormGroup label={__('Password')} fieldId="password">
        <TextInput
          isRequired
          type="password"
          id="password"
          ouiaId="input_password"
          name="password"
          aria-label="password"
          value={password}
          onChange={(_event, value) => setpassword(value)}
        />
      </FormGroup>

      <ActionGroup>
        <Button
          ouiaId="create-flatpak-form-submit"
          aria-label="create_flatpak"
          variant="primary"
          isDisabled={submitDisabled}
          isLoading={saving || redirect}
          type="submit"
        >
          {__('Create')}
        </Button>
        <Button
          ouiaId="create-cflatpakcancel"
          variant="link"
          onClick={() => setModalOpen(false)}
        >
          {__('Cancel')}
        </Button>
      </ActionGroup>
    </Form>
  );
};

CreateFlatpakForm.propTypes = {
  setModalOpen: PropTypes.func,
};

CreateFlatpakForm.defaultProps = {
  setModalOpen: null,
};

export default CreateFlatpakForm;
