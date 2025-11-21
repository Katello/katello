import React, { useContext } from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  ClipboardCopy,
  Form,
  FormGroup,
  TextInput,
  TextArea,
  FormHelperText,
  HelperText,
  HelperTextItem,
} from '@patternfly/react-core';
import ACSCreateContext from '../ACSCreateContext';
import WizardHeader from '../../../ContentViews/components/WizardHeader';
import { areSubPathsValid, isValidUrl } from '../../helpers';

const AcsUrlPaths = () => {
  const {
    acsType, url, setUrl, subpaths, setSubpaths, contentType,
    distributions, setDistributions,
    components, setComponents,
    architectures, setArchitectures,
  } = useContext(ACSCreateContext);

  const urlValidated = (url === '' || isValidUrl(url, acsType)) ? 'default' : 'error';
  const subPathValidated = areSubPathsValid(subpaths) ? 'default' : 'error';
  const debMode = contentType == 'deb';
  const needDistributions = debMode && acsType === 'custom';
  const toList = (s) => (s || '').trim().split(/[,\s]+/).filter(Boolean);
  const distributionValidated =
        (!needDistributions || toList(distributions).length > 0) ? 'default' : 'error';

  const baseURLplaceholder = acsType === 'rhui' ?
    'https://rhui-server.example.com/pulp/content' :
    'http://, https:// or file://';
  const helperTextInvalid = acsType === 'rhui' ?
    'http://rhui-server.example.com/pulp/content or https://rhui-server.example.com/pulp/content' :
    'http://, https:// or file://';
  let headerDescription =
    __('Enter in the base path and any subpaths that should be searched for alternate content.');
  headerDescription = acsType === 'rhui' ?
    `${headerDescription}${__(' The base path must be a web address pointing to the root RHUI content directory.')}` :
    `${headerDescription}${__(' The base path can be a web address or a filesystem location.')}`;

  return (
    <>
      <WizardHeader
        title={__('URL and paths')}
        description={headerDescription}
      />
      <Form>
        <FormGroup
          label={__('Base URL')}
          fieldId="acs_base_url"
          isRequired
        >
          <TextInput
            isRequired
            type="url"
            id="acs_base_url_field"
            ouiaId="acs_base_url_field"
            name="acs_base_url_field"
            aria-label="acs_base_url_field"
            placeholder={baseURLplaceholder}
            value={url}
            validated={urlValidated}
            onChange={(_event, value) => setUrl(value)}
          />
          {urlValidated === 'error' && (
            <FormHelperText>
              <HelperText>
                <HelperTextItem variant="error">
                  {helperTextInvalid}
                </HelperTextItem>
              </HelperText>
            </FormHelperText>
          )}
        </FormGroup>
        {acsType === 'rhui' &&
        <>
          {__('On the RHUA Instance, check the available repositories.')}
          <ClipboardCopy hoverTip="Copy" clickTip="Copied" variant="inline-compact" isBlock>
            rhui-manager repo list
          </ClipboardCopy>
          {__('Find the relative path for each RHUI repository and combine them in a comma-separated list.')}
          <ClipboardCopy hoverTip="Copy" clickTip="Copied" variant="inline-compact" isBlock>
            rhui-manager repo info --repo_id your_repo_id
          </ClipboardCopy>
        </>
        }
        {!debMode ? (
          <FormGroup
            label={__('Subpaths')}
            type="string"
          >
            <TextArea
              placeholder="test/repo1/, test/repo2/,"
              value={subpaths}
              validated={subPathValidated}
              onChange={(_event, value) => setSubpaths(value)}
              name="acs_subpath_field"
              id="acs_subpath_field"
              aria-label="acs_subpath_field"
            />
            {subPathValidated === 'error' && (
              <FormHelperText>
                <HelperText>
                  <HelperTextItem variant="error">
                    {__('Comma-separated list of subpaths. All subpaths must have a slash at the end and none at the front.')}
                  </HelperTextItem>
                </HelperText>
              </FormHelperText>)}
          </FormGroup>
        ) : (
          <>
            <FormGroup
              label={__('Distributions')}
              isRequired={acsType === 'custom'}
              fieldId="acs_distributions"
            >
              <TextInput
                id="acs_distributions"
                name="acs_distributions"
                placeholder="bookworm bullseye"
                value={distributions}
                onChange={(_e, v) => setDistributions(v)}
                validated={distributionValidated}
              />
              {distributionValidated === 'error' && (
                <FormHelperText>
                  <HelperText>
                    <HelperTextItem variant="error">
                      {__('At least one distribution is required for custom Deb ACS.')}
                    </HelperTextItem>
                  </HelperText>
                </FormHelperText>
              )}
            </FormGroup>
            <FormGroup label={__('Components')} fieldId="acs_components">
              <TextInput
                id="acs_components"
                name="acs_components"
                placeholder="main contrib"
                value={components}
                onChange={(_e, v) => setComponents(v)}
              />
            </FormGroup>
            <FormGroup label={__('Architectures')} fieldId="acs_architectures">
              <TextInput
                id="acs_architectures"
                name="acs_architectures"
                placeholder="amd64 arm64"
                value={architectures}
                onChange={(_e, v) => setArchitectures(v)}
              />
            </FormGroup>
          </>
        )}
      </Form>
    </>
  );
};

export default AcsUrlPaths;
