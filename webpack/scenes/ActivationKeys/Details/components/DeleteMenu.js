import React, {
  useState,
} from 'react';
import PropTypes from 'prop-types';
import {
  Split,
  Icon,
  Text,
} from '@patternfly/react-core';
import {
  Dropdown,
  DropdownItem,
  KebabToggle,
  DropdownPosition,
} from '@patternfly/react-core/deprecated';
import { UndoIcon, TrashIcon } from '@patternfly/react-icons';
import { noop } from 'foremanReact/common/helpers';
import { translate as __ } from 'foremanReact/common/I18n';

const DeleteMenu = ({ handleModalToggle, akId }) => {
  const [isOpen, setIsOpen] = useState(false);
  const onToggle = (isOpenValue) => {
    setIsOpen(isOpenValue);
  };
  const onFocus = () => {
    const element = document.getElementById('toggle-kebab');
    element.focus();
  };
  const onSelect = () => {
    setIsOpen(false);
    onFocus();
  };
  const dropdownItems = [
    <DropdownItem
      ouiaId="delete-menu-option"
      aria-label="delete-link"
      key="delete-link"
      component="button"
      onClick={handleModalToggle}
    >
      <Split hasGutter>
        <Icon>
          <TrashIcon />
        </Icon>
        <Text ouiaId="delete-text">
          {__('Delete')}
        </Text>
      </Split>
    </DropdownItem>,
    <DropdownItem
      ouiaId="ak-legacy-ui"
      key="ak-legacy-ui-link"
      href={`../../../activation_keys/${akId}`}
    >
      <Split hasGutter>
        <Icon>
          <UndoIcon />
        </Icon>
        <Text ouiaId="delete-text">
          {__('Legacy UI')}
        </Text>
      </Split>
    </DropdownItem>];
  return (
    <Dropdown
      ouiaId="dekete-action"
      onSelect={onSelect}
      position={DropdownPosition.right}
      toggle={<KebabToggle id="toggle-kebab" aria-label="delete-toggle" onToggle={(_event, isOpenValue) => onToggle(isOpenValue)} />}
      isOpen={isOpen}
      isPlain
      dropdownItems={dropdownItems}
    />
  );
};

DeleteMenu.propTypes = {
  handleModalToggle: PropTypes.func,
  akId: PropTypes.string.isRequired,
};

DeleteMenu.defaultProps = {
  handleModalToggle: noop,
};

export default DeleteMenu;

