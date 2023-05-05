import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { ActionGroup, Button, Form, FormGroup, Modal, ModalVariant, TextArea, TextInput } from '@patternfly/react-core';
import { editACS, getACSDetails } from '../../ACSActions';
import { areSubPathsValid, isValidUrl } from '../../helpers';

const ACSEditURLPaths = ({ onClose, acsId, acsDetails }) => {
  const { subpaths, base_url: url, alternate_content_source_type: acsType } = acsDetails;
  const dispatch = useDispatch();
  const [acsUrl, setAcsUrl] = useState(url);
  const [acsSubpath, setAcsSubpath] = useState(subpaths.join() || '');
  const [saving, setSaving] = useState(false);
  const subPathValidated = areSubPathsValid(acsSubpath) ? 'default' : 'error';
  const urlValidated = (acsUrl === '' || isValidUrl(acsUrl, acsType)) ? 'default' : 'error';
  const baseURLplaceholder = acsType === 'rhui' ?
    'https://rhui-server.example.com/pulp/content' :
    'http:// or https://';
  const helperTextInvalid = acsType === 'rhui' ?
    'http://rhui-server.example.com/pulp/content or https://rhui-server.example.com/pulp/content' :
    'http://, https:// or file://';

  const onSubmit = () => {
    setSaving(true);
    let params = {
      id: acsId,
      base_url: acsUrl,
    };
    if (acsSubpath !== '') {
      params = { subpaths: acsSubpath.split(','), ...params };
    } else {
      params = { subpaths: [], ...params };
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
      title={__('Edit URL and subpaths')}
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
          helperTextInvalid={helperTextInvalid}
          validated={urlValidated}
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
            onChange={value => setAcsUrl(value)}
          />
        </FormGroup>
        <FormGroup
          label={__('Subpaths')}
          type="string"
          fieldId="acs_subpaths"
          helperTextInvalid={__('Comma-separated list of subpaths. All subpaths must have a slash at the end and none at the front.')}
          validated={subPathValidated}
        >
          <TextArea
            placeholder="test/repo1/, test/repo2/,"
            value={acsSubpath}
            validated={subPathValidated}
            onChange={value => setAcsSubpath(value)}
            name="acs_subpath_field"
            id="acs_subpath_field"
            aria-label="acs_subpath_field"
          />
        </FormGroup>
        <ActionGroup>
          <Button
            ouiaId="edit-acs-url-submit"
            aria-label="edit_acs_url"
            variant="primary"
            isDisabled={saving ||
                acsUrl.length === 0 ||
                subPathValidated === 'error' ||
                urlValidated === 'error'
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
    id: PropTypes.number,
  }),
};

ACSEditURLPaths.defaultProps = {
  acsDetails: {
    alternate_content_source_type: '',
    base_url: '',
    subpaths: '',
    id: undefined,
  },
};

export default ACSEditURLPaths;
