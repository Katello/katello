import React, { useState } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { useDispatch, useSelector } from 'react-redux';
import { STATUS } from 'foremanReact/constants';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { Modal, ModalVariant, Form, FormGroup, TextInput, ActionGroup, Button, Select, SelectOption } from '@patternfly/react-core';
import { createPackageFilterRule } from '../../../ContentViewDetailActions';
import {
  selectCreatePackageFilterRule, selectCreatePackageFilterRuleError,
  selectCreatePackageFilterRuleStatus,
} from '../../../ContentViewDetailSelectors';

const AddPackageRuleModal = ({
  filterId, show, setIsOpen, setRuleSaved,
}) => {
  const versionComparators = ['All versions', 'Equal to', 'Greater than', 'Less than', 'Range'];
  // ['All Versions', 'Equal to', 'Greater than', 'Less than', 'Range'];

  const versionComparatorStaticTranslated = {
    'All versions': __('All Versions'),
    'Equal to': __('Equal to'),
    'Greater than': __('Greater than'),
    'Less than': __('Less than'),
    Range: __('Range'),
  };
  const [name, setName] = useState('');
  const [architecture, setArchitecture] = useState('');
  const [version, setVersion] = useState('');
  const [minVersion, setMinVersion] = useState('');
  const [maxVersion, setMaxVersion] = useState('');
  const [versionComparator, setVersionComparator] = useState('All versions');
  const [saving, setSaving] = useState(false);
  const [versionComparatorSelectOpen, setVersionComparatorSelectOpen] = useState(false);
  const dispatch = useDispatch();
  const response = useSelector(state => selectCreatePackageFilterRule(state));
  const status = useSelector(state => selectCreatePackageFilterRuleStatus(state));
  const error = useSelector(state => selectCreatePackageFilterRuleError(state));

  const showVersion = () => (versionComparator === 'Equal to');
  const showMinVersion = () => (versionComparator === 'Greater than' || versionComparator === 'Range');
  const showMaxVersion = () => (versionComparator === 'Less than' || versionComparator === 'Range');

  const formVersionParams = () => {
    switch (versionComparator) {
      case 'All Versions':
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

  const onSave = () => {
    setSaving(true);
    dispatch(createPackageFilterRule(
      filterId,
      { name, architecture, ...formVersionParams() },
    ));
  };

  const onSelect = (event, selection) => {
    setVersionComparator(selection);
    setVersionComparatorSelectOpen(false);
  };

  useDeepCompareEffect(() => {
    const { id } = response || {};
    if (id && status === STATUS.RESOLVED && saving) {
      setSaving(false);
      setRuleSaved(true);
      setIsOpen(false);
    } else if (status === STATUS.ERROR) {
      setSaving(false);
    }
  }, [response, status, error, saving]);

  return (
    <Modal
      title={__('Create package filter rule')}
      variant={ModalVariant.small}
      isOpen={show}
      onClose={() => {
        setIsOpen(false);
      }}
      appendTo={document.body}
    >
      <Form>
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
          <Select
            selections={versionComparator}
            onSelect={onSelect}
            isOpen={versionComparatorSelectOpen}
            onToggle={isExpanded => setVersionComparatorSelectOpen(isExpanded)}
            id="version_comparator"
            name="version_comparator"
            aria-label="version_comparator"
          >
            {
              versionComparators.map(item => (
                <SelectOption key={item} value={item}>
                  {versionComparatorStaticTranslated[item]}
                </SelectOption>))
            }
          </Select>
        </FormGroup>
        {showVersion() &&
        <FormGroup label={__('Version')} fieldId="version">
          <TextInput
            type="text"
            id="version"
            aria-label="input_version"
            name="version"
            value={version}
            onChange={value => setVersion(value)}
          />
        </FormGroup>}
        {showMinVersion() &&
        <FormGroup label={__('Minimum Version')} fieldId="min_version">
          <TextInput
            type="text"
            id="min_version"
            aria-label="input_min_version"
            name="min_version"
            value={minVersion}
            onChange={value => setMinVersion(value)}
          />
        </FormGroup>}
        {showMaxVersion() &&
        <FormGroup label={__('Maximum Version')} fieldId="max_version">
          <TextInput
            type="text"
            id="max_version"
            aria-label="input_max_version"
            name="max_version"
            value={maxVersion}
            onChange={value => setMaxVersion(value)}
          />
        </FormGroup>}
        <ActionGroup>
          <Button
            aria-label="create_package_filter_rule"
            variant="primary"
            isDisabled={saving}
            onClick={() => onSave()}
          >
            {__('Create rule')}
          </Button>
          <Button variant="link" onClick={() => setIsOpen(false)}>
            {__('Cancel')}
          </Button>
        </ActionGroup>
      </Form>
    </Modal>
  );
};

AddPackageRuleModal.propTypes = {
  filterId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  show: PropTypes.bool.isRequired,
  setIsOpen: PropTypes.func,
  setRuleSaved: PropTypes.func,
};

AddPackageRuleModal.defaultProps = {
  setIsOpen: null,
  setRuleSaved: null,
};

export default AddPackageRuleModal;
