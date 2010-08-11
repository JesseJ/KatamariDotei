Search2mzIdentML.rb
Version: 1.0

Search2mzIdentML.rb will transform a search engine output file into an mzIdentML file. Currently only writes that which is required for mzIdentML.

Currently supports: pepXML

See spec.rb on how to run from code, or use command line: search2mzidentml_cl.rb inputFile database

Required input: Aside from the file to transform into mzIdentML, the FASTA database that was used in the peptide search engine is also required.

Important note: oboe.yaml provides a custom mapping between pepXML terms and mzIdentML temrs. Not all terms have a mapping, however, and some mappings are likely incomplete. In order to produce a proper mzIdentML file (One that would pass a validator), terms that don't have a mapping are not included in the output mzIdentML file. If you are aware of a proper mapping that isn't listed in oboe.yaml, feel free to add it in.