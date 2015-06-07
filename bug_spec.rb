require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'dbfile.sqlite3'
)

class Car < ActiveRecord::Base
  has_many :wheels, -> { select(:colour, :id) }
end

class Wheel < ActiveRecord::Base
  belongs_to :car
end

describe ActiveRecord::Associations::CollectionAssociation do
  before :all do
    m = ActiveRecord::Migration.new
    m.create_table :cars do |t|
      t.timestamps null: true
    end

    m.create_table :wheels do |t|
      t.string :colour
      t.integer :car_id
      t.timestamps null: true
    end
  end

  after :all do
    m = ActiveRecord::Migration.new
    m.drop_table :cars
    m.drop_table :wheels
  end

  # Bug reason:
  # Method #count_records in ActiveRecord::Associations::HasManyAssociation
  # doesn't call count(:all) but simply count().
  # ActiveRecord::Associations::CollectionAssociation#size
  # relies on #count_records.
  describe "#size" do
    it "doesn't raise error on unloaded relation collection" do
      car = Car.create

      expect {
        car.wheels.size
      }.not_to raise_error
    end
  end
end
