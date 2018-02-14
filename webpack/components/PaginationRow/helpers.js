// eslint-disable-next-line import/prefer-default-export
export const propsToState = (props) => {
  const { page, subtotal, ...rest } = props;
  const perPage = parseInt(props.perPage, 10);

  const amountOfPages = Math.ceil(subtotal / perPage);
  const itemsEnd = page * perPage > subtotal ? subtotal : page * perPage;
  let itemsStart = page * perPage;
  itemsStart -= perPage;
  itemsStart += 1;

  return {
    ...rest,
    amountOfPages,
    itemCount: subtotal,
    itemsStart,
    itemsEnd,
    perPage,
    page: parseInt(page, 10),
  };
};
