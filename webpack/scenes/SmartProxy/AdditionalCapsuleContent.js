import React from 'react';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import ContentConfig from '../Content/ContentConfig';

const AdditionalCapsuleContent = ({ counts }) => {
  const {
    deb: debPackageCount = 0,
    docker_manifest: dockerManifestCount = 0,
    docker_manifest_list: dockerManifestListCount = 0,
    docker_tag: dockerTagCount = 0,
    file: fileCount = 0,
    erratum: errataCount = 0,
    package_group: packageGroup = 0,
    module_stream: moduleStreamCount = 0,
  } = counts;

  const contentConfigTypes = ContentConfig.filter(({ names: { capsuleCountLabel } }) =>
    !!counts[`${capsuleCountLabel}`])
    .map(({
      names: {
        capsuleCountLabel, pluralLowercase,
      },
    }) => {
      const countParam = `${capsuleCountLabel}`;
      const count = counts[countParam];
      return {
        pluralLowercase,
        count,
      };
    });

  return (
    <>
      {errataCount > 0 &&
      <>
        {`${errataCount} ${__('Errata')}`}<br />
      </>
            }
      {moduleStreamCount > 0 &&
      <>
        {`${moduleStreamCount} ${__('Module streams')}`}<br />
      </>
            }
      {packageGroup > 0 &&
      <>
        {`${packageGroup} ${__('Package groups')}`}<br />
      </>
            }
      {dockerTagCount > 0 &&
      <>
        {`${dockerTagCount} ${__('Container tags')}`}<br />
      </>
            }
      {dockerManifestCount > 0 &&
      <>
        {`${dockerManifestCount} ${__('Container manifests')}`}<br />
      </>
            }
      {dockerManifestListCount > 0 &&
      <>
        {`${dockerManifestListCount} ${__('Container manifest lists')}`}<br />
      </>
      }
      {fileCount > 0 &&
      <>
        {`${fileCount} ${__('Files')}`}<br />
      </>
            }
      {debPackageCount > 0 &&
      <>
        {`${debPackageCount} ${__('Debian packages')}`}<br />
      </>}
      {contentConfigTypes?.length > 0 &&
                contentConfigTypes.map(({ count, pluralLowercase }) => (
                  <React.Fragment key={pluralLowercase}>
                    {`${count} ${pluralLowercase}`}<br />
                  </React.Fragment>))
            }
    </>
  );
};

AdditionalCapsuleContent.propTypes = {
  counts: PropTypes.shape({
    deb: PropTypes.number,
    docker_manifest: PropTypes.number,
    docker_manifest_list: PropTypes.number,
    docker_tag: PropTypes.number,
    file: PropTypes.number,
    erratum: PropTypes.number,
    package_group: PropTypes.number,
    module_stream: PropTypes.number,
  }),
};

AdditionalCapsuleContent.defaultProps = {
  counts: {},
};

export default AdditionalCapsuleContent;
