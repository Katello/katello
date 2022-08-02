import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import PropTypes from 'prop-types';
import { translate as __ } from 'foremanReact/common/I18n';
import { ActionGroup, Button, Form, FormGroup, Modal, ModalVariant, TextArea, TextInput } from '@patternfly/react-core';
import { editACS, getACSDetails } from '../../ACSActions';

const ACSEditURLPaths = ({ onClose, acsId, acsDetails }) => {
  const { subpaths, base_url: url } = acsDetails;
  const dispatch = useDispatch();
  const [acsUrl, setAcsUrl] = useState(url);
  const [acsSubpath, setAcsSubpath] = useState(subpaths.join() || '');
  const [saving, setSaving] = useState(false);

  const onSubmit = () => {
    setSaving(true);
    let params = { id: acsId, base_url: acsUrl };
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
      title={__('Edit Alternate content source URL and subpaths')}
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
            onChange={(value) => {
              setAcsUrl(value);
            }}
          />
        </FormGroup>
        <FormGroup
          label={__('Subpaths')}
          type="string"
          fieldId="acs_subpaths"
        >
          <TextArea
            placeholder="test/repo1/, test/repo2/,"
            value={acsSubpath}
            onChange={(value) => {
              setAcsSubpath(value);
            }}
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
            isDisabled={saving || acsUrl.length === 0}
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
    id: PropTypes.number,
  }),
};

ACSEditURLPaths.defaultProps = {
  acsDetails: { base_url: '', subpaths: '', id: undefined },
};

export default ACSEditURLPaths;
