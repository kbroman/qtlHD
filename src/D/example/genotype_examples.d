// Example implementations

module example.genotype_examples;

import std.conv;
import std.algorithm;
import std.string;
import std.stdio;
import std.exception;
import qtl.core.genotype;

/**
 * RISIB, RISELF set using Genotype combinator
 * RISIB { NA, A, B };
 */

class RISIB {
  GenotypeSymbolMapper NA, A, B;
  this() {
    NA = new GenotypeSymbolMapper("NA");
    A  = new GenotypeSymbolMapper("A");
    A ~= new TrueGenotype(0,0);
    B  = new GenotypeSymbolMapper("B");
    B ~= new TrueGenotype(1,1);
    NA.add_encoding("-");
    A.add_encoding("AA");
    B.add_encoding("BB");
  }
}

class ObservedRISIB {
  RISIB crosstype;
  ObservedGenotypes symbols;
  this() {
    auto risib = new RISIB;
    symbols = new ObservedGenotypes();
    symbols ~= risib.NA;
    symbols ~= risib.A;
    symbols ~= risib.B;
    crosstype = risib;
  }
  /// Decode an input to an (observed) genotype
  auto decode(in string s) {
    return symbols.decode(s);
  }
  auto length() { return symbols.length; }
  override string toString() { return to!string(symbols); }
}

unittest {
  auto risib = new RISIB;
  auto symbols = new ObservedGenotypes();
  symbols ~= risib.NA;
  symbols ~= risib.A;
  symbols ~= risib.B;
  assert(symbols.decode("-") == risib.NA);
  assert(symbols.decode("A") == risib.A);
  assert(symbols.decode("AA") == risib.A);
  assert(symbols.decode("0,0") == risib.A);
  assert(symbols.decode("1,1") == risib.B);
}

unittest {
  // We can also roll our own types (to create a RISIB)
  auto NA = new GenotypeSymbolMapper("NA");
  auto A  = new GenotypeSymbolMapper("A");
  A ~= new TrueGenotype(0,0);
  auto B  = new GenotypeSymbolMapper("B");
  B ~= new TrueGenotype(1,1);
  assert(NA.name == "NA");
  assert(A.name == "A");
  auto symbols = new ObservedGenotypes();
  symbols ~= NA;
  symbols ~= A;
  symbols ~= B;
  GenotypeSymbolMapper risib[];  // create a set of observed genotypes
  // now find them by name
  NA.add_encoding("-"); // also support dash inputs for NA
  risib ~= symbols.decode("-");
  risib ~= symbols.decode("NA");
  risib ~= symbols.decode("A");
  risib ~= symbols.decode("B");
  // risib ~= symbols.decode("C"); // raises exception!
  assert(risib[0].isNA);
  assert(risib[1].isNA);
  assert(risib[2].name == "A");
  assert(to!string(risib[2]) == "[(0,0)]");
  assert(risib[3].name == "B");
  assert(to!string(risib[3]) == "[(1,1)]");
}

class RISELF {
  GenotypeSymbolMapper NA, A, B;
  this() {
    NA = new GenotypeSymbolMapper("NA");
    A  = new GenotypeSymbolMapper("A");
    A ~= new TrueGenotype(0,0);
    B  = new GenotypeSymbolMapper("B");
    B ~= new TrueGenotype(1,1);
    NA.add_encoding("-");
    A.add_encoding("AA");
    B.add_encoding("BB");
  }
}

class ObservedRISELF {
  RISELF crosstype;
  ObservedGenotypes symbols;
  this() {
    auto riself = new RISELF;
    symbols = new ObservedGenotypes();
    symbols ~= riself.NA;
    symbols ~= riself.A;
    symbols ~= riself.B;
    crosstype = riself;
  }
  /// Decode an input to an (observed) genotype
  auto decode(in string s) {
    return symbols.decode(s);
  }
  auto length() { return symbols.length; }
  override string toString() { return to!string(symbols); }
}

