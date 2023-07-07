import React, {
  useState,
} from 'react';
import PropTypes from 'prop-types';
import { Dropdown, DropdownItem, KebabToggle, DropdownPosition } from '@patternfly/react-core';
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
      key="delete"
      component="button"
      onClick={handleModalToggle}
    >
      {__('Delete')}
    </DropdownItem>,
    <DropdownItem
      ouiaId="linkbacktooldpage"
      key="link"
      href={`../../../activation_keys/${akId}`}
    >
      {__('Old Activation key Details Page')}
    </DropdownItem>];
  return (
    <Dropdown
      ouiaId="dekete-action"
      onSelect={onSelect}
      position={DropdownPosition.right}
      toggle={<KebabToggle id="toggle-kebab" onToggle={onToggle} />}
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

