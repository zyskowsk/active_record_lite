require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  def other_class
  end

  def other_table
  end
end

class BelongsToAssocParams < AssocParams
  def initialize(name, params)
  end

  def type
  end
end

class HasManyAssocParams < AssocParams
  def initialize(name, params, self_class)
  end

  def type
  end
end

module Associatable
  def assoc_params
  end

  def belongs_to(name, params = {})

    define_method(name) do 
      if params[:class_name].nil?
        other_class_name = name.to_s.camelize 
      else
        other_class_name = params[:class_name]
      end
      if params[:primary_key].nil?
        primary_key = :id
      else 
        primary_key = params[:primary_key]
      end
      if params[:foreign_key].nil?
        foreign_key = name.to_s + "_id" 
      else
        foreign_key = params[:foreign_key]
      end

      other_class = other_class_name.constantize
      other_table_name = other_class.table_name

      results = DBConnection.execute(<<-SQL, self.id)
        SELECT #{other_table_name}.* 
          FROM #{self.class.table_name}
          JOIN #{other_table_name}
            ON #{self.class.table_name}.#{foreign_key} = #{other_table_name}.#{primary_key}
         WHERE #{self.class.table_name}.id = ? 
      SQL

      other_class.parse_all(results)
    end

  end

  def has_many(name, params = {})

    define_method(name) do 
      if params[:class_name].nil?
        other_class_name = name.to_s.singularize.camelize
      else
        other_class_name = params[:class_name]
      end
      if params[:primary_key].nil?
        primary_key = :id
      else 
        primary_key = params[:primary_key]
      end
      if params[:foreign_key].nil?
        foreign_key = self.to_s.underscore + "_id"
      else
        foreign_key = params[:foreign_key]
      end

      other_class = other_class_name.constantize
      other_table_name = other_class.table_name

      results = DBConnection.execute(<<-SQL, self.id)
        SELECT #{other_table_name}.*
        FROM #{self.class.table_name}
        JOIN #{other_table_name}
        ON #{other_table_name}.#{foreign_key} = #{self.class.table_name}.#{primary_key}
        WHERE #{self.class.table_name}.id = ?
      SQL

      other_class.parse_all(results)
    end
  end

  def has_one_through(name, assoc1, assoc2)
  end
end
