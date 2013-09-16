class Object

	def self.my_attr_accessor(*attrs)
		attrs_get = attrs.map { |attr| [attr, "@#{attr}"] }
		attrs_set = attrs.map { |attr| ["#{attr}=", "@#{attr}"] }

		attrs_get.each do |attr_pair|
			define_method(attr_pair.first) do 
				self.instance_variable_get(attr_pair.last)
			end
		end

		attrs_set.each do |attr_pair|
			define_method(attr_pair.first) do |var|
				self.instance_variable_set(attr_pair.last, var)
			end
		end
	end
end

