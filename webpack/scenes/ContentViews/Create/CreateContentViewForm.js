import React, { useState, useEffect } from 'react';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { STATUS } from 'foremanReact/constants';
import { translate as __ } from 'foremanReact/common/I18n';
import PropTypes from 'prop-types';
import { useDispatch, useSelector } from 'react-redux';
import {
  Form,
  FormGroup,
  TextInput,
  TextArea,
  Checkbox,
  ActionGroup,
  Button,
  Tile,
  Grid,
  GridItem,
  FormHelperText,
  HelperText,
  HelperTextItem,
} from '@patternfly/react-core';
import { createContentView } from '../ContentViewsActions';
import {
  selectCreateContentViews,
  selectCreateContentViewStatus,
  selectCreateContentViewError,
} from './ContentViewCreateSelectors';
import { LabelDependencies, LabelAutoPublish } from './ContentViewFormComponents';
import ContentViewIcon from '../components/ContentViewIcon';
import './CreateContentViewForm.scss';

export const contentViewDescriptions = {
  CV: __('Contains repositories. Versions are published and optionally filtered.'),
  CCV: __('Contains content views. You must choose the version to use for each content view.'),
  RCV: __('Contains repositories. Always serves the latest synced content, without the need to publish versions.'),
};

const CreateContentViewForm = ({ setModalOpen }) => {
  const dispatch = useDispatch();
  const [name, setName] = useState('');
  const [label, setLabel] = useState('');
  const [description, setDescription] = useState('');
  const [composite, setComposite] = useState(false);
  const [component, setComponent] = useState(true);
  const [rolling, setRolling] = useState(false);
  const [autoPublish, setAutoPublish] = useState(false);
  const [dependencies, setDependencies] = useState(false);
  const [redirect, setRedirect] = useState(false);
  const [saving, setSaving] = useState(false);

  const [labelValidated, setLabelValidated] = useState('default');
  const handleLabelChange = (newLabel, _event) => {
    setLabel(newLabel);
    if (newLabel === '') {
      setLabelValidated('default');
    } else if (/^[\w-]+$/.test(newLabel)) {
      setLabelValidated('success');
    } else {
      setLabelValidated('error');
    }
  };

  const response = useSelector(selectCreateContentViews);
  const status = useSelector(selectCreateContentViewStatus);
  const error = useSelector(selectCreateContentViewError);

  useDeepCompareEffect(() => {
    const { id } = response;
    if (id && status === STATUS.RESOLVED && saving) {
      setSaving(false);
      setRedirect(true);
    } else if (status === STATUS.ERROR) {
      setSaving(false);
    }
  }, [response, status, error, saving]);

  const onSave = () => {
    setSaving(true);
    dispatch(createContentView({
      name,
      label,
      description,
      composite,
      rolling,
      solve_dependencies: (dependencies && !(rolling || composite)),
      auto_publish: (autoPublish && composite),
    }));
  };

  useEffect(() => {
    setLabel(name.replace(/[^A-Za-z0-9_-]/g, '_'));
  }, [name]);

  if (redirect) {
    const { id } = response;
    if (composite) {
      window.location.assign(`/content_views/${id}#/contentviews`);
    } else {
      window.location.assign(`/content_views/${id}#/repositories`);
    }
  }

  const submitDisabled =
    !name?.length || !label?.length || saving || redirect || labelValidated === 'error';

  return (
    <Form
      onSubmit={(e) => {
        e.preventDefault();
        onSave();
      }}
      id="create-content-view-form"
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
      <FormGroup
        label={__('Label')}
        isRequired
        fieldId="label"
      >
        <TextInput
          isRequired
          type="text"
          id="label"
          aria-label="input_label"
          ouiaId="input_label"
          name="label"
          value={label}
          validated={labelValidated}
          onChange={(_event, newLabel) => handleLabelChange(newLabel, _event)}
        />
        {labelValidated === 'error' && (
          <FormHelperText>
            <HelperText>
              <HelperTextItem variant="error">
                {__("Must be Ascii alphanumeric, '_' or '-'")}
              </HelperTextItem>
            </HelperText>
          </FormHelperText>
        )}
      </FormGroup>
      <FormGroup label={__('Description')} fieldId="description">
        <TextArea
          isRequired
          type="text"
          id="description"
          name="description"
          aria-label="input_description"
          value={description}
          onChange={(_event, value) => setDescription(value)}
        />
      </FormGroup>
      <FormGroup isInline fieldId="type" label={__('Type')}>
        <Grid hasGutter>
          <GridItem span={4}>
            <Tile
              style={{ height: '100%' }}
              isStacked
              aria-label="component_tile"
              icon={<ContentViewIcon composite={false} rolling={false} />}
              id="component"
              title={__('Content view')}
              onClick={() => { setComponent(true); setComposite(false); setRolling(false); }}
              isSelected={component}
            >
              {contentViewDescriptions.CV}
            </Tile>
          </GridItem>
          <GridItem span={4}>
            <Tile
              style={{ height: '100%' }}
              isStacked
              aria-label="composite_tile"
              icon={<ContentViewIcon composite rolling={false} />}
              id="composite"
              title={__('Composite content view')}
              onClick={() => { setComposite(true); setComponent(false); setRolling(false); }}
              isSelected={composite}
            >
              {contentViewDescriptions.CCV}
            </Tile>
          </GridItem>
          <GridItem span={4}>
            <Tile
              style={{ height: '100%' }}
              isStacked
              aria-label="rolling_tile"
              icon={<ContentViewIcon composite={false} rolling />}
              id="rolling"
              title={__('Rolling content view')}
              onClick={() => { setComposite(false); setComponent(false); setRolling(true); }}
              isSelected={rolling}
            >
              {contentViewDescriptions.RCV}
            </Tile>
          </GridItem>
        </Grid>
      </FormGroup>
      {!composite && !rolling && (
        <FormGroup isInline fieldId="dependencies">
          <Checkbox
            id="dependencies"
            ouiaId="dependencies"
            name="dependencies"
            label={LabelDependencies()}
            isChecked={dependencies}
            onChange={(_event, checked) => setDependencies(checked)}
          />
        </FormGroup>
      )}
      {composite && (
        <FormGroup isInline fieldId="autoPublish">
          <Checkbox
            id="autoPublish"
            ouiaId="autoPublish"
            name="autoPublish"
            label={LabelAutoPublish()}
            isChecked={autoPublish}
            onChange={(_event, checked) => setAutoPublish(checked)}
          />
        </FormGroup>
      )}
      <ActionGroup>
        <Button
          ouiaId="create-content-view-form-submit"
          aria-label="create_content_view"
          variant="primary"
          isDisabled={submitDisabled}
          isLoading={saving || redirect}
          type="submit"
        >
          {__('Create content view')}
        </Button>
        <Button
          ouiaId="create-content-view-form-cancel"
          variant="link"
          onClick={() => setModalOpen(false)}
        >
          {__('Cancel')}
        </Button>
      </ActionGroup>
    </Form>
  );
};

CreateContentViewForm.propTypes = {
  setModalOpen: PropTypes.func,
};

CreateContentViewForm.defaultProps = {
  setModalOpen: null,
};

export default CreateContentViewForm;
