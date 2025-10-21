import React, { useContext } from 'react';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  Alert,
  ClipboardCopy,
  Grid,
  GridItem,
  Form,
  FormGroup,
  FormSelect,
  FormSelectOption,
  Tile,
} from '@patternfly/react-core';
import { FormattedMessage } from 'react-intl';
import ACSCreateContext from '../ACSCreateContext';
import WizardHeader from '../../../ContentViews/components/WizardHeader';

const SelectSource = () => {
  const {
    acsType, setAcsType, contentType, setContentType, setAuthentication,
  } = useContext(ACSCreateContext);

  const onSelect = (event) => {
    setAcsType(event.currentTarget.id);
    if (event.currentTarget.id === 'rhui') {
      setAuthentication('content_credentials');
    } else {
      setAuthentication('');
    }
  };
  const onKeyDown = (event) => {
    if (event.key === ' ' || event.key === 'Enter') {
      event.preventDefault();
      setAcsType(event.currentTarget.id);
    }
  };

  const typeOptions = [{ value: 'yum', label: __('Yum') }];
  if (acsType !== 'rhui') {
    typeOptions.push({ value: 'deb', label: __('Deb') });
    typeOptions.push({ value: 'file', label: __('File') });
  }

  return (
    <>
      <WizardHeader
        title={__('Select source type')}
        description={__('Alternate content sources define new locations to download content from at repository or smart proxy sync time.')}
      />
      <FormattedMessage
        className="acs-blurb"
        id="acs-blurb"
        defaultMessage={__('Content will be synced from the alternate content source first, then the original source if the ACS is not reachable.')}
      />
      <Form>
        <FormGroup
          label={__('Source type')}
          type="string"
          fieldId="source_type"
          isRequired
        >
          <Grid hasGutter>
            <GridItem span={4} rowSpan={2}>
              <Tile
                title={__('Custom')}
                isStacked
                id="custom"
                onClick={onSelect}
                onKeyDown={onKeyDown}
                style={{ height: '100%' }}
                isSelected={acsType === 'custom'}
              >
                {__('Define repositories structured under a common web or filesystem path.')}
              </Tile>
            </GridItem>
            <GridItem span={4} rowSpan={2}>
              <Tile
                title={__('Simplified')}
                isStacked
                id="simplified"
                onClick={onSelect}
                onKeyDown={onKeyDown}
                style={{ height: '100%' }}
                isSelected={acsType === 'simplified'}
              >
                {__('Sync smart proxy content directly from upstream repositories by selecting the desired products.')}
              </Tile>
            </GridItem>
            <GridItem span={4} rowSpan={2}>
              <Tile
                title={__('RHUI')}
                isStacked
                id="rhui"
                onClick={onSelect}
                onKeyDown={onKeyDown}
                style={{ height: '100%' }}
                isSelected={acsType === 'rhui'}
              >
                {__('Define RHUI repository paths with guided steps.')}
              </Tile>
            </GridItem>
          </Grid>
        </FormGroup>
        <FormGroup
          label={__('Content type')}
          type="string"
          fieldId="content_type"
          isRequired
        >
          <FormSelect
            ouiaId="content-type-select"
            isRequired
            isDisabled={acsType === 'rhui'}
            value={contentType}
            onChange={(_event, value) => {
              setContentType(value);
            }}
            aria-label="FormSelect Input"
          >
            {
              typeOptions.map(option => (
                <FormSelectOption
                  key={option.value}
                  value={option.value}
                  label={option.label}
                />
              ))
            }
          </FormSelect>
        </FormGroup>
        {acsType === 'rhui' &&
        <>
          <Alert
            ouiaId="rhui-cert-alert"
            variant="info"
            title={__('Generate RHUI certificates for the desired repositories as necessary.')}
          />
          <ClipboardCopy hoverTip="Copy" clickTip="Copied" variant="inline-compact" isBlock>
            rhui-manager client cert --name rhui-acs-certs --days 365 --dir /root
            --repo_label rhui-repo-1,rhui-repo-2
          </ClipboardCopy>
          <a href="/content_credentials">
            {__('Create content credentials with the generated SSL certificate and key.')}
          </a>
        </>
        }
      </Form>
    </>
  );
};

export default SelectSource;
