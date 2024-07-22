object false

node(:total)    { @collection[:total] }
node(:subtotal) { @collection[:subtotal] }
node(:selectable) { @collection[:selectable] || @collection[:total] }
node(:page)     { @collection[:page] }
node(:per_page) { @collection[:per_page] }
node(:error)    { @collection[:error] }
node(:search)   { params[:search] }
node(:sort) do
  {
    :by => params[:sort_by],
    :order => params[:sort_order],
  }
end
