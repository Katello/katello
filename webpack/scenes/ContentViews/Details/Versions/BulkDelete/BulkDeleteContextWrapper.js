import React, {
  createContext,
  useState,
} from 'react';

import { PropTypes } from 'prop-types';

export const BulkDeleteContext = createContext({});

const BulkDeleteContextWrapper = ({
  children, versions, onClose,
}) => {
  const [selectedEnvForAK, setSelectedEnvForAK] = useState([]);
  const [selectedCVForAK, setSelectedCVForAK] = useState(null);
  const [selectedEnvForHosts, setSelectedEnvForHosts] = useState([]);
  const [selectedCVForHosts, setSelectedCVForHosts] = useState(null);
  const [currentStep, setCurrentStep] = useState(1);

  return (
    <BulkDeleteContext.Provider value={{
      onClose,
      versions,
      selectedEnvForAK,
      setSelectedEnvForAK,
      selectedCVForAK,
      setSelectedCVForAK,
      selectedEnvForHosts,
      setSelectedEnvForHosts,
      selectedCVForHosts,
      setSelectedCVForHosts,
      currentStep,
      setCurrentStep,
    }}
    >
      {children}
    </BulkDeleteContext.Provider>);
};

BulkDeleteContextWrapper.propTypes = {
  versions: PropTypes.arrayOf(PropTypes.shape({})).isRequired,
  onClose: PropTypes.func.isRequired,
  children: PropTypes.element.isRequired,
};

export default BulkDeleteContextWrapper;
