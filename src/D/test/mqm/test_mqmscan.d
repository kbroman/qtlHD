/**
 * Test mqm routines, using hyper_noX (CSV) set
 */

module test.mqm.test_mqmscan;

import qtl.core.primitives;
import qtl.core.chromosome;
import qtl.core.phenotype;
import qtl.core.genotype;
import qtl.core.marker;
import qtl.core.map;
import qtl.core.matrices;
import qtl.core.make_map;
import qtl.plugins.input.read_csv;
import qtl.core.scanone_hk;
import std.stdio;
import std.conv;
import std.string;
import std.path;
import std.algorithm;

alias std.algorithm.find find;

static bool VERBOSE = false;

import qtl.core.libs.libload;
import std.loader;


version (Windows) {
  extern(C){
    double function(int Nind, int *Nmark, char** cofactor, char** marker, 
               double* y, int* f1genotype, int Backwards, double **QTL,double** mapdistance,
               int **Chromo,int Nrun,int RMLorML, double windowsize,double stepsize, double stepmin,double stepmax,double
               alfa,int em,int out_Naug,int **INDlist,char reestimate, char
               crosstype,bool dominance,int verbose) analyseF2;
    int function(char*** markers,int* nind, int* augmentednind, int** INDlist,
                  double neglect_unlikely, int max_totalaugment, int max_indaugment,
                  double*** pheno_value,int nmark, int* chr, double* mapdistance,
                  int augment_strategy, char crosstype,int verbose) mqmaugmentfull; 
  }
  
  static this(){
    HXModule lib = load_library("mqm");
    load_function(analyseF2)(lib,"analyseF2");
    load_function(mqmaugmentfull)(lib,"mqmaugmentfull");
    writeln("Loaded MQM functionality");
  }
  
}else{
  extern(C){
    double analyseF2(int Nind, int *Nmark, char** cofactor, char** marker, 
               double* y, int* f1genotype, int Backwards, double **QTL,double** mapdistance,
               int **Chromo,int Nrun,int RMLorML, double windowsize,double stepsize, double stepmin,double stepmax,double
               alfa,int em,int out_Naug,int **INDlist,char reestimate, char
               crosstype,bool dominance,int verbose);
    int mqmaugmentfull(char*** markers,int* nind, int* augmentednind, int** INDlist,
                  double neglect_unlikely, int max_totalaugment, int max_indaugment,
                  double*** pheno_value,int nmark, int* chr, double* mapdistance,
                  int augment_strategy, char crosstype,int verbose);
  }
}

unittest{
  writeln("Unit test " ~ __FILE__);
  alias std.path.buildPath buildPath;
  auto fn = dirName(__FILE__) ~ sep ~ buildPath("..","..","..","..","test","data","input","hyper_noX.csv");
  if(VERBOSE) writeln("  - reading CSV " ~ fn);
  auto indata = new ReadSimpleCSV!F2(fn);
  char** markers = indata.getGenotypesForMQM();
  writeln("  - GENO DONE !!!");
  int nind = cast(int)indata.genotypes.length;
  int nmark = cast(int)indata.markers.length;
  int augmentednind = cast(int)indata.genotypes.length;
  int* INDlist = doRange(0,nind).ptr;
  int* chr = indata.getChromosomesForMQM();
  writeln("  - CHR DONE !!!");
  int* f1genotype = doRange(0,nind).ptr;
  double* mapdistance = indata.getDistancesForMQM();
  char crosstype = 'F';
  char* cofactors = doArray!char(nmark,'0').ptr;
  writeln("  - COF DONE !!!");
  int verbose = 1;
  int backwards = 0;
  double neglect_unlikely = 1;
  int max_totalaugment = 10;
  int max_indaugment = 1;
  double** pheno_value = indata.getPhenotypesForMQM();
  writeln("  - PHENO DONE !!!");
  double** QTL; //stores the result
  double windowsize = 20.0;
  double stepsize = 1.0;
  double stepmin = 0.0;
  double stepmax = 200.0;
  double alpha = 0.05;
  int maxiter = 10000;
  char estmap = 'N';
  int phenotype = 0;
  writeln("  - SETUP DONE");
  mqmaugmentfull(&markers,&nind,&augmentednind,&INDlist,neglect_unlikely, max_totalaugment, max_indaugment,&pheno_value,nmark,chr,mapdistance,1,crosstype,verbose);
  double logL = analyseF2(augmentednind, &nmark, &cofactors, markers, pheno_value[phenotype], f1genotype, backwards,QTL, &mapdistance,&chr,0,0,windowsize, stepsize,stepmin,stepmax,alpha,maxiter,nind,&INDlist,estmap,crosstype,false,verbose);
}
