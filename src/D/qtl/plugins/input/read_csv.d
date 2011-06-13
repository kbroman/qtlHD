/**
 * Plugin for reading simple CSV files
 *
 *   rm read_csv ; dmd -unittest qtl/plugins/input/read_csv.d qtl/core/*.d ; time ./read_csv
 */

module qtl.plugins.input.read_csv;

import qtl.core.primitives;
import qtl.core.chromosome;
import qtl.core.phenotype;
import qtl.core.genotype;

import std.stdio;
import std.conv;
import std.string;
import std.path;

/** 
 * Read a simple CSV file containing marker names, chromosome nrs, position, 
 * phenotype and genotype - such as the listeria.csv file used in R/qtl.
 *
 * The file is parsed once on class instantiation. Elements can be queried.
 */

class ReadSimpleCSV {

  private File f;
  string phenotypename;
  Marker[] markers;
  Chromosome[string] chromosomes;
  Phenotype!double[] phenotypes;
  Genotype!BC[][] genotypes;      // FIXME: currently fixated for BC

  this(in string fn) {
    f = File(fn,"r");
    // read markers
    Marker[] ms;
    auto header = split(f.readln(),",");
    immutable size = header.length;
    ms.reserve(size);  // pre-allocate memory (just good practise)
    foreach (i, mname; header)
    {
       // writeln(mname);
       Marker m = { name:mname, id:i-1};
       ms ~= m;
    }
    phenotypename = ms[0].name;
    markers = ms[1..$];
    // read chromosome info
    auto cnames = split(f.readln(),",");
    if (cnames.length != size) throw new Exception("# Chromosomes out of range");
    foreach (i, cname; cnames)
    {
       if (i>0) {
         immutable cname2 = strip(cname);
         if (!(cname in chromosomes))
           chromosomes[cname2] = new Chromosome(cname2);
         markers[i-1].chromosome = chromosomes[cname2];
       }
    }
    // read position info
    auto positions = split(f.readln(),",");
    if (positions.length != size) throw new Exception("Positions out of range");
    foreach (i, pos; positions)
    {
       if (i>0) {
         immutable pos2 = strip(pos);
         markers[i-1].position = to!double(pos2);
       }
    }
    // read remaining data
    string buf;
    uint individual = 0;
    while (f.readln(buf)) {
      auto fields = split(buf,",");
      if (fields.length != size) throw new Exception("Field # out of range in ", buf);
      auto p = set_phenotype!double(fields[0]);
      phenotypes ~= p;
      // set genotype
      Genotype!BC[] gs;
      gs.reserve(size);  // pre-allocate memory (just good practise)
      foreach (field; fields[1..$]) {
        gs ~= set_genotype!BC(strip(field));
      }
      genotypes ~= gs;
      individual++;
    }
    f.close();
  }
}

unittest {
  writeln("Unit test " ~ __FILE__);
  alias std.path.join join;
  auto fn = dirname(__FILE__) ~ sep ~ join("..","..","..","..","..","test","data","input","listeria.csv");
  writeln("  - reading CSV " ~ fn);
  Marker m2 = { id:2, position:4.8};
  assert(m2.id == 2);
  auto markers = [ m2 ];
  auto data = new ReadSimpleCSV(fn);
  assert(data.markers.length == 133, to!string(data.markers.length));
  assert(data.phenotypename == "T264");
  assert(data.markers[0].name == "D10M44");
  assert(data.markers[0].id == 0);
  assert(data.markers[1].id == 1);
  // Check chromosomes
  assert(data.chromosomes.length == 20, to!string(data.chromosomes.length));
  assert(data.chromosomes["X"].id == 0);
  assert(data.chromosomes["7"].id == 7);
  assert(data.markers[2].position == 24.84773, "Marker position not matching");
  // Check phenotype
  assert(data.phenotypes[29].value == PHENOTYPE_NA, to!string(data.phenotypes[29].value));
  assert(data.phenotypes[30].value == 74.417);
  // Check genotype
  assert(data.genotypes[1][0].value == BC.NA);
  assert(data.genotypes[1][1].value == BC.B);

  // foreach(name; data.chromosomes.keys.sort) {
  // }
}

void main() { }