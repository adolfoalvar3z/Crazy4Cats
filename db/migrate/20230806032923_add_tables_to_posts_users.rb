class AddTablesToPostsUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :posts_users, :like, :string
  end
end
