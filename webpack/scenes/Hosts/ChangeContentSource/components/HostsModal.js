import React, { useState } from 'react';
import {
  Button,
  Modal,
  ModalVariant,
  List, ListItem,
  SearchInput,
} from '@patternfly/react-core';

import { translate as __ } from 'foremanReact/common/I18n';
import { foremanUrl } from 'foremanReact/common/helpers';

import PropTypes from 'prop-types';

const HostsModal = ({
  hosts, isOpen, setModalOpenState, modalTitle,
}) => {
  const [search, setSearch] = useState('');

  return (
    <Modal
      variant={ModalVariant.small}
      title={modalTitle}
      position="top"
      isOpen={isOpen}
      onClose={() => setModalOpenState(false)}
    >
      <SearchInput
        placeholder={__('Search')}
        value={search}
        onChange={v => setSearch(v)}
        onClear={() => setSearch('')}
      />
      <List isPlain isBordered className="margin-top-16">
        {(search ? hosts.filter(h => (`${h.name}`).includes(search)) : hosts).map(h => (
          <ListItem key={h.id}>
            <Button
              component="a"
              href={foremanUrl(`/new/hosts/${h.name}`)}
              variant="link"
              target="_blank"
              isInline
            >
              {h.name}
            </Button>
          </ListItem>
        ))}
      </List>
    </Modal>);
};

HostsModal.propTypes = {
  hosts: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  isOpen: PropTypes.bool.isRequired,
  setModalOpenState: PropTypes.func.isRequired,
  modalTitle: PropTypes.string.isRequired,
};

export default HostsModal;
