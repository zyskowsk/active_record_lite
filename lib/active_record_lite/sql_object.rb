require_relative './associatable'
require_relative './db_connection'
require_relative './mass_object'
require_relative './searchable'
require 'active_support/inflector'

class SQLObject < MassObject
  def self.set_table_name(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name.underscore
  end

  def self.all
    DBConnection.execute <<-SQL
      SELECT * 
        FROM "#{table_name}"
    SQL
  end

  def self.find(id)
    DBConnection.execute(<<-SQL, id).first
      SELECT * 
      FROM "#{table_name}"
      WHERE id = ?
    SQL
  end

  def create
  end

  def update
  end

  def save
  end

  def attribute_values
  end
end
