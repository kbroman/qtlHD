/**
 * Phenotype module
 *
 * PhenotypeMatrix holds phenotypes (cols) against individuals (rows)
 */

module qtl.core.phenotype;

import std.conv;
import std.stdio;
import std.string;
import std.array;
import std.typecons;
import std.algorithm;
import std.exception;
import std.path;
import std.file;

import qtl.core.primitives;
import qtl.core.phenotype;
import qtl.core.data.matrix;

immutable PHENOTYPE_NA = double.max; 

/**
 * AnyPhenotype is the most primitive representation of a phenotype. The type
 * can be any type T (normally a double, but can potentially be any Object).
 *
 * Note the primitive should be small as small as possible, there may be many
 * phenotypes! Therefore it is a struct.
 *
 * Note we do not use this facility other than outputting 'NA' when missing.
 */

struct AnyPhenotype(T) {
  T value;
  
  /// String representation of phenotype.
  const string toString(){
    if(to!double(value) != PHENOTYPE_NA){
      return to!string(value);
    }else{
      return "NA";
    }
  }
}

alias AnyPhenotype!double Phenotype ;

/**
 * PhenotypeMatrix holds phenotypes (cols) against individuals (rows)
 */

alias Phenotype[][] PhenotypeMatrix; // = new double[][][](n_ind,n_phe);

Phenotype set_phenotype(in string s) {
  // writeln(s);
  Phenotype p;
  if(s == "NA" || s == "-"){
    p.value = PHENOTYPE_NA;
  }else{
    if(s.countUntil(".") != -1){  // FIXME: this should only be for floats
      p.value = to!double(s);
    }else{
      p.value = to!double(s~".0");
    }
  }
  return p;
}

/**
 * Check whether a phenotype is missing
 */
bool isNA(Phenotype p) { 
  return(p.value == PHENOTYPE_NA);
}

// return boolean vector of size individuals indicating whether a 
// phenotype is missing (true)
bool[] individuals_missing_a_phenotype(Phenotype[][] phenotype_matrix)
{
  return filter_matrix_by_row_2bool!Phenotype(phenotype_matrix, (p) => isNA(p));
}

// omit individuals from phenotype data
Phenotype[][] omit_ind_from_phenotypes(Phenotype[][] pheno, bool[] to_omit)
{
  if(pheno.length != to_omit.length)
    throw new Exception("no. individuals in pheno (" ~ to!string(pheno.length) ~
                        ") doesn't match length of to_omit (" ~ to!string(to_omit.length) ~ ")");

  Phenotype[][] ret;

  foreach(i; 0..to_omit.length) {
    if(!to_omit[i])
      ret ~= pheno[i];
  }

  return ret;
}

// pull out one phenotype as a vector
Phenotype[] get_phenotype(in size_t index, in Phenotype[][] pheno_matrix)
{
  Phenotype[] ret;

  foreach(i, p; pheno_matrix)
    ret ~= p[index];

  return ret;
}

// pull out phenotype as a vector, selected by name
Phenotype[] get_phenotype(in string phename_to_get, in string[] phenames, in Phenotype[][] pheno_matrix)
{
  if(phenames.length != pheno_matrix[0].length)
    throw new Exception("no. phenotypes in phenames (" ~ to!string(phenames.length) ~ 
                        ") doesn't match no. columns in pheno_matrix (" ~ to!string(pheno_matrix[0].length) ~ ")");

  // find name in vector of names
  auto index = countUntil!("a == b")(phenames, phename_to_get);
  if(index < 0)
    throw new Exception("Phenotype not found.");

  return get_phenotype(index, pheno_matrix);
}

// batches of phenotypes with common missing data patterns
size_t[][] create_phenotype_batches(Phenotype[][] pheno)
{
  size_t[][] phenotype_batches = [ [0] ];

  size_t[] first_pattern = [];
  size_t[][] patterns;

  if(pheno[0].length == 1) return phenotype_batches;

  foreach(i; 0..pheno.length) {
    if(isNA(pheno[i][0]))
      first_pattern ~= i;
  }
  patterns ~= first_pattern;

  foreach(j; 1..pheno[0].length) {
    size_t[] this_pattern = [];

    foreach(i; 0..pheno.length) {
      if(isNA(pheno[i][j]))
        this_pattern ~= i;
    }

    bool found = false;
    foreach(i; 0..patterns.length) {
      if(this_pattern == patterns[i]) {
        found = true;
        phenotype_batches[i] ~= j;
      }
    }
    if(!found) {
      phenotype_batches ~= [j];
      patterns ~= this_pattern;
    }
  }

  return phenotype_batches;
}

// create string with pattern of missing values for a phenotype column
//    if individuals 2, 6, 8 are missing, the output will be "2|6|8"
string create_missing_phenotype_pattern(Phenotype[][] pheno, size_t pheno_column)
{
  string pattern;

  foreach(i; 0..pheno.length) {
    if(isNA(pheno[i][pheno_column])) {
      if(pattern == "") pattern = to!string(i);
      else pattern ~= "|" ~ to!string(i);
    }
  }

  return pattern;
}


// batches of phenotypes with common missing data patterns
size_t[][string] create_phenotype_batches_hash(Phenotype[][] pheno)
{
  auto pattern = create_missing_phenotype_pattern(pheno, 0);
  auto phenotype_batches = [pattern: [cast(size_t)0]];
  if(pheno[0].length == 1) return phenotype_batches;

  foreach(i; 1..pheno[0].length) {
    pattern = create_missing_phenotype_pattern(pheno, i);
    phenotype_batches[pattern] ~= i;
  }

  return phenotype_batches;
}
