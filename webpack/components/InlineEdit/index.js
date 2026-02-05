import React, { useState } from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  Button,
  Flex,
  FlexItem,
  FormGroup,
  FormSelect,
  FormSelectOption,
  TextArea,
  TextInput,
} from '@patternfly/react-core';
import { CheckIcon, TimesIcon, PencilAltIcon } from '@patternfly/react-icons';
import './InlineEdit.scss';

const InlineEdit = ({
  value, onSave, isRequired, multiline, type, options,
}) => {
  const [isEditing, setIsEditing] = useState(false);
  const [editValue, setEditValue] = useState(value);

  const handleSave = () => {
    if (isRequired && !editValue.trim()) {
      return;
    }
    onSave(editValue);
    setIsEditing(false);
  };

  const handleCancel = () => {
    setEditValue(value);
    setIsEditing(false);
  };

  const handleKeyDown = (e) => {
    if (e.key === 'Enter' && !multiline) {
      e.preventDefault();
      handleSave();
    } else if (e.key === 'Escape') {
      handleCancel();
    }
  };

  const renderValue = () => {
    if (type === 'select') {
      const option = options.find(opt => opt.value === value);
      return option?.label || value || __('Not set');
    }
    return value || __('Not set');
  };

  const renderEditField = () => {
    if (type === 'select') {
      return (
        <FormSelect
          value={editValue}
          onChange={newValue => setEditValue(newValue)}
          aria-label="inline-edit-select"
          ouiaId="inline-edit-select"
        >
          {options.map(option => (
            <FormSelectOption
              key={option.value}
              value={option.value}
              label={option.label}
            />
          ))}
        </FormSelect>
      );
    }

    if (multiline) {
      return (
        <TextArea
          value={editValue}
          onChange={(event, newValue) => setEditValue(newValue)}
          onKeyDown={handleKeyDown}
          aria-label="inline-edit-textarea"
          autoFocus
          rows={3}
        />
      );
    }

    return (
      <TextInput
        value={editValue}
        onChange={(event, newValue) => setEditValue(newValue)}
        onKeyDown={handleKeyDown}
        aria-label="inline-edit-input"
        autoFocus
        isRequired={isRequired}
        ouiaId="inline-edit-input"
      />
    );
  };

  if (!isEditing) {
    return (
      <Flex className="inline-edit-display">
        <FlexItem flex={{ default: 'flex_1' }}>
          <span className="inline-edit-value">{renderValue()}</span>
        </FlexItem>
        <FlexItem>
          <Button
            variant="plain"
            aria-label="Edit"
            onClick={() => {
              setEditValue(value);
              setIsEditing(true);
            }}
            icon={<PencilAltIcon />}
            ouiaId="inline-edit-edit-button"
          />
        </FlexItem>
      </Flex>
    );
  }

  return (
    <FormGroup className="inline-edit-form">
      <Flex>
        <FlexItem flex={{ default: 'flex_1' }}>
          {renderEditField()}
        </FlexItem>
        <FlexItem>
          <Button
            variant="plain"
            aria-label="Save"
            onClick={handleSave}
            icon={<CheckIcon />}
            isDisabled={isRequired && !editValue.trim()}
            ouiaId="inline-edit-save-button"
          />
        </FlexItem>
        <FlexItem>
          <Button
            variant="plain"
            aria-label="Cancel"
            onClick={handleCancel}
            icon={<TimesIcon />}
            ouiaId="inline-edit-cancel-button"
          />
        </FlexItem>
      </Flex>
    </FormGroup>
  );
};

InlineEdit.propTypes = {
  value: PropTypes.string,
  onSave: PropTypes.func.isRequired,
  isRequired: PropTypes.bool,
  multiline: PropTypes.bool,
  type: PropTypes.oneOf(['text', 'select']),
  options: PropTypes.arrayOf(PropTypes.shape({
    value: PropTypes.string,
    label: PropTypes.string,
  })),
};

InlineEdit.defaultProps = {
  value: '',
  isRequired: false,
  multiline: false,
  type: 'text',
  options: [],
};

export default InlineEdit;
