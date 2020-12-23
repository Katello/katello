const CONTENT_VIEWS_KEY = 'CONTENT_VIEWS';
export const CREATE_CONTENT_VIEW_KEY = 'CONTENT_VIEW_CREATE';
export const COPY_CONTENT_VIEW_KEY = 'CONTENT_VIEW_COPY';
export const UPDATE_CONTENT_VIEW = 'UPDATE_CONTENT_VIEW';
export const UPDATE_CONTENT_VIEW_SUCCESS = 'UPDATE_CONTENT_VIEW_SUCCESS';
export const UPDATE_CONTENT_VIEW_FAILURE = 'UPDATE_CONTENT_VIEW_FAILURE';
export const cvDetailsKey = cvId => `${CONTENT_VIEWS_KEY}_${cvId}`;
export const cvDetailsRepoKey = cvId => `${CONTENT_VIEWS_KEY}_REPOSITORIES_${cvId}`;
export const cvDetailsFilterKey = cvId => `${CONTENT_VIEWS_KEY}_FILTERS_${cvId}`;

// Repo added to content view status display and key
export const ADDED = 'Added';
export const NOT_ADDED = 'Not added';
export const ALL_STATUSES = 'All';

export const REPOSITORY_TYPES = 'REPOSITORY_TYPES';

export default CONTENT_VIEWS_KEY;
