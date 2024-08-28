export const determineInitialAKSelection = (activationKeys, initialAKSelection) => {
  // If we've received the initialAKSelection from the URL, and it's a valid activation key, use it
  if (initialAKSelection &&
    (activationKeys ?? []).some(ak => ak.name === initialAKSelection)) {
    return { activationKeys: initialAKSelection.split(',') };
  }
  // If there's only one activation key, use it
  if (activationKeys?.length === 1) {
    return { activationKeys: [activationKeys[0].name] };
  }
  // Otherwise, don't select any activation keys
  return { activationKeys: [] };
};

export default determineInitialAKSelection;
