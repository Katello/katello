import React, { useContext, useState } from 'react';
import { useSelector } from 'react-redux';
import { translate as __ } from 'foremanReact/common/I18n';
import { DualListSelector } from '@patternfly/react-core';
import ACSCreateContext from '../ACSCreateContext';
import WizardHeader from '../../../ContentViews/components/WizardHeader';
import { selectProducts } from '../../ACSSelectors';

const ACSProducts = () => {
  const {
    setProductIds, productNames, setProductNames,
  } = useContext(ACSCreateContext);
  const availableProducts = useSelector(selectProducts);
  const { results } = availableProducts;
  const [availableOptions, setAvailableOptions] = useState(results?.map(product =>
    product.name)?.filter(pName => !productNames.includes(pName)));
  const onListChange = (newAvailableOptions, newChosenOptions) => {
    setAvailableOptions(newAvailableOptions);
    setProductNames(newChosenOptions);
    setProductIds(results?.filter(product =>
      newChosenOptions.includes(product.name))?.map(p => p?.id));
  };

  return (
    <>
      <WizardHeader
        title={__('Select products')}
        description={__('Select products to associate to this source.')}
      />
      <DualListSelector
        isSearchable
        availableOptions={availableOptions}
        chosenOptions={productNames}
        addAll={onListChange}
        removeAll={onListChange}
        addSelected={onListChange}
        removeSelected={onListChange}
        id="product_selector"
      />
    </>
  );
};

export default ACSProducts;
