require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'

class SQLObject < MassObject
  extend Searchable
  extend Associatable

  def self.set_table_name(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name.underscore
  end

  def self.all
    DBConnection.execute <<-SQL
      SELECT * 
        FROM #{table_name}
    SQL
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id)
      SELECT * 
        FROM #{table_name}
       WHERE id = ?
    SQL

    self.parse_all(results).first
  end

  def create
    attrs_string = "(#{attribute_values.join(", ")})"
    question_string = "(#{(['?'] * num_attributes).join(", ")})"

    DBConnection.execute(<<-SQL, *values)
      INSERT INTO #{self.class.table_name} #{attrs_string}
           VALUES #{question_string}
    SQL

    self.id = self.class.all.count
  end

  def update
    set_line = attribute_values.map do |attr| 
      "#{attr} = ?"
    end.join(", ")

    DBConnection.execute(<<-SQL, *values, self.id)
      UPDATE #{self.class.table_name}
         SET #{set_line}
       WHERE id = ?
    SQL
  end

  def save
    self.create if self.id.nil?
    self.update if not self.id.nil?
  end

  private

    def attribute_values
      self.class.attributes
    end

    def num_attributes
      attribute_values.count
    end

    def values
      attribute_values.map{ |attr| self.send(attr) }
    end
end
