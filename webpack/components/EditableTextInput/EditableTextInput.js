import React, { useState, useEffect } from 'react';
import { TextInput, TextArea, Text, TextVariants, Button, Split, SplitItem } from '@patternfly/react-core';
import { TimesIcon, CheckIcon, PencilAltIcon } from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import PropTypes from 'prop-types';
import Loading from '../Loading';
import './editableTextInput.scss';

const EditableTextInput = ({
  onEdit, value, textArea, attribute,
}) => {
  // Tracks input box state
  const [inputValue, setInputValue] = useState(value);
  const [editing, setEditing] = useState(false);
  const [submitting, setSubmitting] = useState(false);

  // Setting didCancel to prevent actions from happening after component has been unmounted
  // see https://overreacted.io/a-complete-guide-to-useeffect/#speaking-of-race-conditions
  useEffect(() => {
    let didCancel = false;

    const onSubmit = async () => {
      if (submitting) { // no dependency array because this check takes care of it
        await onEdit(inputValue, attribute);
        if (!didCancel) {
          setSubmitting(false);
          setEditing(false);
        }
      }
    };
    onSubmit();

    return () => {
      didCancel = true;
    };
  });

  // Listen for enter and trigger submit workflow on enter
  useEffect(() => {
    const listener = (event) => {
      if (event.code === 'Enter' || event.code === 'NumpadEnter') {
        if (editing) setSubmitting(true);
      }
    };
    document.addEventListener('keydown', listener);
    return () => {
      document.removeEventListener('keydown', listener);
    };
  }, [editing]);

  const onClear = () => {
    setInputValue(value);
    setEditing(false);
  };

  const inputProps = {
    value: inputValue || '',
    onChange: v => setInputValue(v),
  };

  if (submitting) return <Loading size="sm" />;
  if (editing) {
    return (
      <Split>
        <SplitItem>
          {textArea ?
            (<TextArea {...inputProps} aria-label={`${attribute} text area`} />) :
            (<TextInput {...inputProps} type="text" aria-label={`${attribute} text input`} />)}
        </SplitItem>
        <SplitItem>
          <Button
            aria-label={`submit ${attribute}`}
            variant="plain"
            onClick={() => setSubmitting(true)}
          >
            <CheckIcon />
          </Button>
        </SplitItem>
        <SplitItem>
          <Button aria-label={`clear ${attribute}`} variant="plain" onClick={onClear}>
            <TimesIcon />
          </Button>
        </SplitItem>
      </Split>
    );
  }
  return (
    <Split>
      <SplitItem>
        <Text aria-label={`${attribute} text value`} component={TextVariants.p}>
          {value || (<i>{__('None provided')}</i>)}
        </Text>
      </SplitItem>
      <SplitItem>
        <Button
          className="foreman-edit-icon"
          aria-label={`edit ${attribute}`}
          variant="plain"
          onClick={() => setEditing(true)}
        >
          <PencilAltIcon />
        </Button>
      </SplitItem>
    </Split>
  );
};

EditableTextInput.propTypes = {
  onEdit: PropTypes.func.isRequired,
  value: PropTypes.string,
  attribute: PropTypes.string.isRequired,
  textArea: PropTypes.bool, // Is a text area instead of input when editing
};

EditableTextInput.defaultProps = {
  textArea: false,
  value: '', // API can return null, so default to empty string
};

export default EditableTextInput;