unittest {
  auto riself = new RISELF;
  auto symbols = new ObservedGenotypes();
  symbols ~= riself.NA;
  symbols ~= riself.A;
  symbols ~= riself.B;
  assert(symbols.decode("-") == riself.NA);
  assert(symbols.decode("A") == riself.A);
  assert(symbols.decode("AA") == riself.A);
  assert(symbols.decode("0,0") == riself.A);
  assert(symbols.decode("1,1") == riself.B);
}

unittest {
  // We can also roll our own types (to create a RISELF)
  auto NA = new GenotypeSymbolMapper("NA");
  auto A  = new GenotypeSymbolMapper("A");
  A ~= new TrueGenotype(0,0);
  auto B  = new GenotypeSymbolMapper("B");
  B ~= new TrueGenotype(1,1);
  assert(NA.name == "NA");
  assert(A.name == "A");
  auto symbols = new ObservedGenotypes();
  symbols ~= NA;
  symbols ~= A;
  symbols ~= B;
  GenotypeSymbolMapper riself[];  // create a set of observed genotypes
  // now find them by name
  NA.add_encoding("-"); // also support dash inputs for NA
  riself ~= symbols.decode("-");
  riself ~= symbols.decode("NA");
  riself ~= symbols.decode("A");
  riself ~= symbols.decode("B");
  // riself ~= symbols.decode("C"); // raises exception!
  assert(riself[0].isNA);
  assert(riself[1].isNA);
  assert(riself[2].name == "A");
  assert(to!string(riself[2]) == "[(0,0)]");
  assert(riself[3].name == "B");
  assert(to!string(riself[3]) == "[(1,1)]");
}


/**
 * BC implementation
 * BC  { NA, A, H };
 */

class BC {
  GenotypeSymbolMapper NA, A, H;
  this() {
    NA = new GenotypeSymbolMapper("NA");
    A  = new GenotypeSymbolMapper("A");
    A ~= new TrueGenotype(0,0);
    H  = new GenotypeSymbolMapper("H");
    H ~= new TrueGenotype(1,0);
    NA.add_encoding("-");
  }
}

class ObservedBC {
  BC crosstype;
  ObservedGenotypes symbols;
  this() {
    auto bc = new BC;
    symbols = new ObservedGenotypes();
    symbols ~= bc.NA;
    symbols ~= bc.A;
    symbols ~= bc.H;
    crosstype = bc;
  }
  /// Decode an input to an (observed) genotype
  auto decode(in string s) { return symbols.decode(s); }
  auto length() { return symbols.length; }
  override string toString() { return to!string(symbols); }

}

unittest {
  auto bc = new BC;
  auto symbols = new ObservedGenotypes();
  symbols ~= bc.NA;
  symbols ~= bc.A;
  symbols ~= bc.H;
  assert(symbols.decode("-") == bc.NA);
  assert(symbols.decode("A") == bc.A);
  assert(symbols.decode("H") == bc.H);
}

/**
 * F2 set using Genotype combinator
 * F2  { NA, A, H, B, HorB, HorA };
 */

class F2 {
  GenotypeSymbolMapper NA, A, B, H, HorB, HorA;
  alias HorB C;
  alias HorA D;
  this() {
    auto aa = new TrueGenotype(0,0);
    auto bb = new TrueGenotype(1,1);
    auto ab = new TrueGenotype(0,1);
    auto ba = new TrueGenotype(1,0);
    NA = new GenotypeSymbolMapper("NA");
    A  = new GenotypeSymbolMapper("A");
    A ~= aa;
    B  = new GenotypeSymbolMapper("B");
    B ~= bb;
    H  = new GenotypeSymbolMapper("H");
    H ~= ab;
    H ~= ba;
    HorB  = new GenotypeSymbolMapper("HorB","C");
    HorB ~= ab;
    HorB ~= bb;
    HorA  = new GenotypeSymbolMapper("HorA","D");
    HorA ~= ab;
    HorA ~= aa;
    NA.add_encoding("-");
    A.add_encoding("AA");
    B.add_encoding("BB");
    H.add_encoding("AB");
    H.add_encoding("BA");
  }
}

