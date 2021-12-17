import React, { useState, useEffect } from 'react';
import {
  TextInput, TextArea, Text, Button, Split, SplitItem, Tooltip, TooltipPosition,
} from '@patternfly/react-core';
import {
  EyeIcon,
  EyeSlashIcon,
  TimesIcon,
  CheckIcon,
  PencilAltIcon,
} from '@patternfly/react-icons';
import { translate as __ } from 'foremanReact/common/I18n';
import PropTypes from 'prop-types';
import './editableTextInput.scss';

const PASSWORD_MASK = '••••••••';

const EditableTextInput = ({
  onEdit, value, textArea, attribute, placeholder, isPassword, hasPassword,
  component, currentAttribute, setCurrentAttribute, disabled,
}) => {
  const [inputValue, setInputValue] = useState(value);
  const [editing, setEditing] = useState(false);
  const [passwordPlaceholder, setPasswordPlaceholder] = useState(hasPassword
    ? PASSWORD_MASK : null);
  const [showPassword, setShowPassword] = useState(false);

  useEffect(() => {
    if (setCurrentAttribute && currentAttribute) {
      if (attribute !== currentAttribute) {
        setEditing(false);
      }
    }
  }, [attribute, currentAttribute, setCurrentAttribute]);

  const onEditClick = () => {
    setEditing(true);
    if (isPassword) setPasswordPlaceholder(null);
    if (setCurrentAttribute && attribute !== currentAttribute) setCurrentAttribute(attribute);
  };

  const onSubmit = async () => {
    setEditing(false);
    if (isPassword) {
      if (inputValue?.length > 0) {
        setPasswordPlaceholder(PASSWORD_MASK);
      }
    }
    await onEdit(inputValue, attribute);
  };

  const onClear = () => {
    if (isPassword) {
      if (hasPassword || inputValue?.length > 0) {
        setPasswordPlaceholder(PASSWORD_MASK);
      }
    }
    setInputValue(value);
    setEditing(false);
  };

  const toggleShowPassword = () => {
    setShowPassword(prevShowPassword => !prevShowPassword);
  };

  const onKeyUp = ({ key, charCode }) => (key === 'Enter' || charCode === '13') && onSubmit();

  const inputProps = {
    onKeyUp,
    component,
    value: inputValue || '',
    onChange: setInputValue,
  };

  return editing ? (
    <Split>
      <SplitItem>
        {textArea ?
          (<TextArea {...inputProps} aria-label={`${attribute} text area`} />) :
          (<TextInput {...inputProps} type={(isPassword && !showPassword) ? 'password' : 'text'} aria-label={`${attribute} text input`} />)}
      </SplitItem>
      <SplitItem>
        <Button
          aria-label={`submit ${attribute}`}
          variant="plain"
          onClick={onSubmit}
        >
          <CheckIcon />
        </Button>
      </SplitItem>
      <SplitItem>
        <Button aria-label={`clear ${attribute}`} variant="plain" onClick={onClear}>
          <TimesIcon />
        </Button>
      </SplitItem>
      {isPassword ?
        <SplitItem>
          <Button aria-label={`show-password ${attribute}`} variant="plain" isDisabled={!inputValue?.length} onClick={toggleShowPassword}>
            {showPassword ?
              (<EyeSlashIcon />) :
              (<EyeIcon />)}
          </Button>
        </SplitItem> :
        null
      }
    </Split>
  ) : (
    <Split>
      <SplitItem>
        {inputValue ?
          <Text aria-label={`${attribute} text value`} component={component}>
            {editing ? inputValue : passwordPlaceholder || inputValue}
          </Text> :
          <Text className="textInput-placeholder" aria-label={`${attribute} text value`} component={component}>
            {passwordPlaceholder || placeholder}
          </Text>}
      </SplitItem >
      {!disabled &&
        <SplitItem>
          <Tooltip
            position={TooltipPosition.top}
            content={__('Edit')}
          >
            <Button
              className="foreman-edit-icon"
              aria-label={`edit ${attribute}`}
              variant="plain"
              onClick={onEditClick}
            >
              <PencilAltIcon />
            </Button>
          </Tooltip>
        </SplitItem>
      }
    </Split >
  );
};

EditableTextInput.propTypes = {
  onEdit: PropTypes.func.isRequired,
  value: PropTypes.string,
  attribute: PropTypes.string.isRequired,
  textArea: PropTypes.bool, // Is a text area instead of input when editing
  placeholder: PropTypes.string,
  component: PropTypes.string,
  currentAttribute: PropTypes.string,
  setCurrentAttribute: PropTypes.func,
  disabled: PropTypes.bool,
  isPassword: PropTypes.bool,
  hasPassword: PropTypes.bool,
};

EditableTextInput.defaultProps = {
  textArea: false,
  placeholder: __('None provided'),
  value: '', // API can return null, so default to empty string
  component: undefined,
  currentAttribute: undefined,
  setCurrentAttribute: undefined,
  disabled: false,
  isPassword: false,
  hasPassword: false,
};

export default EditableTextInput;
