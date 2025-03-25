import React, { useState } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { useDispatch, useSelector } from 'react-redux';
import { STATUS } from 'foremanReact/constants';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { Modal, ModalVariant, Form, FormGroup, TextInput, ActionGroup, Button } from '@patternfly/react-core';
import { addCVFilterRule, editCVFilterRule, getCVFilterRules } from '../../../ContentViewDetailActions';
import {
  selectCreateFilterRuleStatus,
} from '../../../ContentViewDetailSelectors';

const AddEditDebPackageRuleModal = ({ filterId, onClose, selectedFilterRuleData }) => {
  const {
    id: editingId,
    name: editingName,
    arch: editingArchitecture,
  } = selectedFilterRuleData || {};

  const isEditing = !!selectedFilterRuleData;


  const [name, setName] = useState(editingName || '');
  const [architecture, setArchitecture] = useState(editingArchitecture || '');
  const [saving, setSaving] = useState(false);
  const dispatch = useDispatch();
  const status = useSelector(state => selectCreateFilterRuleStatus(state));

  const submitDisabled = !name || name.length === 0;

  const onSubmit = () => {
    setSaving(true);
    dispatch(isEditing ?
      editCVFilterRule(
        filterId,
        {
          id: editingId,
          name,
          architecture,
        },
        () => {
          dispatch(getCVFilterRules(filterId));
          onClose();
        },
      ) :
      addCVFilterRule(
        filterId,
        { name, architecture }, () => {
          dispatch(getCVFilterRules(filterId));
          onClose();
        },
      ));
  };

  useDeepCompareEffect(() => {
    if (status === STATUS.ERROR) {
      setSaving(false);
    }
  }, [status, setSaving]);

  return (
    <Modal
      ouiaId="add-edit-deb-filter-rule-modal"
      title={selectedFilterRuleData ? __('Edit package filter rule') : __('Create package filter rule')}
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
        <FormGroup label={__('DEB name')} isRequired fieldId="name">
          <TextInput
            ouiaId="input-name"
            isRequired
            type="text"
            id="name"
            aria-label="input_name"
            name="name"
            value={name}
            onChange={(_event, value) => setName(value)}
          />
        </FormGroup>
        <FormGroup label={__('Architecture')} fieldId="architecture">
          <TextInput
            ouiaId="input-architecture"
            type="text"
            id="architecture"
            aria-label="input_architecture"
            name="architecture"
            value={architecture}
            onChange={(_event, value) => setArchitecture(value)}
          />
        </FormGroup>
        <ActionGroup>
          <Button
            ouiaId="create-deb-package-filter-rule"
            aria-label="create_deb_package_filter_rule"
            variant="primary"
            isDisabled={saving || submitDisabled}
            type="submit"
          >
            {selectedFilterRuleData ? __('Edit rule') : __('Create rule')}
          </Button>
          <Button ouiaId="cancel-button" variant="link" onClick={onClose}>
            {__('Cancel')}
          </Button>
        </ActionGroup>
      </Form>
    </Modal>
  );
};

AddEditDebPackageRuleModal.propTypes = {
  filterId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  onClose: PropTypes.func,
  selectedFilterRuleData: PropTypes.shape({
    id: PropTypes.number,
    name: PropTypes.string,
    arch: PropTypes.string,
  }),
};

AddEditDebPackageRuleModal.defaultProps = {
  onClose: null,
  selectedFilterRuleData: undefined,
};

export default AddEditDebPackageRuleModal;
