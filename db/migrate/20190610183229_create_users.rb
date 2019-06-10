class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name
      t.string :file1_key
      t.string :file2_key
      t.string :file3_key

      t.timestamps
    end
  end
end
