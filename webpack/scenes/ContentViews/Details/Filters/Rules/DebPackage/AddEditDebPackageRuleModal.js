import React, { useState } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { useDispatch, useSelector } from 'react-redux';
import { STATUS } from 'foremanReact/constants';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  Modal, ModalVariant, Form, FormGroup, TextInput,
  ActionGroup, Button, FormSelect, FormSelectOption, Popover,
} from '@patternfly/react-core';
import {
  HelpIcon,
} from '@patternfly/react-icons';
import { addCVFilterRule, editCVFilterRule, getCVFilterRules } from '../../../ContentViewDetailActions';
import {
  selectCreateFilterRuleStatus,
} from '../../../ContentViewDetailSelectors';
import { orgId } from '../../../../../../services/api';
import SearchText from '../../../../../../components/Search/SearchText';
import { CONTENT_VIEW_NEEDS_PUBLISH } from '../../../../ContentViewsConstants';

const AddEditDebPackageRuleModal = ({
  filterId, onClose, selectedFilterRuleData, repositoryIds,
}) => {
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
  const showMinVersion =
    versionComparator === VersionModifiers['Greater than'] ||
    versionComparator === VersionModifiers.Range;
  const showMaxVersion =
    versionComparator === VersionModifiers['Less than'] ||
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
    dispatch({ type: CONTENT_VIEW_NEEDS_PUBLISH });
  };

  useDeepCompareEffect(() => {
    if (status === STATUS.ERROR) {
      setSaving(false);
    }
  }, [status, setSaving]);

  const nameAutoCompleteEndpoint = '/katello/api/v2/debs/auto_complete_name';
  const archAutoCompleteEndpoint = '/katello/api/v2/debs/auto_complete_arch';
  const searchDataProp = term => ({
    organization_id: orgId(),
    term,
    repoids: repositoryIds,
  });

  return (
    <Modal
      ouiaId="add-edit-deb-filter-rule-modal"
      title={selectedFilterRuleData ? __('Edit DEB rule') : __('Add DEB rule')}
      variant={ModalVariant.small}
      isOpen
      onClose={onClose}
      appendTo={document.body}
      help={
        <Popover
          headerContent={__('Help')}
          bodyContent={__('Filter rules may include or exclude specific Debian packages ' +
        'by name, architecture, and version. Version comparisons follow Debian policy ' +
        '(epoch:upstream-revision; "~" sorts before empty). Leave all version fields ' +
        'blank to match all versions.')}
        >
          <Button variant="plain" aria-label="Help" ouiaId="deb-filter-rule-modal-help">
            <HelpIcon />
          </Button>
        </Popover>
      }
    >
      <Form onSubmit={(e) => {
        e.preventDefault();
        onSubmit();
      }}
      >
        <FormGroup label={__('DEB name')} isRequired fieldId="name">
          <SearchText
            data={{
              autocomplete: {
                url: nameAutoCompleteEndpoint,
                apiParams: input => searchDataProp(input),
              },
            }}
            onSearchChange={setName}
            initialQuery={name}
          />
        </FormGroup>
        <FormGroup label={__('Architecture')} fieldId="architecture">
          <SearchText
            data={{
              autocomplete: {
                url: archAutoCompleteEndpoint,
                apiParams: arch => searchDataProp(arch),
              },
            }}
            onSearchChange={setArchitecture}
            initialQuery={architecture}
          />
        </FormGroup>
        <FormGroup label={__('Version')} fieldId="version_comparator">
          <FormSelect
            ouiaId="deb-version-comparator"
            value={versionComparator}
            onChange={(_event, val) => setVersionComparator(val)}
            id="version_comparator"
            name="version_comparator"
            aria-label="version_comparator"
          >
            {Object.entries(VersionModifiers).map(([key, label]) => (
              <FormSelectOption key={key} value={key} label={label} />
            ))}
          </FormSelect>
        </FormGroup>
        {showVersion &&
          <FormGroup label={__('Version')} fieldId="version">
            <TextInput
              ouiaId="deb-input-version"
              type="text"
              id="version"
              aria-label="input_version"
              name="version"
              value={version}
              onChange={(_event, val) => setVersion(val)}
            />
          </FormGroup>}
        {showMinVersion &&
          <FormGroup label={__('Minimum version')} fieldId="min_version">
            <TextInput
              ouiaId="deb-input-min-version"
              type="text"
              id="min_version"
              aria-label="input_min_version"
              name="min_version"
              value={minVersion}
              onChange={(_event, val) => setMinVersion(val)}
            />
          </FormGroup>}
        {showMaxVersion &&
          <FormGroup label={__('Maximum version')} fieldId="max_version">
            <TextInput
              ouiaId="deb-input-max-version"
              type="text"
              id="max_version"
              aria-label="input_max_version"
              name="max_version"
              value={maxVersion}
              onChange={(_event, val) => setMaxVersion(val)}
            />
          </FormGroup>}
        <ActionGroup>
          <Button
            ouiaId="add-edit-deb-package-modal-submit"
            aria-label="add_deb_package_filter_rule"
            variant="primary"
            isDisabled={saving || submitDisabled}
            type="submit"
          >
            {selectedFilterRuleData ? __('Save') : __('Add rule')}
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
    version: PropTypes.string,
    min_version: PropTypes.string,
    max_version: PropTypes.string,
  }),
  repositoryIds: PropTypes.arrayOf(PropTypes.number),
};

AddEditDebPackageRuleModal.defaultProps = {
  onClose: null,
  selectedFilterRuleData: undefined,
  repositoryIds: [],
};

export default AddEditDebPackageRuleModal;
