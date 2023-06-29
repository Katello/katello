import React from 'react';
import PropTypes from 'prop-types';
import { Dropdown, DropdownItem, KebabToggle, DropdownPosition } from '@patternfly/react-core';
import { noop } from 'foremanReact/common/helpers';

const DeleteMenu = ({ handleModalToggle, akId }) => {
  const [isOpen, setIsOpen] = React.useState(false);
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
      Delete
    </DropdownItem>,
    <DropdownItem
      ouiaId="linkbacktooldpage"
      key="link"
      href={`../../../activation_keys/${akId}`}
    >
      Old Activation key Details Page
    </DropdownItem>];
  return (
    <React.Fragment>
      <Dropdown
        ouiaId="dekete-action"
        onSelect={onSelect}
        position={DropdownPosition.right}
        toggle={<KebabToggle id="toggle-kebab" onToggle={onToggle} />}
        isOpen={isOpen}
        isPlain
        dropdownItems={dropdownItems}
      />
    </React.Fragment>
  );
};

DeleteMenu.propTypes = {
  handleModalToggle: PropTypes.func,
  akId: PropTypes.string,
};

DeleteMenu.defaultProps = {
  handleModalToggle: noop,
  akId: '',
};

export default DeleteMenu;

