require_relative './db_connection'

module Searchable
  def where(params)
  	where_line = params.keys.map do |attr|
  		"#{attr} = ?"
  	end.join("AND ")

  	values = params.values

  	results = DBConnection.execute(<<-SQL, *values)
  		SELECT * 
    		FROM #{table_name}
    	 WHERE #{where_line}
  	SQL

  	self.parse_all(results)
  end
end