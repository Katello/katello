import React, { useState } from 'react';
import PropTypes from 'prop-types';
import {
  Flex,
  Modal,
  ModalVariant,
  Checkbox,
  Form,
  FormGroup,
  ActionGroup,
  Button,
  Card,
  CardTitle,
  CardBody,
  Tooltip,
} from '@patternfly/react-core';
import {
  Select,
  SelectVariant,
  SelectOption,
} from '@patternfly/react-core/deprecated';
import { OutlinedQuestionCircleIcon } from '@patternfly/react-icons';
import { useDispatch } from 'react-redux';
import { translate as __ } from 'foremanReact/common/I18n';
import getContentViewDetails, { addComponent } from '../ContentViewDetailActions';
import { truncate } from '../../../../utils/helpers';

const ComponentContentViewBulkAddModal = ({ cvId, rowsToAdd, onClose }) => {
  const dispatch = useDispatch();
  const versionSelect = {};
  const versionSelectedOption = {};
  const componentLatest = {};
  rowsToAdd.forEach((row) => {
    const { componentCvVersions: versions, componentCvName: name } = row;
    versionSelect[name] = versions;
    versionSelectedOption[name] = versions[0]?.id;
    componentLatest[name] = versions && versions?.length === 0;
  });
  const [selectedVersion, setSelectedVersion] = useState(versionSelectedOption);
  const [selectedComponentLatest, setSelectedComponentLatest] = useState(componentLatest);
  const [cvVersionSelectOpen, setCvVersionSelectOpen] = useState('');

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
    }, () => dispatch(getContentViewDetails(cvId))));
    onClose();
  };

  return (
    <Modal
      title={__('Add content views')}
      variant={ModalVariant.large}
      ouiaId="add-content-views"
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
        {Object.keys(versionSelect).sort().map(componentCvName => (
          <Card
            ouiaId="componentCvName"
            aria-label="componentCvName"
            key={componentCvName}
          >
            <CardTitle aria-label={componentCvName}>{truncate(componentCvName)}</CardTitle>
            <CardBody>
              <FormGroup label={__('Version')} isRequired fieldId="version">
                <Select
                  variant={SelectVariant.typeahead}
                  selections={selectedVersion[componentCvName]}
                  ouiaId="select-version"
                  isDisabled={versionSelect[componentCvName].length <= 1 ||
                      selectedComponentLatest[componentCvName]}
                  onSelect={(__event, value) => {
                    setSelectedVersion({ ...selectedVersion, ...{ [componentCvName]: value } });
                    setCvVersionSelectOpen('');
                  }
                  }
                  isOpen={cvVersionSelectOpen === componentCvName}
                  onToggle={(_event, isExpanded) => setCvVersionSelectOpen(isExpanded ? componentCvName : '')}
                  id={`horzontal-form-title-${componentCvName}-${cvVersionSelectOpen[componentCvName]}`}
                  name="horizontal-form-title"
                  aria-label={`version-select-${componentCvName}`}
                  menuAppendTo="parent"
                  maxHeight="20rem"
                >
                  {versionSelect[componentCvName].map(version => (
                    <SelectOption
                      key={`${componentCvName}-${version.version}`}
                      aria-label={`${componentCvName}-${version.version}`}
                      value={version.id}
                      description={version.description}
                    >
                      <>{`${__('Version')} ${version.version}`}{__(` (${version.published_at_words} ago)`)}</>
                    </SelectOption>
                  ))}
                </Select>
              </FormGroup>
              <FormGroup style={{ marginTop: '1em' }}>
                <Flex style={{ display: 'inline-flex' }}>
                  <Checkbox
                    style={{ marginTop: 0 }}
                    id={`latest-${componentCvName}`}
                    ouiaId={`latest-${componentCvName}`}
                    name="latest"
                    label={__('Always update to latest version')}
                    isChecked={selectedComponentLatest[componentCvName]}
                    onChange={(_event, checked) => {
                      setSelectedComponentLatest({
                        ...selectedComponentLatest,
                        ...{ [componentCvName]: checked },
                      });
                      setSelectedVersion({
                        ...selectedVersion,
                        ...{ [componentCvName]: versionSelect[componentCvName][0]?.id },
                      });
                    }
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
