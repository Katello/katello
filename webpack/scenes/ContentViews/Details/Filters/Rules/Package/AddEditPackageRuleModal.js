import React, { useState } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { useDispatch, useSelector } from 'react-redux';
import { STATUS } from 'foremanReact/constants';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  Modal, ModalVariant, Form, FormGroup, TextInput,
  ActionGroup, Button, FormSelect, FormSelectOption,
} from '@patternfly/react-core';
import { addCVFilterRule, editCVFilterRule, getCVFilterRules } from '../../../ContentViewDetailActions';
import {
  selectCreateFilterRuleStatus,
} from '../../../ContentViewDetailSelectors';

const AddEditPackageRuleModal = ({ filterId, onClose, selectedFilterRuleData }) => {
  const {
    id: editingId,
    name: editingName,
    arch: editingArchitecture,
    version: editingVersion,
    min_version: editingMinVersion,
    max_version: editingMaxVersion,
  } = selectedFilterRuleData || {};

  const isEditing = !!selectedFilterRuleData;

  const VersionModifiers = {
    'All versions': __('All versions'),
    'Equal to': __('Equal to'),
    'Greater than': __('Greater than'),
    'Less than': __('Less than'),
    /* eslint-disable quote-props */
    'Range': __('Range'),
  };

  const versionText = () => {
    switch (true) {
    case !!editingVersion: return VersionModifiers['Equal to'];
    case !!editingMinVersion && !editingMaxVersion: return VersionModifiers['Greater than'];
    case !editingMinVersion && !!editingMaxVersion: return VersionModifiers['Less than'];
    case !!editingMinVersion && !!editingMaxVersion: return VersionModifiers.Range;
    default: return VersionModifiers['All versions'];
    }
  };

  const [name, setName] = useState(editingName || '');
  const [architecture, setArchitecture] = useState(editingArchitecture || '');
  const [version, setVersion] = useState(editingVersion || '');
  const [minVersion, setMinVersion] = useState(editingMinVersion || '');
  const [maxVersion, setMaxVersion] = useState(editingMaxVersion || '');
  const [versionComparator, setVersionComparator] = useState(versionText(selectedFilterRuleData));
  const [saving, setSaving] = useState(false);
  const dispatch = useDispatch();
  const status = useSelector(state => selectCreateFilterRuleStatus(state));

  const submitDisabled = !name || name.length === 0;

  const showVersion = versionComparator === VersionModifiers['Equal to'];
  const showMinVersion = versionComparator === VersionModifiers['Greater than'] ||
    versionComparator === VersionModifiers.Range;
  const showMaxVersion = versionComparator === VersionModifiers['Less than'] ||
    versionComparator === VersionModifiers.Range;

  const formVersionParams = () => {
    switch (versionComparator) {
    case 'All versions':
      return {};
    case 'Equal to':
      return { version };
    case 'Greater than':
      return { min_version: minVersion };
    case 'Less than':
      return { max_version: maxVersion };
    case 'Range':
      return { min_version: minVersion, max_version: maxVersion };
    default:
      return {};
    }
  };

  const onSubmit = () => {
    setSaving(true);
    dispatch(isEditing ?
      editCVFilterRule(
        filterId,
        {
          id: editingId,
          name,
          architecture,
          ...formVersionParams(),
        },
        () => {
          dispatch(getCVFilterRules(filterId));
          onClose();
        },
      ) :
      addCVFilterRule(
        filterId,
        { name, architecture, ...formVersionParams() }, () => {
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
      title={selectedFilterRuleData ? __('Edit RPM rule') : __('Add RPM rule')}
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
        <FormGroup label={__('RPM name')} isRequired fieldId="name">
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
        <FormGroup label={__('Architecture')} fieldId="architecture">
          <TextInput
            type="text"
            id="architecture"
            aria-label="input_architecture"
            name="architecture"
            value={architecture}
            onChange={value => setArchitecture(value)}
          />
        </FormGroup>
        <FormGroup label={__('Version')} fieldId="version_comparator">
          <FormSelect
            value={versionComparator}
            onChange={setVersionComparator}
            id="version_comparator"
            name="version_comparator"
            aria-label="version_comparator"
          >
            {
              Object.values(VersionModifiers).map(item => (
                <FormSelectOption key={item} value={item} label={VersionModifiers[item]} />))
            }
          </FormSelect>
        </FormGroup>
        {showVersion &&
          <FormGroup label={__('Version')} fieldId="version">
            <TextInput
              type="text"
              id="version"
              aria-label="input_version"
              name="version"
              value={version}
              onChange={setVersion}
            />
          </FormGroup>}
        {showMinVersion &&
          <FormGroup label={__('Minimum version')} fieldId="min_version">
            <TextInput
              type="text"
              id="min_version"
              aria-label="input_min_version"
              name="min_version"
              value={minVersion}
              onChange={setMinVersion}
            />
          </FormGroup>}
        {showMaxVersion &&
          <FormGroup label={__('Maximum version')} fieldId="max_version">
            <TextInput
              type="text"
              id="max_version"
              aria-label="input_max_version"
              name="max_version"
              value={maxVersion}
              onChange={setMaxVersion}
            />
          </FormGroup>}
        <ActionGroup>
          <Button
            aria-label="add_package_filter_rule"
            variant="primary"
            isDisabled={saving || submitDisabled}
            type="submit"
          >
            {selectedFilterRuleData ? __('Edit rule') : __('Add rule')}
          </Button>
          <Button variant="link" onClick={onClose}>
            {__('Cancel')}
          </Button>
        </ActionGroup>
      </Form>
    </Modal>
  );
};

AddEditPackageRuleModal.propTypes = {
  filterId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  onClose: PropTypes.func,
  selectedFilterRuleData: PropTypes.shape({
    id: PropTypes.number,
    name: PropTypes.string,
    arch: PropTypes.string,
    version: PropTypes.string,
    min_version: PropTypes.string,
    max_version: PropTypes.string,
  }),
};

AddEditPackageRuleModal.defaultProps = {
  onClose: null,
  selectedFilterRuleData: undefined,
};

export default AddEditPackageRuleModal;
