require_relative './db_connection'

module Searchable
  def where(params)
  	where_line = params.keys.map do |attr|
  		"#{attr} = ?"
  	end.join("AND ")

  	values = params.values

  	DBConnection.execute(<<-SQL, *values)
  		SELECT * 
    		FROM #{table_name}
    	 WHERE #{where_line}
  	SQL
  end
end