/**
 * Cross module
 **/

module qtl.core.cross;

// things I think I really need
import qtl.core.primitives;
import qtl.core.genotype;
import std.stdio;
import std.math;

// things for the unit tests 
import qtl.plugins.input.read_csv;
import std.path;

class Cross { }


// class to contain genotype data with hmm-related functions
class F2Cross : Cross {
  Genotype!F2[][] genotypes;
  immutable F2[] possible_true_genotypes = [F2.A, F2.H, F2.B];

  this(Genotype!F2[][] genotypes) {
    this.genotypes = genotypes;
  }

  // marginal genotype probability
  double init(Genotype!F2 true_gen)
  {
    switch(true_gen.value) {
    case F2.H:
      return(-LN2);
    case F2.A: case F2.B: 
      return(-2.0*LN2);
    }
    return(0.0); /* shouldn't get here */
  }

  // emission probability (marker genotype "penetrance")
  double emit(Genotype!F2 obs_gen, Genotype!F2 true_gen, double error_prob) 
  {
    switch(obs_gen.value) {
    case F2.NA: return(0.0);
    case F2.A: case F2.H: case F2.B:
      if(obs_gen.value == true_gen.value) {
	return(log(1.0-error_prob));
      } else {
	return(log(error_prob)-LN2);
      }
    case F2.C:
      if(true_gen.value != F2.A) {
	return(log(1.0-error_prob/2.0));
      } else {
	return(log(error_prob)-LN2);
      }
    case F2.D:
      if(true_gen.value != F2.B) {
	return(log(1.0-error_prob/2.0));
      } else {
	return(log(error_prob)-LN2);
      }
    }
    return(0.0); /* shouldn't get here */
  }

  // transition probabilities 
  double step(Genotype!F2 true_gen_left, Genotype!F2 true_gen_right, 
	      double rec_frac) {
    switch(true_gen_left.value) {
    case F2.A:
      switch(true_gen_right.value) {
      case F2.A: return(2.0*log(1.0-rec_frac));
      case F2.H: return(LN2 + log(1.0-rec_frac) + log(rec_frac));
      case F2.B: return(2.0*log(rec_frac));
      }
    case F2.H:
      switch(true_gen_right.value) {
      case F2.A: case F2.B: return(log(rec_frac) + log(1.0-rec_frac));
      case F2.H: return(log((1.0-rec_frac)^^2 + rec_frac^^2));
      }
    case F2.B:
      switch(true_gen_right.value) {
      case F2.A: return(2.0*log(rec_frac));
      case F2.H: return(LN2 + log(1.0-rec_frac) + log(rec_frac));
      case F2.B: return(2.0*log(1.0-rec_frac));
      }
    }
    return(log(-1.0)); /* shouldn't get here */
  }
}

unittest {
  writeln("Unit test " ~ __FILE__);
  alias std.path.join join;
  auto fn = dirname(__FILE__) ~ sep ~ join("..","..","..","..","test","data","input","listeria.csv");
  writeln("  - read CSV " ~ fn);
  auto data = new ReadSimpleCSV(fn);
  auto cross = new F2Cross(data.genotypes);
}

  
