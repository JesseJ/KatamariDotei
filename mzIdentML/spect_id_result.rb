
Ident = Struct.new(:id, :mass, :charge, :experi, :pep, :rank, :pass)
PepEvidence = Struct.new(:id, :start, :end, :pre, :post, :missedCleavages, :isDecoy, :DBSequence_Ref)

class SpectIdResult
	def initialize(index, items)
		@index = index
		@items = items
	end
	
	def index
		@index
	end
	
	def items
		@items
	end
end

class SpectIdItem
	def initialize(ident)
		@ident = ident
		@pepEv = nil
		@vals = []
	end
	
	def ident
		@ident
	end
	
	def pepEvidence
		@pepEv
	end
	
	def pepEvidence=(pepEv)
		@pepEv = pepEv
	end
	
	def vals
		@vals
	end
	
	def vals=(vals)
		@vals = vals
	end
end
