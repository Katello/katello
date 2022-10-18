import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { ActionGroup, Button, Form, FormGroup, Modal, ModalVariant, Switch, TextArea, TextInput } from '@patternfly/react-core';
import { editACS, getACSDetails } from '../../ACSActions';
import { areSubPathsValid, isValidUrl } from '../../helpers';

const ACSEditURLPaths = ({ onClose, acsId, acsDetails }) => {
  const { subpaths, base_url: url, verify_ssl: verifySsl } = acsDetails;
  const dispatch = useDispatch();
  const [acsUrl, setAcsUrl] = useState(url);
  const [acsVerifySSL, setAcsVerifySSL] = useState(verifySsl);
  const [acsSubpath, setAcsSubpath] = useState(subpaths.join() || '');
  const [saving, setSaving] = useState(false);
  const subPathValidated = areSubPathsValid(acsSubpath) ? 'default' : 'error';
  const urlValidated = (acsUrl === '' || isValidUrl(acsUrl)) ? 'default' : 'error';

  const onSubmit = () => {
    setSaving(true);
    let params = {
      id: acsId,
      base_url: acsUrl,
      verify_ssl: acsVerifySSL,
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
          helperTextInvalid="http://, https:// or file://"
          validated={urlValidated}
          isRequired
        >
          <TextInput
            isRequired
            type="text"
            id="acs_base_url_field"
            name="acs_base_url_field"
            aria-label="acs_base_url_field"
            placeholder="https:// or file://"
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
        <FormGroup label={__('Verify SSL')} fieldId="verify_ssl">
          <Switch
            id="verify-ssl-switch"
            aria-label="verify-ssl-switch"
            isChecked={acsVerifySSL}
            onChange={checked => setAcsVerifySSL(checked)}
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
            {__('Edit ACS')}
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
    verify_ssl: PropTypes.bool,
    id: PropTypes.number,
  }),
};

ACSEditURLPaths.defaultProps = {
  acsDetails: {
    base_url: '',
    subpaths: '',
    id: undefined,
    verify_ssl: false,
  },
};

export default ACSEditURLPaths;
