import React, { useState, useEffect } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { Redirect } from 'react-router-dom';
import { useDispatch, useSelector } from 'react-redux';
import { STATUS } from 'foremanReact/constants';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  Modal,
  ModalVariant,
  Form,
  FormGroup,
  TextInput,
  ActionGroup,
  Button,
  Radio,
  TextArea,
  Split,
  SplitItem,
} from '@patternfly/react-core';
import {
  Select,
  SelectOption,
} from '@patternfly/react-core/deprecated';
import { addCVFilterRule, createContentViewFilter, getRepositoryTypes } from '../../ContentViewDetailActions';
import { selectCreateContentViewFilter, selectCreateContentViewFilterStatus,
  selectCreateContentViewFilterError, selectCreateFilterRule,
  selectCreateFilterRuleError, selectCreateFilterRuleStatus,
  selectRepoTypes, selectRepoTypesStatus } from '../../../Details/ContentViewDetailSelectors';
import { CONTENT_VIEW_NEEDS_PUBLISH, FILTER_TYPES } from '../../../ContentViewsConstants';
import ContentType from '../ContentType';

const CVFilterAddModal = ({ cvId, onClose }) => {
  const [inclusion, setInclusion] = useState(true);
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [type, setType] = useState('rpm');
  const [saving, setSaving] = useState(false);
  const [typeSelectOpen, setTypeSelectOpen] = useState(false);
  const dispatch = useDispatch();
  const response = useSelector(state => selectCreateContentViewFilter(state));
  const status = useSelector(state => selectCreateContentViewFilterStatus(state));
  const error = useSelector(state => selectCreateContentViewFilterError(state));
  const ruleResponse = useSelector(state => selectCreateFilterRule(state));
  const ruleStatus = useSelector(state => selectCreateFilterRuleStatus(state));
  const ruleError = useSelector(state => selectCreateFilterRuleError(state));
  const repoTypesResponse = useSelector(state => selectRepoTypes(state));
  const repoTypesStatus = useSelector(state => selectRepoTypesStatus(state));
  const [redirect, setRedirect] = useState(false);
  const [repoTypes, setRepoTypes] = useState([]);

  useEffect(() => {
    dispatch(getRepositoryTypes());
  }, [dispatch]);

  const onSubmit = () => {
    setSaving(true);
    dispatch(createContentViewFilter(
      cvId,
      {
        name, description, inclusion, type,
      }, () => dispatch({ type: CONTENT_VIEW_NEEDS_PUBLISH }),
    ));
  };

  const onSelect = (event, selection) => {
    setType(selection);
    setTypeSelectOpen(false);
  };

  useDeepCompareEffect(() => {
    const { id } = response || {};
    if (id && status === STATUS.RESOLVED && saving) {
      // We need to create an empty rule for Errata by Date type once the Filter is created.
      if (type === 'erratum_date') {
        dispatch(addCVFilterRule(id, { types: ['security', 'enhancement', 'bugfix'] }));
      } else {
        setSaving(false);
        setRedirect(true);
      }
    } else if (status === STATUS.ERROR) {
      setSaving(false);
    }
  }, [response, status, error, saving, dispatch, type]);

  useDeepCompareEffect(() => {
    const { id: filterId } = response || {};
    const { id: filterRuleId } = ruleResponse || {};
    if (filterId && filterRuleId &&
      status === STATUS.RESOLVED && ruleStatus === STATUS.RESOLVED &&
      saving) {
      setSaving(false);
      setRedirect(true);
    }
  }, [response, status, ruleResponse, ruleStatus, ruleError, saving]);

  useDeepCompareEffect(() => {
    if (repoTypesStatus === STATUS.RESOLVED && repoTypesResponse) {
      const allRepoTypes = [];
      repoTypesResponse.forEach((repoType) => {
        const { name: repoTypeName } = repoType;
        allRepoTypes.push(repoTypeName);
      });
      setRepoTypes(allRepoTypes);
    }
  }, [repoTypesResponse, repoTypesStatus]);

  const filterTypeOptions = () => {
    const filterTypeSelectOpions = FILTER_TYPES.map(item =>
      <SelectOption key={item} value={item}><ContentType type={item} /></SelectOption>);
    if (repoTypes.includes('deb')) {
      filterTypeSelectOpions.push(<SelectOption key="deb" value="deb"><ContentType type="deb" /></SelectOption>);
    }
    return filterTypeSelectOpions;
  };

  if (redirect) {
    const { id } = response;
    return (<Redirect to={`/filters/${id}`} />);
  }

  return (
    <Modal
      title={__('Create filter')}
      variant={ModalVariant.large}
      isOpen
      ouiaId="create-filter-modal"
      onClose={onClose}
      appendTo={document.body}
    >
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
            ouiaId="input_name"
            name="name"
            value={name}
            onChange={(_event, value) => setName(value)}
          />
        </FormGroup>
        <FormGroup label={__('Content type')} isRequired fieldId="content_type">
          <Select
            selections={type}
            onSelect={onSelect}
            isOpen={typeSelectOpen}
            onToggle={(_event, val) => setTypeSelectOpen(val)}
            ouiaId="content_type"
            id="content_type"
            name="content_type"
            aria-label="ContentType"
          >
            { filterTypeOptions() }
          </Select>
        </FormGroup>
        <FormGroup>
          <Split hasGutter>
            <SplitItem>
              <Radio
                isChecked={inclusion}
                name="radio-1"
                onChange={(_event, checked) => setInclusion(checked)}
                label={__('Include filter')}
                id="include_filter"
                ouiaId="include_filter"
                value="includeFilter"
                style={{ margin: '1px' }}
              />
            </SplitItem>
            <SplitItem>
              <Radio
                isChecked={!inclusion}
                name="radio-1"
                onChange={(_event, checked) => setInclusion(!checked)}
                label={__('Exclude filter')}
                id="exclude_filter"
                ouiaId="exclude_filter"
                value="excludeFilter"
                style={{ margin: '1px' }}
              />
            </SplitItem>
          </Split>
        </FormGroup>
        <FormGroup label={__('Description')} fieldId="description">
          <TextArea
            type="text"
            id="description"
            name="description"
            aria-label="input_description"
            value={description}
            resizeOrientation="vertical"
            autoResize
            style={{ maxHeight: '200px', minHeight: '36px' }}
            onChange={(_event, value) => setDescription(value)}
          />
        </FormGroup>
        <ActionGroup>
          <Button
            ouiaId="create-filter-form-submit-button"
            aria-label="create_filter"
            variant="primary"
            isDisabled={saving || name.length === 0}
            type="submit"
          >
            {__('Create filter')}
          </Button>
          <Button ouiaId="create-filter-form-cancel-button" variant="link" onClick={onClose}>
            {__('Cancel')}
          </Button>
        </ActionGroup>
      </Form>
    </Modal>
  );
};

CVFilterAddModal.propTypes = {
  cvId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  onClose: PropTypes.func,
};

CVFilterAddModal.defaultProps = {
  onClose: null,
};

export default CVFilterAddModal;
