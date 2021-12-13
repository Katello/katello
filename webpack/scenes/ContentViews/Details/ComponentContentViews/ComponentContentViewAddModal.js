import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import {
  Flex, Modal, ModalVariant, FormSelect,
  FormSelectOption, Checkbox, Form, FormGroup,
  ActionGroup, Button, Tooltip,
} from '@patternfly/react-core';
import { OutlinedQuestionCircleIcon } from '@patternfly/react-icons';
import { useDispatch, useSelector, shallowEqual } from 'react-redux';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import {
  selectCVDetails,
  selectCVDetailStatus,
  selectCVDetailError,
} from '../../Details/ContentViewDetailSelectors';
import { addComponent } from '../ContentViewDetailActions';

const ComponentContentViewAddModal = ({
  cvId, componentCvId, componentId, latest, show, setIsOpen,
}) => {
  const dispatch = useDispatch();
  const componentDetails = useSelector(
    state => selectCVDetails(state, componentCvId),
    shallowEqual,
  );
  const componentStatus = useSelector(
    state => selectCVDetailStatus(state, componentCvId),
    shallowEqual,
  );
  const componentError = useSelector(
    state => selectCVDetailError(state, componentCvId),
    shallowEqual,
  );
  const [cvName, setCvName] = useState('');
  const [options, setOptions] = useState([]);
  const [formLatest, setFormLatest] = useState(componentId ? latest : false);
  const [selected, setSelected] = useState(null);
  const versionsLoading = componentStatus === STATUS.PENDING;

  useEffect(() => {
    if (!versionsLoading && componentDetails) {
      const { name, versions } = componentDetails;
      const versionMutable = versions;
      setCvName(name);
      const opt = versionMutable.map(item => ({ value: item.id, label: __(`Version ${item.version}`) }));
      setOptions([...opt].reverse());
      setSelected(opt.slice(-1)[0].value);
    }
  }, [componentDetails, componentStatus, componentError, versionsLoading]);

  const getAddParams = () => {
    if (formLatest) {
      return [{ latest: true, content_view_id: componentCvId }];
    }
    return [{ content_view_version_id: selected }];
  };

  const getUpdateParams = () => {
    if (formLatest) {
      return { id: componentId, latest: formLatest, compositeContentViewId: cvId };
    }
    return { id: componentId, compositeContentViewId: cvId, content_view_version_id: selected };
  };

  const updateLatest = (checked) => {
    setFormLatest(checked);
    if (checked) setSelected(options[0]);
  };

  const onSubmit = () => {
    if (componentId) {
      dispatch(addComponent({
        compositeContentViewId: cvId,
        components: getUpdateParams(),
      }));
    } else {
      dispatch(addComponent({
        compositeContentViewId: cvId,
        components: getAddParams(),
      }));
    }
    setIsOpen(false);
  };

  if (show && versionsLoading) return null;

  return (
    <Modal
      title={componentId ? __('Update version') : __('Add component')}
      variant={ModalVariant.small}
      isOpen={show}
      description={__(`Select available version of ${cvName} to use`)}
      onClose={() => {
        setIsOpen(false);
      }}
      appendTo={document.body}
    >
      <Form onSubmit={(e) => {
        e.preventDefault();
        onSubmit();
      }}
      >
        <FormGroup label={__('Version')} isRequired fieldId="version">
          <FormSelect
            value={selected}
            isDisabled={formLatest || options.length === 1}
            onChange={value => setSelected(value)}
            id="horzontal-form-title"
            name="horizontal-form-title"
            aria-label="CvVersion"
          >
            {options.map((option, index) => (
              // eslint-disable-next-line react/no-array-index-key
              <FormSelectOption key={index} value={option.value} label={option.label} />
            ))}
          </FormSelect>
        </FormGroup>
        <FormGroup fieldId="latest">
          <Flex style={{ display: 'inline-flex' }}>
            <Checkbox
              style={{ marginTop: 0 }}
              id="latest"
              name="latest"
              label={__('Always update to latest version')}
              isChecked={formLatest}
              onChange={checked => updateLatest(checked)}
            />
            <Tooltip
              position="top"
              content={
                __('This content view will be automatically updated to the latest version.')
              }
            >
              <OutlinedQuestionCircleIcon />
            </Tooltip>
          </Flex>
        </FormGroup>
        <ActionGroup>
          <Button aria-label="add_component" variant="primary" type="submit">{__('Submit')}</Button>
          <Button variant="link" onClick={() => setIsOpen(false)}>{__('Cancel')}</Button>
        </ActionGroup>
      </Form>
    </Modal >);
};

ComponentContentViewAddModal.propTypes = {
  cvId: PropTypes.oneOfType([
    PropTypes.number,
    PropTypes.string,
  ]).isRequired,
  componentCvId: PropTypes.oneOfType([
    PropTypes.number,
    PropTypes.string,
  ]).isRequired,
  componentId: PropTypes.oneOfType([
    PropTypes.number,
    PropTypes.string,
  ]),
  latest: PropTypes.bool,
  show: PropTypes.bool,
  setIsOpen: PropTypes.func,
};

ComponentContentViewAddModal.defaultProps = {
  componentId: null,
  latest: false,
  show: false,
  setIsOpen: null,
};

export default ComponentContentViewAddModal;
