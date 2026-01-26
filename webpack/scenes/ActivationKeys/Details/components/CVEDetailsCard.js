import React, { useRef, useState } from 'react';
import { DropdownItem } from '@patternfly/react-core/deprecated';
import { translate as __ } from 'foremanReact/common/I18n';
import { useForemanContext, useForemanPermissions } from 'foremanReact/Root/Context/ForemanContext';
import { CVEDetailsBareCard } from '../../../../components/extensions/HostDetails/Cards/ContentViewDetailsCard/ContentViewDetailsCard';
import AssignAKCVModal from './AssignAKCVModal';

const getAKDetailsFromDOM = (node) => {
  try {
    return JSON.parse(node.dataset.akDetails);
  } catch (e) {
    return null;
  }
};
export const CVEDetailsCard = () => { // used as foreman-react-component, takes no props
  const akDetailsNode = useRef(document.getElementById('ak-cve-details')).current;
  const [akDetails, setAkDetails] = useState(getAKDetailsFromDOM(akDetailsNode));
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const userPermissions = useForemanPermissions();

  // Get setting from ForemanContext (registered in plugin.rb)
  const { metadata = {} } = useForemanContext();
  const allowMultipleContentViews = metadata?.katello?.allow_multiple_content_views ?? true;

  const observer = new MutationObserver((mutationsList) => {
    // eslint-disable-next-line no-restricted-syntax
    for (const mutation of mutationsList) {
      if (mutation.type === 'attributes' && mutation.attributeName.startsWith('data-')) {
        akDetailsNode.current = document.getElementById('ak-cve-details');
        setAkDetails(getAKDetailsFromDOM(akDetailsNode));
      }
    }
  });

  // Start observing akDetailsNode for attribute changes
  if (akDetailsNode) observer.observe(akDetailsNode, { attributes: true });

  if (!akDetails || !akDetails.content_view_environments) return null;

  const toggleKebab = () => setIsDropdownOpen(prev => !prev);
  const openModal = () => {
    setIsDropdownOpen(false);
    setIsModalOpen(true);
  };
  const closeModal = () => setIsModalOpen(false);

  // Check for edit_activation_keys permission from ForemanContext
  const hasEditPermission = userPermissions.has('edit_activation_keys');

  // Build permissions object for CVEDetailsBareCard
  // Convert Set to object format expected by the card
  const permissions = {
    view_lifecycle_environments: userPermissions.has('view_lifecycle_environments'),
    view_content_views: userPermissions.has('view_content_views'),
    promote_or_remove_content_views_to_environments:
      userPermissions.has('promote_or_remove_content_views_to_environments'),
  };

  // Create dropdown items if user has permission
  const dropdownItems = hasEditPermission ? [
    <DropdownItem
      aria-label="assign-content-view-environments"
      ouiaId="assign-content-view-environments"
      key="assign-content-view-environments"
      component="button"
      onClick={openModal}
    >
      {__('Assign content view environments')}
    </DropdownItem>,
  ] : undefined;

  // Transform existing assignments to the format expected by AssignAKCVModal
  // Map from snake_case (API data) to the format the modal expects
  // Include the label from the parent content_view_environment object
  const existingAssignments = akDetails.content_view_environments?.map(cve => ({
    contentView: cve.content_view,
    environment: cve.lifecycle_environment,
    label: cve.label, // Pre-computed label from backend
  })) || [];

  return (
    <>
      <CVEDetailsBareCard
        contentViewEnvironments={akDetails.content_view_environments}
        permissions={permissions}
        dropdownItems={dropdownItems}
        isDropdownOpen={isDropdownOpen}
        toggleKebab={toggleKebab}
        openModal={hasEditPermission ? openModal : null}
        allowMultipleContentViews={allowMultipleContentViews}
      />
      {hasEditPermission && akDetails.id && akDetails.organization_id && (
        <AssignAKCVModal
          isOpen={isModalOpen}
          closeModal={closeModal}
          orgId={akDetails.organization_id}
          akId={akDetails.id}
          existingAssignments={existingAssignments}
          allowMultipleContentViews={allowMultipleContentViews}
          key={`ak-cv-modal-${akDetails.id}`}
        />
      )}
    </>
  );
};

export default CVEDetailsCard;
