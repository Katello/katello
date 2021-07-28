class CreateFunctionDebVersionCmp < ActiveRecord::Migration[6.0]
  def up
    create_function :deb_version_cmp
  end

  def down
    drop_function :deb_version_cmp
    drop_function :deb_version_cmp_al
    drop_function :deb_version_cmp_num
    drop_function :deb_version_cmp_string
  end
end