class ObservedF2 {
  F2 crosstype;
  ObservedGenotypes symbols;
  this() {
    auto f2 = new F2;
    symbols = new ObservedGenotypes();
    symbols ~= f2.NA;
    symbols ~= f2.A;
    symbols ~= f2.B;
    symbols ~= f2.H;
    symbols ~= f2.HorB;
    symbols ~= f2.HorA;
    crosstype = f2;
  }
  /// Decode an input to an (observed) genotype
  auto decode(in string s) { return symbols.decode(s); }
  auto length() { return symbols.length; }
  override string toString() { return to!string(symbols); }
}

unittest {
  auto f2 = new F2;
  auto symbols = new ObservedGenotypes();
  symbols ~= f2.NA;
  symbols ~= f2.A;
  symbols ~= f2.B;
  symbols ~= f2.H;
  symbols ~= f2.HorB;
  symbols ~= f2.HorA;
  assert(f2.HorB == f2.C);
  assert(symbols.decode("-") == f2.NA);
  assert(symbols.decode("A") == f2.A);
  assert(symbols.decode("B") == f2.B);
  // assert(symbols.decode("H") == f2.H);
  // assert(symbols.decode("C") == f2.HorB);
  // writeln(f2.HorA.encoding);
  // writeln(symbols);
  assert(symbols.decode("D")   == f2.HorA);
  assert(symbols.decode("NA")  == f2.NA);
  assert(symbols.decode("")    == f2.NA);
  assert(symbols.decode("1,1") == f2.B);
  assert(symbols.decode("0,1") == f2.H);
  assert(symbols.decode("1,0") == f2.H);
}

unittest {
  // the quick way is to used the predefined ObservedF2
  auto symbols = new ObservedF2;
  auto f2 = symbols.crosstype;
  assert(symbols.decode("-") == f2.NA);
  assert(symbols.decode("A") == f2.A);
  assert(symbols.decode("B") == f2.B);
}


/**
 * Phase known/directional F2 with ambiguous scoring:
 * F2  { NA, A, B, AB, BA, HorB, HorA };
 */

unittest {
  auto NA = new GenotypeSymbolMapper("NA","-");
  auto A = new GenotypeSymbolMapper("A");
  A ~= new TrueGenotype(0,0);
  auto B  = new GenotypeSymbolMapper("B");
  B ~= new TrueGenotype(1,1);
  auto AB  = new GenotypeSymbolMapper("AB");
  AB ~= new TrueGenotype(0,1);
  auto BA  = new GenotypeSymbolMapper("BA");
  BA ~= new TrueGenotype(1,0);
  auto HorB  = new GenotypeSymbolMapper("HorB","C");
  HorB ~= B;
  HorB ~= AB;
  HorB ~= BA;
  auto HorA  = new GenotypeSymbolMapper("HorA","D");
  HorA ~= A;
  HorA ~= AB;
  HorA ~= BA;
  auto symbols = new ObservedGenotypes();
  symbols ~= NA;
  symbols ~= A;
  symbols ~= B;
  symbols ~= AB;
  symbols ~= BA;
  symbols ~= HorA;
  symbols ~= HorB;
  assert(HorA.name == "HorA");
  assert(to!string(HorA) == "[(0,0), (0,1), (1,0)]");

  auto gA = new TrueGenotype(0,0);
  auto gB = new TrueGenotype(1,1);
  auto gAB = new TrueGenotype(0,1);
  auto gBA = new TrueGenotype(1,0);

  assert(HorA.match(gA));
  assert(HorA.match(gBA));
  assert(HorA.match(gAB));
  assert(!HorA.match(gB));

  assert(!HorB.match(gA));
  assert(HorB.match(gBA));
  assert(HorB.match(gAB));
  assert(HorB.match(gB));

  // Here a quick test to see if canFind needs sorted input
  int as[] = [ 6,5,4,3,4,7 ];
  assert(canFind(as,4));
  assert(canFind(as,7));
}

/**
 * Flex implementation
 */

class Flex {
  GenotypeSymbolMapper NA;
  this() {
    NA = new GenotypeSymbolMapper("NA");
    NA.add_encoding("-");
  }
}

