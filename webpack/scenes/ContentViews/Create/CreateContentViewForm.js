import { STATUS } from 'foremanReact/constants';
import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import { useDispatch, useSelector } from 'react-redux';
import { Redirect } from 'react-router-dom';
import { translate as __ } from 'foremanReact/common/I18n';
import { Form, FormGroup, TextInput, TextArea, Checkbox, ActionGroup, Button, Tile, Grid, GridItem } from '@patternfly/react-core';
import { createContentView } from '../ContentViewsActions';
import { selectCreateContentViews, selectCreateContentViewStatus, selectCreateContentViewError } from './ContentViewCreateSelectors';
import { LabelDependencies, LabelAutoPublish, LabelImportOnly } from './ContentViewFormComponents';
import ContentViewIcon from '../components/ContentViewIcon';

const CreateContentViewForm = ({ setModalOpen }) => {
  const dispatch = useDispatch();
  const [name, setName] = useState('');
  const [label, setLabel] = useState('');
  const [description, setDescription] = useState('');
  const [composite, setComposite] = useState(false);
  const [component, setComponent] = useState(true);
  const [autoPublish, setAutoPublish] = useState(false);
  const [importOnly, setImportOnly] = useState(false);
  const [dependencies, setDependencies] = useState(false);
  const [redirect, setRedirect] = useState(false);
  const [saving, setSaving] = useState(false);

  const response = useSelector(selectCreateContentViews);
  const status = useSelector(selectCreateContentViewStatus);
  const error = useSelector(selectCreateContentViewError);

  useEffect(() => {
    const { id } = response;
    if (id && status === STATUS.RESOLVED) {
      setSaving(false);
      setRedirect(true);
    } else if (status === STATUS.ERROR) {
      setSaving(false);
    }
  }, [JSON.stringify(response), status, error]);

  const onSave = () => {
    setSaving(true);
    dispatch(createContentView({
      name,
      label,
      description,
      composite,
      solve_dependencies: dependencies,
      auto_publish: (autoPublish && composite),
      import_only: importOnly,
    }));
  };

  useEffect(
    () => {
      setLabel(name.replace(/ /g, '_'));
    },
    [name],
  );

  if (redirect) {
    const { id } = response;
    return (<Redirect to={`/labs/content_views/${id}`} />);
  }

  return (
    <Form>
      <FormGroup label="Name" isRequired fieldId="name">
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
      <FormGroup label="Label" isRequired fieldId="label">
        <TextInput
          isRequired
          type="text"
          id="label"
          aria-label="input_label"
          name="label"
          value={label}
          onChange={value => setLabel(value)}
        />
      </FormGroup>
      <FormGroup label="Description" fieldId="description">
        <TextArea
          isRequired
          type="text"
          id="description"
          name="description"
          aria-label="input_description"
          value={description}
          onChange={value => setDescription(value)}
        />
      </FormGroup>
      <FormGroup isInline fieldId="type" label="Type">
        <Grid hasGutter>
          <GridItem span={6}>
            <Tile
              isStacked
              aria-label="component_tile"
              icon={<ContentViewIcon composite={false} />}
              id="component"
              title="Component content view"
              onClick={() => { setComponent(true); setComposite(false); }}
              isSelected={component}
            >
              {__('Single content view consisting of repositories')}
            </Tile>
          </GridItem>
          <GridItem span={6}>
            <Tile
              isStacked
              aria-label="composite_tile"
              icon={<ContentViewIcon composite />}
              id="composite"
              title="Composite content view"
              onClick={() => { setComposite(true); setComponent(false); }}
              isSelected={composite}
            >
              {__('Consists of component content views')}
            </Tile>
          </GridItem>
        </Grid>
      </FormGroup>
      {!composite &&
        <FormGroup isInline fieldId="dependencies">
          <Checkbox
            id="dependencies"
            name="dependencies"
            label={LabelDependencies()}
            isChecked={dependencies}
            onChange={checked => setDependencies(checked)}
          />
        </FormGroup>}
      {!composite &&
        <FormGroup isInline fieldId="importOnly">
          <Checkbox
            id="importOnly"
            name="importOnly"
            label={LabelImportOnly()}
            isChecked={importOnly}
            onChange={checked => setImportOnly(checked)}
          />
        </FormGroup>}
      {composite &&
        <FormGroup isInline fieldId="autoPublish">
          <Checkbox
            id="autoPublish"
            name="autoPublish"
            label={LabelAutoPublish()}
            isChecked={autoPublish}
            onChange={checked => setAutoPublish(checked)}
          />
        </FormGroup>}
      <ActionGroup>
        <Button aria-label="create_content_view" variant="primary" isDisabled={saving} onClick={() => onSave()}>{__('Create content view')}</Button>
        <Button variant="link" onClick={() => setModalOpen(false)}>{__('Cancel')}</Button>
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
