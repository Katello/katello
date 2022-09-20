import React, { useState } from 'react';
import {
  GridItem,
  Label,
} from '@patternfly/react-core';

import { translate as __ } from 'foremanReact/common/I18n';
import PropTypes from 'prop-types';

import HostsModal from './HostsModal';

const Hosts = ({
  contentHosts, hostsWithoutContent,
}) => {
  const [modalHosts, setModalHosts] = useState(false);
  const [modalIgnored, setModalIgnored] = useState(false);

  const titleHosts = __('Hosts to update');
  const titleIgnored = __('Ignored hosts');

  return (
    <>
      <GridItem span={7}>
        {hostsWithoutContent.length > 0 &&
        <p>
          { __('Some hosts are not registered as content hosts and will be ignored.') }
        </p>
}
        {contentHosts.length > 0 && (<Label color="green" href="#" onClick={() => setModalHosts(true)}>{titleHosts}: {contentHosts.length}</Label>)}
        {' '}
        {hostsWithoutContent.length > 0 && (<Label color="orange" href="#" onClick={() => setModalIgnored(true)}>{titleIgnored}: {hostsWithoutContent.length}</Label>)}

        <HostsModal
          hosts={contentHosts}
          isOpen={modalHosts}
          setModalOpenState={setModalHosts}
          modalTitle={titleHosts}
        />
        <HostsModal
          hosts={hostsWithoutContent}
          isOpen={modalIgnored}
          setModalOpenState={setModalIgnored}
          modalTitle={titleIgnored}
        />
      </GridItem>
    </>
  );
};

Hosts.propTypes = {
  contentHosts: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  hostsWithoutContent: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
};

export default Hosts;
