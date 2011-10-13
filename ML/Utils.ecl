﻿IMPORT * FROM $;
// Utilities for the implementation of ML (rather than the interface to it)
EXPORT Utils := MODULE

// Given a file which is sorted by INFIELD (and possibly other values), add sequence numbers within the range of each infield
// Slighly elaborate code is to avoid having to partition the data to one value of infield per node
EXPORT mac_SequenceInField(infile,infield,seq,outfile) := MACRO

#uniquename(add_rank)
TYPEOF(infile) %add_rank%(infile le,UNSIGNED c) := TRANSFORM
  SELF.seq := c;
	SELF := le;
  END;
	
#uniquename(P)
%P% := PROJECT(infile,%add_rank%(LEFT,COUNTER));

#uniquename(RS)
%RS% := RECORD
  __Seq := MIN(GROUP,%P%.seq);
  %P%.infield;
  END;

#uniquename(Splits)
%Splits% := TABLE(%P%,%RS%,infield,FEW);

#uniquename(to_1)
TYPEOF(infile) %to_1%(%P% le,%Splits% ri) := TRANSFORM
	SELF.Seq := 1+le.Seq - ri.__Seq;
	SELF := le;
  END;
	
outfile := JOIN(%P%,%Splits%,LEFT.InField=RIGHT.InField,%to_1%(LEFT,RIGHT),LOOKUP);

ENDMACRO;

// Shift the column-numbers of a file of discretefields so that the left-most column is now new_lowval
// Can move colums left or right (or not at all)
EXPORT RebaseDiscrete(DATASET(Types.DiscreteField) cl,Types.t_FieldNumber new_lowval) := FUNCTION
  CurrentBase := MIN(cl,number);
	INTEGER Delta := new_lowval-CurrentBase;
	RETURN PROJECT(cl,TRANSFORM(Types.DiscreteField,SELF.number := LEFT.number+Delta,SELF := LEFT));
  END;
	
END;