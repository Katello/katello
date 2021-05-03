import { STATUS } from 'foremanReact/constants';
import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import { useDispatch, useSelector } from 'react-redux';
import { Redirect } from 'react-router-dom';
import { Form, FormGroup, TextInput, ActionGroup, Button } from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  selectCopyContentViewError, selectCopyContentViews,
  selectCopyContentViewStatus,
} from './ContentViewCopySelectors';
import { copyContentView } from '../ContentViewsActions';

const CopyContentViewForm = ({ cvId, setModalOpen }) => {
  const dispatch = useDispatch();
  const [name, setName] = useState('');
  const [redirect, setRedirect] = useState(false);
  const [saving, setSaving] = useState(false);
  const response = useSelector(selectCopyContentViews);
  const status = useSelector(selectCopyContentViewStatus);
  const error = useSelector(selectCopyContentViewError);

  useEffect(() => {
    const { id } = response;
    if (id && status === STATUS.RESOLVED) {
      setSaving(false);
      setRedirect(true);
    } else if (status === STATUS.ERROR) {
      setSaving(false);
    }
  }, [JSON.stringify(response), status, error]);

  const onSubmit = () => {
    setSaving(true);
    dispatch(copyContentView({
      id: cvId,
      name,
    }));
  };

  if (redirect) {
    const { id } = response;
    return (<Redirect to={`/labs/content_views/${id}`} />);
  }

  return (
    <Form>
      <FormGroup label="Name" isRequired fieldId="name">
        <TextInput
          isRequired
          type="text"
          id="name"
          aria-label="input_name"
          name="name"
          value={name}
          onChange={value => setName(value)}
        />
      </FormGroup>
      <ActionGroup>
        <Button aria-label="copy_content_view" variant="primary" isDisabled={saving} onClick={() => onSubmit()}>{__('Copy content view')}</Button>
        <Button variant="link" onClick={() => setModalOpen(false)}>{__('Cancel')}</Button>
      </ActionGroup>
    </Form>
  );
};

CopyContentViewForm.propTypes = {
  cvId: PropTypes.string,
  setModalOpen: PropTypes.func,
};

CopyContentViewForm.defaultProps = {
  cvId: null,
  setModalOpen: null,
};


export default CopyContentViewForm;
