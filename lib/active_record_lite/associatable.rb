require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  def other_class
    get_class_name.constantize
  end

  def other_table
    other_class.table_name
  end
end

class BelongsToAssocParams < AssocParams
  def initialize(name, params)
    @name, @params = name, params
  end

  def primary_key
    return :id if @params[:primary_key].nil?
    @params[:primary_key]  
  end

  def foreign_key
    return @name.to_s + "_id" if @params[:foreign_key].nil?
    @params[:foreign_key]
  end

  def type
  end

  def get_class_name
    return @name.to_s.camelize if @params[:class_name].nil?
    @params[:class_name]
  end
end

class HasManyAssocParams < AssocParams
  def initialize(name, params, self_class)
    @name, @params, @self_class = name, params, self_class
  end

  def foreign_key
    return self_class.to_s.underscore + "_id" if @params[:foreign_key].nil?
    @params[:foreign_key]
  end

  def primary_key
    return :id if @params[:primary_key].nil?
    @params[:primary_key]
  end
      
  def type
  end

  def get_class_name
    return @name.to_s.singularize.camelize if @params[:class_name].nil?
    @params[:class_name]
  end
end

module Associatable
  def assoc_params
  end

  def belongs_to(name, params = {})
    aps = BelongsToAssocParams.new(name, params)

    define_method(name) do 
      results = DBConnection.execute(<<-SQL, self.send(aps.foreign_key))
        SELECT * 
          FROM #{aps.other_table}
         WHERE #{aps.other_table}.#{aps.primary_key} = ? 
      SQL

      aps.other_class.parse_all(results)
    end

  end

  def has_many(name, params = {})
    aps = HasManyAssocParams.new(name, params, self)

    define_method(name) do 
      results = DBConnection.execute(<<-SQL, self.send(aps.primary_key))
        SELECT *
        FROM #{aps.other_table}
        WHERE #{aps.other_table}.#{aps.foreign_key} = ?
      SQL

      aps.other_class.parse_all(results)
    end
  end

  def has_one_through(name, assoc1, assoc2)
  end
end
