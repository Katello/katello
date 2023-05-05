import React, { useState } from 'react';
import PropTypes from 'prop-types';
import {
  Modal, ModalVariant, TextInput,
  Checkbox, Form, FormGroup,
  ActionGroup, Button, Tooltip,
  TooltipPosition,
} from '@patternfly/react-core';
import { OutlinedQuestionCircleIcon } from '@patternfly/react-icons';
import { useDispatch } from 'react-redux';
import { translate as __ } from 'foremanReact/common/I18n';
import { createBookmark, getBookmarks } from './BookmarkActions';

const AddBookmarkModal = ({ selectedItem, onClose, controller }) => {
  const dispatch = useDispatch();
  const [name, setName] = useState(selectedItem);
  const [query, setQuery] = useState(selectedItem);
  const [isPublic, setIsPublic] = useState(false);
  const submitDisabled = !name || !query;

  const onSubmit = (e) => {
    e.preventDefault();
    dispatch(createBookmark({
      controller, name, query, public: isPublic,
    }, () =>
      dispatch(getBookmarks(controller))));
    onClose();
  };

  return (
    <Modal
      ouiaId="add-bookmark-modal"
      title={__('Add Bookmark')}
      variant={ModalVariant.small}
      isOpen
      onClose={onClose}
      appendTo={document.body}
    >
      <Form onSubmit={onSubmit}>
        <FormGroup label={__('Name')} isRequired fieldId="name">
          <TextInput
            ouiaId="name-input"
            isRequired
            type="text"
            id="name"
            aria-label="input_name"
            name="name"
            value={name}
            onChange={setName}
          />
        </FormGroup>
        <FormGroup label={__('Search Query')} isRequired fieldId="query">
          <TextInput
            ouiaId="query-inout"
            isRequired
            type="text"
            id="query"
            aria-label="input_query"
            name="query"
            value={query}
            onChange={setQuery}
          />
        </FormGroup>
        <FormGroup fieldId="public" isInline>
          <Checkbox
            ouiaId="public-checkbox"
            id="public"
            name="public"
            label={__('Public')}
            isChecked={isPublic}
            onChange={setIsPublic}
          />
          <Tooltip
            position={TooltipPosition.top}
            content={
              __('Bookmarks marked as public are available to all users')
            }
          >
            <OutlinedQuestionCircleIcon />
          </Tooltip>
        </FormGroup>
        <ActionGroup>
          <Button variant="primary" type="submit" isDisabled={submitDisabled} ouiaId="save-button">
            {__('Save')}
          </Button>
          <Button variant="link" onClick={onClose} ouiaId="cancel-button">{__('Cancel')}</Button>
        </ActionGroup>
      </Form>
    </Modal>);
};

AddBookmarkModal.propTypes = {
  controller: PropTypes.string.isRequired,
  onClose: PropTypes.func.isRequired,
  selectedItem: PropTypes.string,
};

AddBookmarkModal.defaultProps = {
  selectedItem: '',
};

export default AddBookmarkModal;
