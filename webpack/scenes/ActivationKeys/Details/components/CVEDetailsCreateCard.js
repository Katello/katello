import React, { useRef, useState } from 'react';
import { DropdownItem } from '@patternfly/react-core/deprecated';
import { translate as __ } from 'foremanReact/common/I18n';
import { useForemanContext, useForemanPermissions } from 'foremanReact/Root/Context/ForemanContext';
import { CVEDetailsBareCard } from '../../../../components/extensions/HostDetails/Cards/ContentViewDetailsCard/ContentViewDetailsCard';
import CreateAKCVModal from './CreateAKCVModal';

export const CVEDetailsCreateCard = () => {
  const dataNode = useRef(document.getElementById('ak-create-cve-data')).current;
  const [assignments, setAssignments] = useState([]);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const userPermissions = useForemanPermissions();

  // Get setting from ForemanContext (registered in plugin.rb)
  const { metadata = {} } = useForemanContext();
  // Ensure we get a boolean value (lambda might return the function itself)
  const metadataValue = metadata?.katello?.allow_multiple_content_views;
  const allowMultipleContentViews = typeof metadataValue === 'function' ? metadataValue() : (metadataValue ?? true);

  // Read orgId from DOM
  const orgId = dataNode ? parseInt(dataNode.dataset.orgId, 10) : null;

  const toggleKebab = () => setIsDropdownOpen(prev => !prev);
  const openModal = () => {
    setIsDropdownOpen(false);
    setIsModalOpen(true);
  };
  const closeModal = () => setIsModalOpen(false);

  // Notify AngularJS when assignments change
  const handleAssignmentsChange = (newAssignments) => {
    setAssignments(newAssignments);

    // Call AngularJS scope method
    const angularElement = window.angular?.element(document.getElementById('ak-create-cve-data'));
    if (angularElement) {
      const scope = angularElement.scope();
      if (scope?.updateContentViewEnvironments) {
        scope.$apply(() => {
          scope.updateContentViewEnvironments(newAssignments);
        });
      }
    }
  };

  // Transform assignments to format for display in CVEDetailsBareCard
  const displayAssignments = assignments
    .filter(a => a.contentView && a.environment)
    .map(a => ({
      content_view: a.contentView,
      lifecycle_environment: a.environment,
    }));

  // Build permissions object for CVEDetailsBareCard
  const permissions = {
    view_lifecycle_environments: userPermissions.has('view_lifecycle_environments'),
    view_content_views: userPermissions.has('view_content_views'),
    promote_or_remove_content_views_to_environments:
      userPermissions.has('promote_or_remove_content_views_to_environments'),
  };

  // Check if user has permission to assign content view environments
  const canAssignCVEs = userPermissions.has('create_activation_keys');

  // Create dropdown items for kebab menu if user has permission
  const dropdownItems = canAssignCVEs ? [
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

  // Don't render if no orgId (organization not selected yet)
  if (!orgId) return null;

  return (
    <>
      <CVEDetailsBareCard
        contentViewEnvironments={displayAssignments}
        permissions={permissions}
        dropdownItems={dropdownItems}
        isDropdownOpen={isDropdownOpen}
        toggleKebab={toggleKebab}
        openModal={canAssignCVEs ? openModal : null}
      />
      {canAssignCVEs && (
        <CreateAKCVModal
          isOpen={isModalOpen}
          closeModal={closeModal}
          orgId={orgId}
          existingAssignments={assignments}
          onAssignmentsChange={handleAssignmentsChange}
          allowMultipleContentViews={allowMultipleContentViews}
        />
      )}
    </>
  );
};

export default CVEDetailsCreateCard;
