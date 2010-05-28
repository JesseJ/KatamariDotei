
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

#<SpectrumIdentificationResult id="SIR_1" spectrumID="index=160" SpectraData_ref="SD_1">
#	<SpectrumIdentificationItem id="SII_1_1" calculatedMassToCharge="474.7267125" chargeState="2" experimentalMassToCharge="475.229095" Peptide_ref="peptide_1_1" rank="1" passThreshold="false">
#		<PeptideEvidence id="PE_1_1_Q2VPJ6_0_437_443" start="437" end="443" pre="K" post="N" missedCleavages="0" isDecoy="false" DBSequence_Ref="DBSeq_1_Q2VPJ6"/>
#		<cvParam accession="MS:1001171" name="mascot:score" cvRef="PSI-MS" value="29.31"/>
#		<cvParam accession="MS:1001172" name="mascot:expectation value" cvRef="PSI-MS" value="0.691478046136842"/>
#		<cvParam accession="MS:1001363" name="peptide unique to one protein" cvRef="PSI-MS"/>
#	</SpectrumIdentificationItem>