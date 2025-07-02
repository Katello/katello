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

// eslint-disable-next-line react/prop-types
const FlatpakRemotesForm = ({ setModalOpen, remoteData }) => {
  const {
    name: editingName,
    url: editingUrl,
    username: editingUsername,
    password: editingPassword,
  } = remoteData || {};


  const dispatch = useDispatch();
  const [name, setName] = useState(editingName || '');
  const [url, seturl] = useState(editingUrl || '');
  const [username, setUsername] = useState(editingUsername || '');
  const [password, setpassword] = useState(editingPassword || '');
  const [redirect, setRedirect] = useState(false);
  const [saving, setSaving] = useState(false);

  const [urlValidated, seturlValidated] = useState('default');
  const handleUrlChange = (newurl, _event) => {
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
          onChange={(_event, newurl) => handleUrlChange(newurl, _event)}
        />
        {urlValidated === 'error' && (
          <FormHelperText>
            <HelperText>
              <HelperTextItem variant="error">
                {__('Must be a vaild URL')}
              </HelperTextItem>
            </HelperText>
          </FormHelperText>
        )}
      </FormGroup>
      <FormGroup label={__('Username')} fieldId="username">
        <TextInput
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
          ouiaId="create-flatpakcancel"
          variant="link"
          onClick={() => setModalOpen(false)}
        >
          {__('Cancel')}
        </Button>
      </ActionGroup>
    </Form>
  );
};

FlatpakRemotesForm.propTypes = {
  setModalOpen: PropTypes.func,
};

FlatpakRemotesForm.defaultProps = {
  setModalOpen: null,
};

export default FlatpakRemotesForm;
