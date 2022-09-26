import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import PropTypes from 'prop-types';
import useDeepCompareEffect from 'use-deep-compare-effect';
import { translate as __ } from 'foremanReact/common/I18n';
import { STATUS } from 'foremanReact/constants';
import { ActionGroup, Button, DualListSelector, Form, Modal, ModalVariant } from '@patternfly/react-core';
import { editACS, getACSDetails, getProducts } from '../../ACSActions';
import Loading from '../../../../components/Loading';
import { selectProducts, selectProductsStatus } from '../../ACSSelectors';

const ACSEditProducts = ({ onClose, acsId, acsDetails }) => {
  const { products } = acsDetails;
  const dispatch = useDispatch();
  const [saving, setSaving] = useState(false);
  const [
    acsProducts, setAcsProducts,
  ] = useState(products.map(product => product.name));
  const [productIds, setProductIds] = useState(products.map(product => product.id));
  const availableProducts = useSelector(selectProducts);
  const status = useSelector(selectProductsStatus);
  const { results } = availableProducts;
  const [availableOptions, setAvailableOptions] =
        useState((results?.map(product => product.name))?.filter(p => !acsProducts.includes(p)));
  const onListChange = (newAvailableOptions, newChosenOptions) => {
    setAvailableOptions(newAvailableOptions);
    setAcsProducts(newChosenOptions);
    setProductIds(results?.filter(product =>
      newChosenOptions.includes(product.name))?.map(p => p?.id));
  };

  useDeepCompareEffect(() => {
    if (results && status === STATUS.RESOLVED) {
      setAvailableOptions(results?.map(product =>
        product.name).filter(p => !acsProducts.includes(p)));
    }
  }, [results, status, setAvailableOptions, acsProducts]);

  useEffect(
    () => {
      dispatch(getProducts());
    },
    [dispatch],
  );

  const onSubmit = () => {
    setSaving(true);
    dispatch(editACS(
      acsId,
      { acsId, product_ids: productIds },
      () => {
        dispatch(getACSDetails(acsId));
        onClose();
      },
      () => {
        setSaving(false);
      },
    ));
  };

  if (status === STATUS.PENDING) {
    return <Loading />;
  }

  return (
    <Modal
      title={__('Edit products')}
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
        <DualListSelector
          isSearchable
          availableOptions={availableOptions}
          chosenOptions={acsProducts}
          addAll={onListChange}
          removeAll={onListChange}
          addSelected={onListChange}
          removeSelected={onListChange}
          id="selector"
        />
        <ActionGroup>
          <Button
            ouiaId="edit-acs-details-submit"
            aria-label="edit_acs_details"
            variant="primary"
            isDisabled={saving}
            isLoading={saving}
            type="submit"
          >
            {__('Edit ACS products')}
          </Button>
          <Button ouiaId="edit-acs-smart-proxies-cancel" variant="link" onClick={onClose}>
            {__('Cancel')}
          </Button>
        </ActionGroup>
      </Form>
    </Modal>
  );
};

ACSEditProducts.propTypes = {
  acsId: PropTypes.oneOfType([PropTypes.string, PropTypes.number]).isRequired,
  onClose: PropTypes.func.isRequired,
  acsDetails: PropTypes.shape({
    products: PropTypes.arrayOf(PropTypes.shape({})),
  }),
};

ACSEditProducts.defaultProps = {
  acsDetails: { products: [], id: undefined },
};

export default ACSEditProducts;
