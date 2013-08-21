object false

node(:total)    { @collection[:total] }
node(:subtotal) { @collection[:subtotal] }
node(:offset)   { params[:offset] }
node(:limit)    { params[:page_size] }
node(:search)   { params[:search] }
node(:sort) do 
  {
    :by => params[:sort_by],
    :order => params[:sort_order]
  }
end

node :results do
  partial("api/v2/%s/show" % controller_name, :object => @collection[:results])
end
