import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { Modal, ModalVariant, Form, FormGroup, TextInput, ActionGroup, Button } from '@patternfly/react-core';
import { addCVFilterRule, editCVFilterRule, getCVFilterRules } from '../../../ContentViewDetailActions';

const AddEditContainerTagRuleModal = ({
  onClose, filterId, selectedFilterRuleData,
}) => {
  const { name, id } = selectedFilterRuleData;
  const dispatch = useDispatch();
  const [tagName, setTagName] = useState(name);
  const [saving, setSaving] = useState(false);
  const isEditing = name && id;

  const onSubmit = () => {
    setSaving(true);
    if (isEditing) {
      dispatch(editCVFilterRule(
        filterId,
        { id, name: tagName },
        () => dispatch(getCVFilterRules(filterId)),
      ));
    } else {
      dispatch(addCVFilterRule(
        filterId,
        { name: tagName },
        () => dispatch(getCVFilterRules(filterId)),
      ));
    }
    onClose();
  };

  return (
    <Modal
      title={isEditing ? __('Edit filter rule') : __('Add filter rule')}
      variant={ModalVariant.small}
      isOpen
      onClose={onClose}
      appendTo={document.body}
    >
      <Form onSubmit={(e) => {
        e.preventDefault();
        onSubmit();
      }}
      >
        <FormGroup label={__('Tag name')} isRequired fieldId="tag_name">
          <TextInput
            autoFocus
            isRequired
            type="text"
            id="tag_name"
            aria-label="input_tag"
            name="tagName"
            value={tagName}
            onChange={value => setTagName(value)}
          />
        </FormGroup>
        <ActionGroup>
          <Button
            aria-label="add_edit_filter_rule"
            variant="primary"
            isDisabled={saving || tagName.length === 0}
            type="submit"
          >
            {isEditing ? __('Edit rule') : __('Add rule')}
          </Button>
          <Button variant="link" onClick={onClose}>
            {__('Cancel')}
          </Button>
        </ActionGroup>
      </Form >
    </Modal >
  );
};

AddEditContainerTagRuleModal.propTypes = {
  filterId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  onClose: PropTypes.func.isRequired,
  selectedFilterRuleData: PropTypes.shape({
    name: PropTypes.string,
    id: PropTypes.number,
  }),
};

AddEditContainerTagRuleModal.defaultProps = {
  selectedFilterRuleData: { name: '', id: undefined },
};

export default AddEditContainerTagRuleModal;
