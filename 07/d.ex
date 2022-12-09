defmodule D do
  defstruct name: [], size: 0, files: [], children: []
  # name is fully-qualified path name as a list, e.g. ["/", "dir1"]
  # files is a list of files in this directory
  # directories is a list of the directories in this one.
  # ... the directory names are not qualified in [directories]
  #
  # directories are expected to live in a map of name => %D{}
  # children is the list of unqualified names of children directories
  # so name ++ children[0] is the fully-qualified path for the first child directory
end
