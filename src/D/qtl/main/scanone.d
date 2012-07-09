// Entry point for command line (CLI) scanone tool

import std.getopt;
import std.stdio;
import std.conv;
import std.exception;
import std.file;
import std.string;
import std.path;
import std.algorithm;
import std.math;

import qtl.plugins.qtab.read_qtab;
import qtl.core.chromosome;
import qtl.core.util.data_manip;
import qtl.core.primitives;
import qtl.core.marker;
import qtl.core.genotype;
import qtl.core.phenotype;
import qtl.plugins.qtab.read_qtab;
import qtl.core.map.map;
import qtl.core.map.make_map;

import qtl.core.map.genetic_map_functions;
import qtl.core.hmm.cross;
import qtl.core.hmm.calcgenoprob;
import qtl.core.scanone.scanone_hk;
import qtl.core.scanone.util;
import qtl.core.util.data_manip;



static string ver = import("VERSION");

string copyright = "; qtlHD project (c) 2012";
string usage = "
  usage: scanone [options] inputfile(s)

  options:

    -v --verbosity    Set verbosity level (default 1)
    -d --debug        Set debug message level (default 0)

  examples:

    Execute scanone with the listeria dataset

      ./scanone -v 1 -d 3 ../../test/data/input/listeria_qtab/listeria_symbol.qtab ../../test/data/input/listeria_qtab/listeria_founder.qtab ../../test/data/input/listeria_qtab/listeria_marker_map.qtab ../../test/data/input/listeria_qtab/listeria_genotype.qtab ../../test/data/input/listeria_qtab/listeria_phenotype.qtab
";

int main(string[] args) {
  writeln("scanone ",strip(ver)," ",copyright);
  if (args.length == 1) {
    writeln(usage);
    return 0;
  }
  writeln(args);
  uint verbosity = 1;
  uint debug_level = 0;
  getopt(args, "v|verbose", (string o, string v) { verbosity = to!int(v); },
               "d|debug", (string o, string d) { debug_level = to!int(d); }
  );

  writeln("Verbosity: ",verbosity);
  writeln("Debug level: ",debug_level);
  // Load all information into data structures, basically following
  // test/scanone/test_scanone_f2.d
  auto res = load_qtab(args[1..$]);
  auto s  = res[0];
  auto f  = res[1];
  auto ms = res[2];
  auto i  = res[3];
  auto p  = res[4];
  auto o  = res[5];
  auto g  = res[6]; // genotype combinator matrix

  if (debug_level > 2) {
    writeln("* Symbol data");
    writeln(s);
    writeln(o);
    writeln("* Individuals");
    writeln(i);
    writeln("* Genotype data");
    writeln(g[0..3]);
    writeln("* Phenotype data");
    writeln(p);
    writeln("* Marker data");
    writeln(ms);
  }

  // TODO: reduce missing phenotype data (not all individuals?)
  auto ind_to_omit = is_any_phenotype_missing(p);
  auto n_to_omit = count(ind_to_omit, true);
  writeln("Omitting ", n_to_omit, " individuals with missing phenotype");
  auto pheno = omit_ind_from_phenotypes(p, ind_to_omit);
  writeln("done omitting from phenotypes");

  auto genotype_matrix = omit_ind_from_genotypes(g, ind_to_omit);
  writeln("done omitting from genotypes");

  // cross type
  auto cross_class = form_cross(f["Cross"]);
  writeln("formed cross class");

  auto markers_by_chr = sort_chromosomes_by_marker_id(get_markers_by_chromosome(ms));

  // add pseudomarkers at 2.0 cM spacing
  auto pmar_by_chr = add_minimal_markers(markers_by_chr, 2.0);

  // inter-marker recombination fractions
  auto rec_frac = recombination_fractions(pmar_by_chr, GeneticMapFunc.Haldane);

  // empty covariate matrices
  auto addcovar = new double[][](0, 0);
  auto intcovar = new double[][](0, 0);
  auto weights = new double[](0);

  // null model
  auto rss0 = scanone_hk_null(pheno, addcovar, weights);

  // calcgenoprob for each chromosome, then scanone
  writeln(" --Peaks with LOD > 2:");
  foreach(j, chr; pmar_by_chr) {
    auto genoprobs = calc_geno_prob(cross_class, genotype_matrix, chr[1], rec_frac[j][0], 0.002);
    auto rss = scanone_hk(genoprobs, pheno, addcovar, intcovar, weights);
    auto lod = rss_to_lod(rss, rss0, pheno.length);
    auto peak = get_peak_scanone(lod, chr[1]);
    foreach(k; 0..peak.length) {
      if(peak[k][0] > 2)
        writefln(" ----Chr %-2s : peak for phenotype %d: max lod = %7.2f at pos = %7.2f", chr[0].name, k,
                 peak[k][0], peak[k][1].get_position);
    }
  }

  return 0;
}
