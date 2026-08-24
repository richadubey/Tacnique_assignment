class CreateEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :events do |t|
      t.string :billetto_id, null: false
      t.string :title, null: false
      t.text :description
      t.string :url
      t.string :image_url

      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false

      t.boolean :available, null: false, default: true

      t.integer :price_cents
      t.string :currency

      t.string :category
      t.string :subcategory
      t.string :event_type

      t.integer :organiser_id
      t.string :organiser_name

      t.string :location_name
      t.string :address
      t.string :city
      t.string :postal_code
      t.string :country
      t.string :country_code

      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6

      t.timestamps
    end

    add_index :events, :billetto_id, unique: true
    add_index :events, :starts_at
    add_index :events, :city
    add_index :events, :category
  end
end