class ObservedFlex {
  Flex crosstype;
  ObservedGenotypes symbols;
  this() {
    auto flex = new Flex;
    symbols = new ObservedGenotypes();
    symbols ~= flex.NA;
    crosstype = flex;
  }
  /// Decode an input to an (observed) genotype
  auto decode(in string s) { return symbols.decode(s); }
  auto length() { return symbols.length; }
  override string toString() { return to!string(symbols); }

}


/**
 * Takes a list of genotype encoding string lines, e.g.
 *
 * ["GENOTYPE NA,- as None","GENOTYPE A as 0,0","GENOTYPE B,BB as 1,1"]
 *
 * and turns it into an ObservedGenotypes object
 */

class EncodedCross {
  GenotypeSymbolMapper combinator[string];
  this(string list[]) {
    // parse list
    foreach(line ; list) {
       // writeln(line);
       if (line.strip() == "") continue;
       add(line);
    }
  }

  EncodedGenotype add(string line) {
    auto line_item = new EncodedGenotype(line);
    auto n = line_item.names[0];
    if (n in combinator)
      throw new Exception("Duplicate " ~ line);

    combinator[n] = new GenotypeSymbolMapper(n);
    foreach (tt ; line_item.genotypes) {
       combinator[n] ~= tt;
    }
    foreach (n_alias ; line_item.names[1..$]) {
       combinator[n].add_encoding(n_alias);
    }
    // writeln("--->",combinator[n].encoding,combinator[n]);
    return line_item;
  }

}

unittest {
  auto encoded = "
GENOTYPE NA,- as None
GENOTYPE A as 0,0
GENOTYPE B,BB as 1,1
GENOTYPE C,CC as 2,2         # alias
GENOTYPE AB as 1,0           # phase known/directional
GENOTYPE BA as 0,1           # phase known/directional
GENOTYPE AC,CA as 0,2 2,0    # phase unknown/not directional
GENOTYPE CA,F as 2,0 0,2     # alias
GENOTYPE AorB as 0,0 1,1
GENOTYPE AorABorAC as 0,0 1,0 0,1 0,2 2,0";

  auto cross = new EncodedCross(split(encoded,"\n"));
  auto symbols = new ObservedGenotypes();
  // add genotypes to symbols
  foreach (legaltype; cross.combinator) {
    writeln(legaltype);
    symbols ~= legaltype;
  }
  assert(symbols.decode("NA") == cross.combinator["NA"]);
  assert(symbols.decode("-") == cross.combinator["NA"]);
  assert(symbols.decode("A") == cross.combinator["A"]);
  assert(symbols.decode("B") == cross.combinator["B"]);
  assert(symbols.decode("CC") == cross.combinator["C"]);
  // assert(symbols.decode("BB") == cross.combinator["BB"]); <- error
  assert(symbols.decode("BB") == cross.combinator["B"]); //  <- OK
  assert(symbols.decode("AB") == cross.combinator["AB"]);
  assert(symbols.decode("BA") == cross.combinator["BA"]);
  assert(symbols.decode("AorB") == cross.combinator["AorB"]);
  assert(symbols.decode("0,0") == cross.combinator["A"]);
  assert(symbols.decode("1,1") == cross.combinator["B"]);
  assert(symbols.decode("1,0") == cross.combinator["AB"]);
  // writeln("Cross symbols: ",symbols);
  // the following won't work, because symbols are not added serially to the
  // combinator (see above writeln)
  // assert(symbols.decode("0,1") == cross.combinator["BA"], to!string(symbols.decode("0,1")) ~ " expected " ~ to!string(cross.combinator["BA"]));
  // assert(symbols.decode("0,0|1,1") == cross.combinator["AorB"]);
  // writeln(cross["AorB"].encoding);
  // writeln(symbols);
  // Test for duplicates
  encoded = "
GENOTYPE A as 0,0
GENOTYPE A as 1,1
";
  assertThrown(new EncodedCross(split(encoded,"\n")));
  // This is legal, though probably undefined
  encoded = "
GENOTYPE A as 0,0
GENOTYPE AA as 0,0
";
  assertNotThrown(new EncodedCross(split(encoded,"\n")));
}

// CrossType : allowable cross types we will handle
enum CrossType { BC, F2, RISELF, RISIB };
