import { STATUS } from 'foremanReact/constants';
import React, { useState, useEffect } from 'react';
import PropTypes from 'prop-types';
import { useDispatch, useSelector } from 'react-redux';
import { Redirect } from 'react-router-dom';
import { Form, FormGroup, TextInput, TextArea, Checkbox, Radio, ActionGroup, Button } from '@patternfly/react-core';
import { createContentView } from '../ContentViewsActions';
import { selectCreateContentViews, selectCreateContentViewStatus, selectCreateContentViewError } from './ContentViewCreateSelectors';
import { LabelComponent, LabelComposite, LabelDependencies, LabelAutoPublish, LabelImportOnly } from './ContentViewFormComponents';

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
      <FormGroup isInline fieldId="component">
        <Radio
          id="component"
          name="component"
          role="radio"
          label={LabelComponent()}
          isChecked={component}
          onChange={(checked) => { setComponent(checked); setComposite(!checked); }}
          description="Consists of repositories"
        />
      </FormGroup>
      <FormGroup isInline fieldId="composite">
        <Radio
          id="composite"
          name="composite"
          role="radio"
          label={LabelComposite()}
          isChecked={composite}
          onChange={(checked) => { setComposite(checked); setComponent(!checked); }}
          description="Consists of more than one component view"
        />
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
        <Button aria-label="create_content_view" variant="primary" isDisabled={saving} onClick={() => onSave()}>Create Content View</Button>
        <Button variant="link" onClick={() => setModalOpen(false)}>Cancel</Button>
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
