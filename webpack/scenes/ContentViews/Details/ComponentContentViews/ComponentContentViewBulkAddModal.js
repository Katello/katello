import React, { useState, useMemo } from 'react';
import { last } from 'lodash';
import PropTypes from 'prop-types';
import {
  Flex, Modal, ModalVariant, FormSelect,
  FormSelectOption, Checkbox, Form, FormGroup,
  ActionGroup, Button, Card, CardTitle, CardBody, Tooltip,
} from '@patternfly/react-core';
import { OutlinedQuestionCircleIcon } from '@patternfly/react-icons';
import { useDispatch } from 'react-redux';
import { translate as __ } from 'foremanReact/common/I18n';
import { addComponent } from '../ContentViewDetailActions';

const ComponentContentViewBulkAddModal = ({ cvId, rowsToAdd, onClose }) => {
  const dispatch = useDispatch();
  const [versionSelectOptions, setVersionSelectOptions] = useState({});
  const [selectedVersion, setSelectedVersion] = useState({});
  const [selectedComponentLatest, setSelectedComponentLatest] = useState({});

  useMemo(() => {
    const versionSelect = {};
    const versionSelectedOption = {};
    const componentLatest = {};
    rowsToAdd.forEach((row) => {
      const { componentCvVersions: versions, componentCvName: name } = row;
      const sortedVersions = [].concat(versions).sort((a, b) => (a.id > b.id ? 1 : -1));
      versionSelect[name] = sortedVersions;
      versionSelectedOption[name] = last(sortedVersions)?.id;
      componentLatest[name] = sortedVersions && sortedVersions?.length === 0;
    });
    setVersionSelectOptions(versionSelect);
    setSelectedVersion(versionSelectedOption);
    setSelectedComponentLatest(componentLatest);
  }, [rowsToAdd, setVersionSelectOptions, setSelectedVersion, setSelectedComponentLatest]);

  const bulkAddParams = () => rowsToAdd.map((row) => {
    const { componentCvId: id, componentCvName: name } = row;
    if (selectedComponentLatest[name]) {
      return { latest: true, content_view_id: id };
    }
    return { content_view_version_id: selectedVersion[name] };
  });

  const onSubmit = () => {
    dispatch(addComponent({
      compositeContentViewId: cvId,
      components: bulkAddParams(),
    }));
    onClose();
  };

  return (
    <Modal
      title={__('Add content views')}
      variant={ModalVariant.large}
      isOpen
      description={__('Select available version of content views to use')}
      onClose={onClose}
      appendTo={document.body}
    >
      <Form onSubmit={(e) => {
        e.preventDefault();
        onSubmit();
      }}
      >
        {Object.keys(versionSelectOptions).sort().map(componentCvName => (
          <Card key={componentCvName}>
            <CardTitle aria-label={componentCvName}>{componentCvName}</CardTitle>
            <CardBody>
              <FormGroup label={__('Version')} isRequired fieldId="version">
                <FormSelect
                  value={selectedVersion[componentCvName]}
                  isDisabled={versionSelectOptions[componentCvName].length <= 1}
                  onChange={value =>
                    setSelectedVersion({ ...selectedVersion, ...{ [componentCvName]: value } })}
                  id={`horzontal-form-title-${componentCvName}`}
                  name="horizontal-form-title"
                  aria-label={`version-select-${componentCvName}`}
                >
                  {versionSelectOptions[componentCvName].map((version, index) => (
                    // eslint-disable-next-line react/no-array-index-key
                    <FormSelectOption aria-label={`${componentCvName}-${version.version}`} key={index} value={version.id} label={`${__('Version')} ${version.version}`} />
                  ))}
                </FormSelect>
              </FormGroup>
              <FormGroup style={{ marginTop: '1em' }}>
                <Flex style={{ display: 'inline-flex' }}>
                  <Checkbox
                    style={{ marginTop: 0 }}
                    id={`latest-${componentCvName}`}
                    name="latest"
                    label={__('Always update to latest version')}
                    isChecked={selectedComponentLatest[componentCvName]}
                    onChange={checked =>
                      setSelectedComponentLatest({
                        ...selectedComponentLatest,
                        ...{ [componentCvName]: checked },
                      })
                    }
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
            </CardBody>
          </Card>
        ))}
        <ActionGroup>
          <Button ouiaId="add-components-modal-add" aria-label="add_components" variant="primary" type="submit">{__('Add')}</Button>
          <Button ouiaId="add-components-modal-cancel" variant="link" onClick={onClose}>{__('Cancel')}</Button>
        </ActionGroup>
      </Form>
    </Modal >);
};

ComponentContentViewBulkAddModal.propTypes = {
  cvId: PropTypes.oneOfType([
    PropTypes.number,
    PropTypes.string,
  ]).isRequired,
  rowsToAdd: PropTypes.arrayOf(PropTypes.shape({})),
  onClose: PropTypes.func,
};

ComponentContentViewBulkAddModal.defaultProps = {
  rowsToAdd: [],
  onClose: null,
};

export default ComponentContentViewBulkAddModal;
