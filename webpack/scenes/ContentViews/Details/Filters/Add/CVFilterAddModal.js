import React, { useState } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { Redirect } from 'react-router-dom';
import { useDispatch, useSelector } from 'react-redux';
import { STATUS } from 'foremanReact/constants';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { Modal, ModalVariant, Form, FormGroup, TextInput, ActionGroup, Button, Radio, TextArea,
  Split, SplitItem, Select, SelectOption } from '@patternfly/react-core';
import { addCVFilterRule, createContentViewFilter } from '../../ContentViewDetailActions';
import {
  selectCreateContentViewFilter, selectCreateContentViewFilterStatus,
  selectCreateContentViewFilterError, selectCreateFilterRule,
  selectCreateFilterRuleError, selectCreateFilterRuleStatus,
} from '../../../Details/ContentViewDetailSelectors';
import { FILTER_TYPES } from '../../../ContentViewsConstants';
import ContentType from '../ContentType';

const CVFilterAddModal = ({ cvId, show, setIsOpen }) => {
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
  const [redirect, setRedirect] = useState(false);

  const onSave = () => {
    setSaving(true);
    dispatch(createContentViewFilter(
      cvId,
      {
        name, description, inclusion, type,
      },
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

  if (redirect) {
    const { id } = response;
    return (<Redirect to={`/filters/${id}`} />);
  }

  return (
    <Modal
      title={__('Create filter')}
      variant={ModalVariant.large}
      isOpen={show}
      onClose={() => {
        setIsOpen(false);
      }}
      appendTo={document.body}
    >
      <Form>
        <FormGroup label={__('Name')} isRequired fieldId="name">
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
        <FormGroup>
          <Split hasGutter>
            <SplitItem>
              <Radio
                isChecked={inclusion}
                name="radio-1"
                onChange={checked => setInclusion(checked)}
                label="Include Filter"
                id="include_filter"
                value="includeFilter"
              />
            </SplitItem>
            <SplitItem>
              <Radio
                isChecked={!inclusion}
                name="radio-1"
                onChange={checked => setInclusion(!checked)}
                label="Exclude Filter"
                id="exclude_filter"
                value="excludeFilter"
              />
            </SplitItem>
          </Split>
        </FormGroup>
        <FormGroup label={__('Content type')} isRequired fieldId="content_type">
          <Select
            selections={type}
            onSelect={onSelect}
            isOpen={typeSelectOpen}
            onToggle={isExpanded => setTypeSelectOpen(isExpanded)}
            id="content_type"
            name="content_type"
            aria-label="ContentType"
          >
            {
              FILTER_TYPES.map(item =>
                <SelectOption key={item} value={item}><ContentType type={item} /></SelectOption>)
            }
          </Select>
        </FormGroup>
        <FormGroup label={__('Description')} fieldId="description">
          <TextArea
            type="text"
            id="description"
            name="description"
            aria-label="input_description"
            value={description}
            onChange={value => setDescription(value)}
          />
        </FormGroup>
        <ActionGroup>
          <Button
            aria-label="create_filter"
            variant="primary"
            isDisabled={saving}
            onClick={() => onSave()}
          >
            {__('Create filter')}
          </Button>
          <Button variant="link" onClick={() => setIsOpen(false)}>
            {__('Cancel')}
          </Button>
        </ActionGroup>
      </Form>
    </Modal>
  );
};

CVFilterAddModal.propTypes = {
  cvId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  show: PropTypes.bool.isRequired,
  setIsOpen: PropTypes.func,
};

CVFilterAddModal.defaultProps = {
  setIsOpen: null,
};

export default CVFilterAddModal;
