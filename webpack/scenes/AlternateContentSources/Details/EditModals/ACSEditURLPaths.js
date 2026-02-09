import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import {
  ActionGroup,
  Button,
  Form,
  FormGroup,
  Modal,
  ModalVariant,
  TextArea,
  TextInput,
  FormHelperText,
  HelperText,
  HelperTextItem,
} from '@patternfly/react-core';
import { editACS, getACSDetails } from '../../ACSActions';
import { areSubPathsValid, isValidUrl, spaceSepOrEmpty, toList } from '../../helpers';

const ACSEditURLPaths = ({ onClose, acsId, acsDetails }) => {
  const {
    subpaths,
    base_url: url,
    alternate_content_source_type: acsType,
    content_type: contentType,
    deb_releases: distInit = '',
    deb_components: compInit = '',
    deb_architectures: archInit = '',
  } = acsDetails;
  const dispatch = useDispatch();
  const [acsUrl, setAcsUrl] = useState(url);
  const [acsSubpath, setAcsSubpath] = useState((subpaths && subpaths.join()) || '');
  const [debReleases, setDebReleases] = useState(distInit || '');
  const [debComponents, setDebComponents] = useState(compInit || '');
  const [debArchitectures, setDebArchitectures] = useState(archInit || '');
  const [saving, setSaving] = useState(false);
  const debMode = contentType === 'deb';
  const subPathValidated = debMode || areSubPathsValid(acsSubpath) ? 'default' : 'error';
  const urlValidated = (acsUrl === '' || isValidUrl(acsUrl, acsType)) ? 'default' : 'error';
  const needDebReleases = debMode && acsType === 'custom';
  const debReleasesValidated = (!needDebReleases || toList(debReleases).length > 0) ? 'default' : 'error';
  const baseURLplaceholder = acsType === 'rhui' ?
    'https://rhui-server.example.com/pulp/content' :
    'http://, https:// or file://';
  const helperTextInvalid = acsType === 'rhui' ?
    'http://rhui-server.example.com/pulp/content or https://rhui-server.example.com/pulp/content' :
    'http://, https:// or file://';

  const onSubmit = () => {
    setSaving(true);
    let params = {
      id: acsId,
      base_url: acsUrl,
    };
    if (debMode) {
      params = {
        ...params,
        deb_releases: spaceSepOrEmpty(debReleases),
        deb_components: spaceSepOrEmpty(debComponents),
        deb_architectures: spaceSepOrEmpty(debArchitectures),
        subpaths: [],
      };
    } else {
      params = {
        ...params,
        subpaths: (acsSubpath !== '') ? acsSubpath.split(',').map(s => s.trim()) : [],
      };
    }
    dispatch(editACS(
      acsId,
      params,
      () => {
        dispatch(getACSDetails(acsId));
        onClose();
      },
      () => {
        setSaving(false);
      },
    ));
  };

  return (
    <Modal
      title={debMode ? __('Edit URL and Debian fields') : __('Edit URL and subpaths')}
      variant={ModalVariant.small}
      isOpen
      onClose={onClose}
      appendTo={document.body}
      ouiaId="acs-edit-url-paths-modal"
    >
      <Form onSubmit={(e) => {
        e.preventDefault();
        onSubmit();
      }}
      >
        <FormGroup
          label={__('Base URL')}
          type="string"
          fieldId="acs_base_url"
          isRequired
        >
          <TextInput
            ouiaId="acs-base-url-field"
            isRequired
            type="text"
            id="acs_base_url_field"
            name="acs_base_url_field"
            aria-label="acs_base_url_field"
            placeholder={baseURLplaceholder}
            value={acsUrl}
            validated={urlValidated}
            onChange={(_event, value) => setAcsUrl(value)}
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
        {!debMode ? (
          <FormGroup
            label={__('Subpaths')}
            type="string"
            fieldId="acs_subpaths"
          >
            <TextArea
              placeholder="test/repo1/, test/repo2/,"
              value={acsSubpath}
              validated={subPathValidated}
              onChange={(_event, value) => setAcsSubpath(value)}
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
              </FormHelperText>
            )}
          </FormGroup>
        ) : (
          <>
            <FormGroup
              label={__('Releases/Distributions')}
              isRequired={acsType === 'custom'}
              fieldId="acs_deb_releases"
            >
              <TextInput
                id="acs_deb_releases"
                name="acs_deb_releases"
                ouiaId="acs_deb_releases"
                placeholder="bookworm bullseye"
                value={debReleases}
                onChange={(_e, v) => setDebReleases(v)}
                validated={debReleasesValidated}
              />
              {debReleasesValidated === 'error' && (
                <FormHelperText>
                  <HelperText>
                    <HelperTextItem variant="error">
                      {__('At least one distribution is required for custom Deb ACS.')}
                    </HelperTextItem>
                  </HelperText>
                </FormHelperText>
              )}
            </FormGroup>
            <FormGroup label={__('Components')} fieldId="acs_deb_components">
              <TextInput
                id="acs_deb_components"
                name="acs_deb_components"
                ouiaId="acs_deb_components"
                placeholder="main contrib"
                value={debComponents}
                onChange={(_e, v) => setDebComponents(v)}
              />
            </FormGroup>
            <FormGroup label={__('Architectures')} fieldId="acs_deb_architectures">
              <TextInput
                id="acs_deb_architectures"
                name="acs_deb_architectures"
                ouiaId="acs_deb_architectures"
                placeholder="amd64 arm64"
                value={debArchitectures}
                onChange={(_e, v) => setDebArchitectures(v)}
              />
            </FormGroup>
          </>
        )}
        <ActionGroup>
          <Button
            ouiaId="edit-acs-url-submit"
            aria-label="edit_acs_url"
            variant="primary"
            isDisabled={saving ||
                acsUrl.length === 0 ||
                urlValidated === 'error' ||
                (debMode ? (debReleasesValidated === 'error') : (subPathValidated === 'error'))
            }
            isLoading={saving}
            type="submit"
          >
            {__('Edit')}
          </Button>
          <Button ouiaId="edit-acs-url-cancel" variant="link" onClick={onClose}>
            {__('Cancel')}
          </Button>
        </ActionGroup>
      </Form>
    </Modal>
  );
};

ACSEditURLPaths.propTypes = {
  acsId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  onClose: PropTypes.func.isRequired,
  acsDetails: PropTypes.shape({
    base_url: PropTypes.string,
    subpaths: PropTypes.arrayOf(PropTypes.string),
    alternate_content_source_type: PropTypes.string,
    content_type: PropTypes.string,
    deb_releases: PropTypes.string,
    deb_components: PropTypes.string,
    deb_architectures: PropTypes.string,
    id: PropTypes.number,
  }),
};

ACSEditURLPaths.defaultProps = {
  acsDetails: {
    alternate_content_source_type: '',
    base_url: '',
    subpaths: [],
    content_type: '',
    deb_releases: '',
    deb_components: '',
    deb_architectures: '',
    id: undefined,
  },
};

export default ACSEditURLPaths;
