Main Functions

	1. Takes .raw file and creates an mzXML or mzML file.
	2. Takes an mzML (or mzXML) file and creates a file in the format needed by search engines. Can run Hardklor on the mzXML file.
	3. Runs Mascot, X! Tandem, OMSSA, and Tide. Outputs pepXML files as their search results.
	4. Runs Percolator on the search results.
	5. Combines Percolator output into one.
	6. Allows for multiple search iterations.
	7. Determines minimum number of peptides and proteins


HOW TO RUN:

	KatamariDotei/bin/katamari_dotei_cl.rb rawFile databaseID [configFile]


CONTACT:

	If you have any questions at all, please email me at firstblackphantom@gmail.com


NOTE: This program relies on many other programs which are not included in this repository.



See documentation.txt and notes.txt for more information.
