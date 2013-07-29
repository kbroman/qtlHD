/**
 * Generic matrix functions 
 */

module qtl.core.data.matrix;

import std.conv;
import std.stdio;
import std.string;
import std.array;
import std.typecons;
import std.algorithm;

import qtl.core.phenotype;


/**
 * Return a list of booleans for rows matching the test function for every item in the row
 */

bool[] filter_matrix_by_row_2bool(T)(T[][] matrix, bool delegate (T) test ) {
  return map!( (row) { return reduce!( (count,item) => count+test(item) )(0,row) > 0 ; } )(matrix).array();

}

/**
 * pull out a column of a matrix indexed as matrix[row][col]
 **/
T[] get_column(T)(in size_t column_index, T[][] matrix)
{
  return map!( (row) { return row[column_index]; })(matrix).array();
}


/**
 * transpose of a matrix
 */
T[][] transpose_matrix(T)(in T[][] matrix)
{
  auto ret = new T[][](matrix[0].length, matrix.length);

  foreach(i, row; matrix) {
    foreach(j, element; row)
      ret[j][i] = element;
  }

  return ret;
}


unittest {
  writeln("Test get_column and transpose_matrix");

  Phenotype pheno[][];
  auto pdbl = [ ["0.0", "0.0", "0.0", "0.0", "0.0"],
                ["0.0", "0.0", "0.0", "0.0", "0.0"],
                [  "-", "0.0", "0.0",   "-", "0.0"],
                ["0.0", "0.0", "0.0", "0.0", "0.0"],
                ["0.0", "0.0", "0.0", "0.0", "0.0"],
                ["0.0", "0.0", "0.0", "0.0", "0.0"],
                [  "-",   "-",   "-",   "-",   "-"],
                ["0.0", "0.0", "0.0", "0.0", "0.0"],
                [  "-",   "-", "0.0",   "-",   "-"],
                ["0.0", "0.0", "0.0", "0.0", "0.0"],
                ["0.0",   "-",   "-", "0.0",   "-"],
                ["0.0",   "-",   "-", "0.0",   "-"],
                ["0.0", "0.0", "0.0", "0.0", "0.0"]];

  foreach(line; pdbl) {
    Phenotype[] ps = std.array.array(map!((a) {return
    set_phenotype(a);})(line));
    pheno ~= ps;
  }

  writeln("Test get_column");
  auto pcol = get_column(1, pheno);
  foreach(i, row; pheno)
    assert(row[1] == pcol[i]);

  writeln("Test transpose of phenotype matrix");
  auto tpheno = transpose_matrix(pheno);

  foreach(i, row; tpheno)
    foreach(j, element; row)
      assert(element == pheno[j][i]);
}
