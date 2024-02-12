import React, { useState } from 'react';
import PropTypes from 'prop-types';
import {
  TreeView,
} from '@patternfly/react-core';
import { translate as __ } from 'foremanReact/common/I18n';

const ErratumExpansionContents = ({ erratum }, debErratum) => {
  const {
    bugs, cves, deb_packages, packages,
    module_streams: moduleStreams,
  } = erratum;
  const [activeItems, setActiveItems] = useState(null);
  const options_all = [
    {
      name: __('Bugs'),
      id: 'bugs',
      children: bugs.map(bug => ({ name: bug.bug_id, id: bug.bug_id, ...bug })),
    },
    {
      name: __('CVEs'),
      id: 'cves',
      children: cves.map(cve => ({ name: cve.cve_id, id: cve.cve_id, ...cve })),
    },
  ];
  const options_deb = [
    {
      name: __('Debs'),
      id: 'deb_packages',
      // debs is just a list of strings
      children: deb_packages.map(deb => ({ id: `${deb.release}:${deb.name}-${deb.version}`, ...deb })),
    },
  ];
  const options_rpm = [
    {
      name: __('Packages'),
      id: 'packages',
      // packages is just a list of strings
      children: packages.map((packageName, idx) => ({ name: packageName, id: idx })),
    },
    {
      name: __('Module streams'),
      id: 'module_streams',
      children: moduleStreams.map(({ name, stream, id }) => ({ name: `${name}:${stream}`, id })),
    },
  ];
  return (
    <TreeView
      data={options_all.concat(debErratum ? options_deb : options_rpm)}
      activeItems={activeItems}
      onSelect={(evt, treeViewItem) => setActiveItems([treeViewItem])}
      hasBadges
    />
  );
};

ErratumExpansionContents.propTypes = {
  erratum: PropTypes.shape({
    title: PropTypes.string,
    description: PropTypes.string,
    summary: PropTypes.string,
    solution: PropTypes.string,
    bugs: PropTypes.arrayOf(PropTypes.shape({})),
    cves: PropTypes.arrayOf(PropTypes.shape({})),
    deb_packages: PropTypes.arrayOf(PropTypes.shape({})),
    packages: PropTypes.arrayOf(PropTypes.string),
    module_streams: PropTypes.arrayOf(PropTypes.shape({})),
  }).isRequired,
};

export default ErratumExpansionContents;
