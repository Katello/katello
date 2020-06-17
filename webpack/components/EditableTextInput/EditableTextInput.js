import React, { useState, Fragment } from 'react';
import { TextInput, TextArea, Text, TextVariants, Button, Split, SplitItem } from '@patternfly/react-core';
import { TimesIcon, CheckIcon, EditIcon } from '@patternfly/react-icons';
import PropTypes from 'prop-types';
import Loading from '../Loading';
import './editableTextInput.scss';

const EditableTextInput = ({
  onEdit, value, textArea, editable, label,
}) => {
  // Tracks input box state
  const [inputValue, setInputValue] = useState(value);
  const [editing, setEditing] = useState(false);
  const [working, setWorking] = useState(false);
  const onSubmit = () => {
    setWorking(true);
    onEdit(inputValue);
    setWorking(false);
    setEditing(false);
  };
  const onClear = () => {
    setInputValue(value);
    setEditing(false);
  };

  const textInput = () => {
    const sharedProps = {
      value: inputValue,
      onChange: v => setInputValue(v),
    };

    if (textArea) {
      return <TextArea {...sharedProps} aria-label={`text area ${label}`} />;
    }
    return <TextInput {...sharedProps} type="text" aria-label={`text input ${label}`} />;
  };

  if (working) return <Loading size="sm" />;
  return (
    <Fragment>
      {editing ?
      (
        <Split>
          <SplitItem>
            {textInput()}
          </SplitItem>
          <SplitItem>
            <Button aria-label={`submit ${label}`} variant="plain" onClick={onSubmit}>
              <CheckIcon />
            </Button>
          </SplitItem>
          <SplitItem>
            <Button aria-label={`clear ${label}`} variant="plain" onClick={onClear}>
              <TimesIcon />
            </Button>
          </SplitItem>
        </Split>
      ) :
      (
        <Split>
          <SplitItem>
            <Text aria-label={`text value ${label}`} component={TextVariants.p}>
              {value}
            </Text>
          </SplitItem>
          {editable &&
          <SplitItem>
            <Button
              className="foreman-edit-icon"
              aria-label={`edit ${label}`}
              variant="plain"
              onClick={() => setEditing(true)}
            >
              <EditIcon />
            </Button>
          </SplitItem>}
        </Split>
      )
    }
    </Fragment>
  );
};

EditableTextInput.propTypes = {
  onEdit: PropTypes.func.isRequired,
  value: PropTypes.string,
  label: PropTypes.string.isRequired,
  textArea: PropTypes.bool, // Is a text area instead of input when editing
  editable: PropTypes.bool,
};

EditableTextInput.defaultProps = {
  textArea: false,
  editable: true,
  value: '', // API can return null, so default to empty string
};

export default EditableTextInput;
