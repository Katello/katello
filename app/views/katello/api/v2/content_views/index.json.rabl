node(:total) { @collection[:total] }
node(:subtotal) { @collection[:subtotal] }
node(:offset) { params[:offset] }
node(:limit) { params[:page_size] }
node(:search) { params[:search] }
node(:sort) { {:by => params[:sort_by], :order => params[:sort_order]} }

node :results do
  partial("api/v2/content_views/show", :object => @collection[:results])
end
