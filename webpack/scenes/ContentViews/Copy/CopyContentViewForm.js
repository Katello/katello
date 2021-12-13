import { STATUS } from 'foremanReact/constants';
import React, { useState } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import PropTypes from 'prop-types';
import { useDispatch, useSelector } from 'react-redux';
import { useHistory } from 'react-router-dom';
import { translate as __ } from 'foremanReact/common/I18n';
import { Form, FormGroup, TextInput, ActionGroup, Button } from '@patternfly/react-core';
import {
  selectCopyContentViewError, selectCopyContentViews,
  selectCopyContentViewStatus,
} from './ContentViewCopySelectors';
import { copyContentView } from '../ContentViewsActions';

const CopyContentViewForm = ({ cvId, setModalOpen }) => {
  const dispatch = useDispatch();
  const [name, setName] = useState('');
  const [saving, setSaving] = useState(false);
  const response = useSelector(selectCopyContentViews);
  const status = useSelector(selectCopyContentViewStatus);
  const error = useSelector(selectCopyContentViewError);
  const { push } = useHistory();

  useDeepCompareEffect(() => {
    const { id } = response;
    if (saving && id && status === STATUS.RESOLVED) {
      setSaving(false);
      setModalOpen(false);
      push(`/content_views/${id}`);
    } else if (status === STATUS.ERROR) {
      setSaving(false);
    }
  }, [response, status, error, saving, setSaving, setModalOpen, push]);

  const onSubmit = () => {
    setSaving(true);
    dispatch(copyContentView({
      id: cvId,
      name,
    }));
  };

  return (
    <Form onSubmit={(e) => {
      e.preventDefault();
      onSubmit();
    }}
    >
      <FormGroup label={__('Name')} isRequired fieldId="name">
        <TextInput
          isRequired
          type="text"
          id="name"
          aria-label="input_name"
          name="name"
          value={name}
          onChange={setName}
        />
      </FormGroup>
      <ActionGroup>
        <Button
          aria-label="copy_content_view"
          variant="primary"
          isDisabled={!name?.length || saving}
          type="submit"
        >
          {__('Copy content view')}
        </Button>
        <Button variant="link" onClick={() => setModalOpen(false)}>{__('Cancel')}</Button>
      </ActionGroup>
    </Form >
  );
};

CopyContentViewForm.propTypes = {
  cvId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]),
  setModalOpen: PropTypes.func,
};

CopyContentViewForm.defaultProps = {
  cvId: null,
  setModalOpen: null,
};


export default CopyContentViewForm;
