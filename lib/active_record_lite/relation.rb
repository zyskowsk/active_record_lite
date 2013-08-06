class Relation

	sql_bits = {:select => [],
							:from => [],
							:where => [],}

	def initialize(sql_bits, cache)
		@constraints = contraints
		@cache = cache
	end

end