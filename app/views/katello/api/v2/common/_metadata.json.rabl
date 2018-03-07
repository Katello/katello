object false

node(:total)    { @collection[:total] }
node(:subtotal) { @collection[:subtotal] }
node(:page)     { @collection[:page] }
node(:per_page) { @collection[:per_page] }
node(:error)    { @collection[:error] }
node(:search)   { params[:search] }
node(:sort) do
  {
    :by => params[:sort_by],
    :order => params[:sort_order]
  }
end

if User.current && ::ColumnRegistry::Manager.resources.include?(resource_class.name)
  node(:table_configuration) do
    {
      :resource => resource_class.name,
      :columns => ::UserColumn.collate(resource_class.name,
                   User.current.user_columns.resource(resource_class.name).first.try(:columns))
    }
  end
end
